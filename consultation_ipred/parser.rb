
require "rubygems"
require "bundler/setup"

require "nokogiri"

files = %w(organisations.html public_authorities.html)

file = files.first
doc = Nokogiri::HTML(File.read(file))

links = doc.css("a").map do |link|
  href =link["href"] 
  href if href =~ /\.pdf$/i
end.compact

p links
