
require "rubygems"
require "bundler/setup"
require 'cgi'
require 'iconv'
require 'answer'
require 'yaml'

files = %w(organisations public_authorities)

files.each do |type|
  file = type + ".links"

  links = File.read(file).split("\n")

  answers = {}

  links.each do |url|
    name = File.basename(URI.parse(url).path, ".pdf")
    name = CGI::unescape(name)
    #name = Iconv.iconv("utf-8", "iso8859-15", name).first
    names = name.split("_")
    
    language = names.last.dup
      
    language.gsub!(/\s/, "")
    if language.size == 2
      names.pop
    else
      language = nil
    end
    
    annex = names.index { |part| part =~ /^annex/ }
    if annex
      names[annex..-1] = []
    end
    
    raise "no name on #{url}" if names.empty?
    
    name = names.map(&:capitalize).join(" ")
    #name = "#{name} (#{language})"
    
    answer = answers[name] ||= Answer.new(name)
    if annex
      answer.annexes << url
    else
      answer.files << url
    end
    if language
      answer.languages << language
      answer.languages.uniq!
    end
  end

  answers.sort.each do |name, answer|
    puts "#{answer.name} (#{answer.languages.join(",")})"
    (answer.files + answer.annexes).each do |url|
      # p answer
      name = File.basename(URI.parse(url).path)
      puts "  " + name
    end
  end

  File.open(type + ".yaml", "w") do |f|
    f.puts answers.to_yaml
  end
end
