Amendment extraction
====================

It's a tool to extract amendment texts from EU documents and output them in mediawiki format.

It was made for [La Quadrature du Net](http://www.laquadrature.net/).

Installation
------------

You need Ruby 1.9+.

Clone the repository and run "bundle" to install the gems.

Usage
-----

First you must save the doc file to OpenDocument text (.odt) with OpenOffice or LibreOffice.

Then you can run the command line version:

    ./extract_amendments.rb <odt file> >result.mediawiki


Or you can use the web server :

Run the server with `ruby server.rb` and go to http://localhost:4567/. Then select your odt file and submit. Your browser should display the mediawiki text to copy/paste.

