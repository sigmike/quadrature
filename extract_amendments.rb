#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'zippy'
require 'clik'
require 'nokogiri'

xml_dump_path = nil

extra_args = cli '--xml-dump' => lambda { |path| xml_dump_path = path }

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


