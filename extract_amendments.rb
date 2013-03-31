#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'zippy'
require 'clik'
require 'nokogiri'

xml_dump_path = nil
def debug(values)
end
parse_only_one = false
parse_only_num = nil

extra_args = cli '--xml-dump'  => lambda { |path| xml_dump_path = path },
                 '-d --debug'  => lambda { def debug(values) p values; end },
                 '-1 --one'    => lambda { parse_only_one = true },
                 '-n --number' => lambda { |num| parse_only_num = num }

opendocument_path = extra_args.first
raise "usage: #$0 <OpenDocument file>" unless opendocument_path

xml = nil
Zippy.open(opendocument_path) do |zip|
  xml = zip['content.xml']
end

doc = Nokogiri::XML::Document.parse(xml)

if xml_dump_path
  File.open(xml_dump_path, "w") { |f| f.write doc.to_xml(indent: 2) }
end


text = doc.xpath('//office:text').first
raise "no office:text found" unless text

amend_start = nil
amend_nodes = []

text.children.each_with_index do |node, i|
  if node.search("[text()='<Amend>']").size > 0
    amend_start = i
  elsif node.search("[text()='</Amend>']").size > 0
    if amend_start.nil?
      raise "amend end before amend start"
    end
    amend_end = i
    amend_nodes << text.children.slice(amend_start..amend_end)
    amend_start = nil
  end
end

puts "#{amend_nodes.length} amendments found"

amendments = []

amend_nodes.each do |nodes|
  amend_text = nodes.map(&:text).join
  debug amend_text: amend_text unless parse_only_num
  
  amend_doc = Nokogiri::XML::Document.parse(amend_text)
  
  num_am = amend_doc.xpath("//NumAm").first.text
  
  next if parse_only_num and num_am != parse_only_num
  
  doc_amend = amend_doc.xpath("//DocAmend").first.text
  article = amend_doc.xpath("//Article").first.text
  
  amendment = {
    num_am: num_am,
    doc_amend: doc_amend,
    article: article,
  }
  debug amendment
  
  tables = nodes.css('table|table')
  raise "amendment table not found" if tables.size == 0
  raise "too many tables" if tables.size > 1
  table = tables.first
  
  text_table = table.css("table|table-row").map do |row|
    row.css("table|table-cell").map do |cell|
      cell.css("text|p").map do |paragraph|
        paragraph.children.map do |element|
          if element.is_a? Nokogiri::XML::Element and element.name == 'span'
            "'''#{element.text}'''"
          else
            element.text
          end
        end.join
      end.join("\n")
    end
  end
  debug text_table: text_table
  
  header_index = text_table.index(["Text proposed by the Commission", "Amendment"])
  raise "first row not found in table of amendment #{num_am}" unless header_index
  
  changes = text_table[(header_index + 1)..-1]
  raise "amendment changes not found" if changes.size == 0
  
  debug changes: changes
  amendment[:changes] = changes
  
  amendments << amendment
  
  break if parse_only_one
end

