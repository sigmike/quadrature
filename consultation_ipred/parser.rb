
require "rubygems"
require "bundler/setup"

files = %w(organisations.links public_authorities.links)

file = files.first

links = File.read(file).split("\n")

links.each do |url|
  name = File.basename(URI.parse(url).path, ".pdf")
  names = name.split("_")
  language = names.pop
  
  name = names.map(&:capitalize).join(" ")
  p [name, language]
end

