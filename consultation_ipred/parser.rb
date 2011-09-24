
require "rubygems"
require "bundler/setup"
require 'cgi'
require 'iconv'

files = %w(organisations.links public_authorities.links)

file = files.first

links = File.read(file).split("\n")

class Answer < Struct.new(:name, :files, :annexes, :languages)
  def initialize(*args)
    super
    self.annexes ||= []
    self.files ||= []
    self.languages ||= []
  end
end

answers = {}

links.each do |url|
  name = File.basename(URI.parse(url).path, ".pdf")
  name = CGI::unescape(name)
  #name = Iconv.iconv("utf-8", "iso8859-15", name).first
  names = name.split("_")
  language = names.pop
  
  annex = names.index { |part| part =~ /^annex/ }
  if annex
    names[annex..-1] = []
  end
  
  name = names.map(&:capitalize).join(" ")
  #name = "#{name} (#{language})"
  
  answer = answers[name] ||= Answer.new(name)
  if annex
    answer.annexes << url
  else
    answer.files << url
  end
  answer.languages << language
  answer.languages.uniq!
end

answers.sort.each do |name, answer|
  puts "#{answer.name} (#{answer.languages.join(",")})"
  (answer.files + answer.annexes).each do |url|
    # p answer
    name = File.basename(URI.parse(url).path)
    puts "  " + name
  end
end
