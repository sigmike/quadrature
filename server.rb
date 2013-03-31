#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'haml'
require './extract_amendments'

get '/' do
  haml :index
end

post '/extract' do
  result = AmendmentExtractor.new.extract(params['file'][:tempfile].path)
  haml :extract, locals: {result: result}
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
