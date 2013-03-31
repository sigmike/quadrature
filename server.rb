#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'haml'

get '/' do
  haml :index
end

post '/extract' do
  haml :extract, locals: {result: %x(ruby extract_amendments.rb #{params['file'][:tempfile].path})}
end

__END__

@@ layout
%html
  %body
    = yield
    
@@ index
%form{action: "/extract", method: "POST", enctype: 'multipart/form-data'}
  %input{type: "file", name: "file"}
  %input{type: "submit"}

@@ extract
%pre= Rack::Utils.escape_html(result)
