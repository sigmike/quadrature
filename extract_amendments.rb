#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'zippy'
require 'clik'
require 'nokogiri'
require 'erb'
require 'ostruct'
require 'active_support/core_ext/object'

class AmendmentExtractor
  def debug(value)
    if $DEBUG
      case value
      when String
        output = value
      else
        output = value.inspect
      end
      STDERR.puts output
    end
  end

  def extract(opendocument_path, options = {})
    debug "extracting content from document"
    xml = nil
    Zippy.open(opendocument_path) do |zip|
      xml = zip['content.xml']
    end

    
    debug "parsing document xml"
    doc = Nokogiri::XML::Document.parse(xml)

    if options[:xml_dump_path]
      debug "dumping xml"
      File.open(options[:xml_dump_path], "w") { |f| f.write doc.to_xml(indent: 2) }
    end

    
    debug "parsing styles"
    styles = {}
    doc.css("style|style").each do |node|
      name = node["style:name"]
      style = {}
      
      text_properties = node.css("style|text-properties").first
      if text_properties
        style[:bold] = (text_properties["fo:font-weight"] == "bold")
      end
      
      styles[name] = style
    end

    
    debug "extracting document text"
    text = doc.xpath('//office:text').first
    raise "no office:text found" unless text

    
    debug "extracting amendment nodes"
    amend_start = nil
    amend_nodes = []

    text.children.each_with_index do |node, i|
      if node.search("[text()='<Amend>']").size > 0 or node.search("[text()='<RepeatBlock-Amend><Amend>']").size > 0
        amend_start = i
      elsif node.search("[text()='</Amend>']").size > 0
        if amend_start.nil?
          raise "amend end before amend start (#{node.path})"
        end
        amend_end = i
        amend_nodes << text.children.slice(amend_start..amend_end)
        amend_start = nil
      end
    end

    debug amendments_found: amend_nodes.length

    
    debug "extracting info from amendments"
    amendments = []

    amend_nodes.each do |nodes|
      amend_text = nodes.map(&:text).join
      debug amend_text: amend_text unless options[:parse_only_num]
      
      amend_doc = Nokogiri::XML::Document.parse(amend_text)
      
      num_am = amend_doc.xpath("//NumAm").first.text
      
      next if options[:parse_only_num] and num_am != options[:parse_only_num].to_s

      
      debug "parsing amendment #{num_am}"
      
      doc_amend = amend_doc.xpath("//DocAmend").first.text
      article = amend_doc.xpath("//Article").first.text
      
      amendment = OpenStruct.new
      amendment.num = num_am
      amendment.doc = doc_amend
      amendment.article = article
      debug amendment

      
      debug "parsing amendment table"
      tables = nodes.css('table|table')
      raise "amendment table not found" if tables.size == 0
      raise "too many tables" if tables.size > 1
      table = tables.first

      
      debug "converting table nodes to text"
      text_table = table.css("table|table-row").map do |row|
        row.css("table|table-cell").map do |cell|
          cell.css("text|p").map do |paragraph|
            parts = paragraph.children.map do |element|
              text = element.text
              style = :normal
              
              if text.present? and element.is_a? Nokogiri::XML::Element
                style_name = element["text:style-name"]
                if style_name and styles[style_name][:bold]
                  style = :bold
                end
              end
              
              [style, text]
            end
            
            # merge contiguous styles
            result = []
            last_style = nil
            parts.each do |style, text|
              if style == last_style
                result.last[1] += text
              else
                result << [style, text]
              end
            end
            
            result = result.map do |style, text|
              case style
              when :bold
                "'''#{text}'''"
              else
                text
              end
            end.join
            
          end.join("\n")
        end
      end
      debug text_table: text_table
      

      debug "extracting changes from table"
      changes = text_table[2..-1]
      raise "amendment changes not found" if changes.size == 0
      
      debug changes: changes
      amendment.changes = changes
      
      if justification_title_parent_node = nodes.detect { |node| node.search("[text()='<TitreJust>']").size > 0 }
        justification_title_index = nodes.index(justification_title_parent_node)
        justification_node = nodes[justification_title_index + 1]
        justification_text = justification_node.text
        debug justification_text: justification_text
        amendment.justification = justification_text
      end

      
      amendments << amendment
      
      break if options[:parse_only_one]
    end

    debug "rendering amendments"
    template_text = options[:template] || File.read('template.erb')
    template = ERB.new template_text, 4, '-'

    erb_binding = OpenStruct.new(amendments: amendments).instance_eval { binding }.taint
    output = template.result(erb_binding)
  end
end

if $0 == __FILE__
  options = {}

  extra_args = cli '--xml-dump'   => lambda { |path| options[:xml_dump_path] = path },
                  '-d --debug'    => lambda { $DEBUG = true },
                  '-1 --one'      => lambda { options[:parse_only_one] = true },
                  '-n --number'   => lambda { |num| options[:parse_only_num] = num },
                  '-t --template' => lambda { |file| options[:template] = File.read(file) }

  opendocument_path = extra_args.first
  raise "usage: #$0 <OpenDocument file>" unless opendocument_path
  
  puts AmendmentExtractor.new.extract(opendocument_path, options)
end
