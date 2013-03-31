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
  result = AmendmentExtractor.new.extract(params['file'][:tempfile].path, template: params['template'])
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
      %label.control-label{:for => "template"} Template
      .controls
        %textarea.input-block-level#template{rows: 20, name: "template"}= params[:template] || File.read('template.erb')
    .control-group
      .controls
        %button.btn.btn-primary{:type => "submit"} Extract

@@ extract
%textarea.input-block-level{rows: 20}= Rack::Utils.escape_html(result)
