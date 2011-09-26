
require 'rubygems'
require 'active_support/all'
include ActiveSupport::Inflector

data = File.read('base.mediawiki')

data.gsub! %r((Amendement \d+\n<br/>\n.+\n<br/>\n)(.+)(\n<br/>[-+]*\n)) do |match|
  prefix, names, suffix = $1, $2, $3
  new_names = names.split(", ").map do |name|
    page = transliterate(name.split(/\s+|-/).map(&:capitalize).reject { |part| part == "A." }.join)
    "[[#{page}|#{name}]]"
  end.join(", ")
  prefix + new_names + suffix
end

data.gsub! %r(\|-\n\|width="50%"\|\n('''Or. '''<Original>'''\{..\}..'''|'''.'''|)</Original>\n\|width="50%"\|\n(<Original>)?</Original>\n), ''

File.open("result.mediawiki", "w") do |f|
  f.write data
end

data.scan(/=== Amendment .+?\n\|\}/m).each do |amendment|
end
