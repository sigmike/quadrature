
require "rubygems"
require "bundler/setup"
require 'media_wiki'
require 'yaml'
require 'erb'
require 'answer'
require 'cgi'

env = ARGV.first || "development"
wiki = YAML.load(File.read("wiki.yaml"))[env]

types = YAML.load(File.read("answers.yaml"))

mw = MediaWiki::Gateway.new(wiki["url"])
mw.login(wiki["username"], wiki["password"])

erb = ERB.new File.read("wiki_page.erb"), nil, "<>"

text = ""
text << "==Analyse des réponses à la consultation IPRED==
à vous…

"

types.each do |type, answers|
  case type
  when "organisations"
    title = "Organisations"
  when "public_authorities"
    title = "Public authorities"
  else
    raise "unknown: #{type.inspect}"
  end
  text << "===#{title}===\n"
  answers.sort.each do |name, answer|
    name_with_languages = answer.name
    name_with_languages += " (" + answer.languages.join(", ") + ")" unless answer.languages.empty?
    text << erb.result(binding)
  end
  text << "\n"
  text << "[[Category:IPRED fr]]\n"
end

mw.edit('Analyse reponses consultation IPRED', text, :summary => 'Update from script', :section => 6)
