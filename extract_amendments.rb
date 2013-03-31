#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'zippy'
require 'clik'
require 'nokogiri'

xml_dump_path = nil
def debug(values); end

extra_args = cli '--xml-dump' => lambda { |path| xml_dump_path = path },
                 '-d --debug' => lambda { def debug(values) p values; end }

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
  debug amend_text: amend_text
  
  amend_doc = Nokogiri::XML::Document.parse(amend_text)
  
  num_am = amend_doc.xpath("//NumAm").first.text
  doc_amend = amend_doc.xpath("//DocAmend").first.text
  article = amend_doc.xpath("//Article").first.text
  
  amendment = {
    num_am: num_am,
    doc_amend: doc_amend,
    article: article,
  }
  debug amendment
  amendments << amendment
end

