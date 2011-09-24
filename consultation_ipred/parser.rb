
require "rubygems"
require "bundler/setup"

require "nokogiri"

files = %w(organisations.html public_authorities.html)

file = files.first
doc = Nokogiri::HTML(File.read(file))

links = doc.css("a").map do |link|
  href =link["href"] 
  href if href =~ /\.pdf$/i
end.compact.uniq { |url| URI.parse(url).path }

parsed_names = []

links.each do |url|
  name = File.basename(URI.parse(url).path, ".pdf")
  next if parsed_names.include?(name)
  parsed_names << name
  names = name.split("_")
  language = names.pop
  
  name = names.map(&:capitalize).join(" ")
  p [name, language]
end

