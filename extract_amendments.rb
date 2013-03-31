#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'zippy'
require 'clik'

xml_dump_path = nil

cli '--xml-dump' => lambda { |path| xml_dump_path = path }

opendocument_path = ARGV.first
raise "usage: #$0 <OpenDocument file>" unless opendocument_path

xml = nil
Zippy.open(opendocument_path) do |zip|
  xml = zip['content.xml']
end

if xml_dump_path
  File.open(xml_dump_path, "w") { |f| f.write xml }
end

puts xml.size
