#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'zippy'


opendocument_path = ARGV.first
raise "usage: #$0 <OpenDocument file>" unless opendocument_path

xml = nil
Zippy.open(opendocument_path) do |zip|
  xml = zip['content.xml']
end

puts xml.size
