Amendment extraction
====================

It's a tool to extract amendment texts from EU documents and output them in mediawiki format.

It was made for [La Quadrature du Net](http://www.laquadrature.net/).

It's also available here: http://quadrature.herokuapp.com/


Installation
------------

You need git, Ruby 1.9+ and the gem `bundler`.

    git clone git://github.com/piglop/quadrature.git
    cd quadrature
    bundle


Usage
-----

First you must save the doc file to OpenDocument text (.odt) with OpenOffice or LibreOffice.

Then you can run the command line version:

    ruby extract_amendments.rb your_document.odt >result.mediawiki


Or you can use the web server :

Run the server with `ruby server.rb` (or `rerun server.rb`) and go to http://localhost:4567/

Then select your odt file and submit. Your browser should display the mediawiki text to copy/paste.

