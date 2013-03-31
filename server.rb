#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'haml'
require './extract_amendments'

get '/' do
  haml :index, locals: {template: File.read("template.erb")}
end

post '/extract' do
  result = AmendmentExtractor.new.extract(params['file'][:tempfile].path)
  haml :extract, locals: {result: result}
end

get '/bootstrap.min.css' do
  send_file 'bootstrap.min.css'
end

__END__

@@ layout
%html
  %head
    %link{:href => "/bootstrap.min.css", :rel => "stylesheet"}/

  %body
    .container
      %h1 Amendment Extractor
      = yield
    
@@ index
.well
  %form.form-horizontal{action: "/extract", method: "POST", enctype: 'multipart/form-data'}
    .control-group
      %label.control-label{:for => "file"} ODT File
      .controls
        %input#file{type: "file", name: "file"}
    .control-group
      .controls
        %button.btn.btn-primary{:type => "submit"} Extract

@@ extract
%textarea{rows: 20, style: 'width: 100%'}= Rack::Utils.escape_html(result)
