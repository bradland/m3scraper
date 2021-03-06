# M3 Autotrader Scraper

## General

This repo is very rough. It's just a set of scripts that I put together, without ever intending to release. Everything is cobbled together in a way that will probably break and is not well architected... but it works!

Requires:

* Ruby (tested with 2.2.0)
* Gems
    * Nokogiri
    * Mechanize

## Usage

### Configuring what to scrape

As mentioned above, I put this together for my own purposes. The URL of the target page is a string literal stored in a constant. Yay! You'll find this in `lib/autotrader.rb` in the constant `Autotrader::PAGE_URL`. To change this, simply perform a search on Autotrader, copy the URL of that page, and replace the value of `Autotrader::PAGE_URL`. The script only fetches the first page of results, so you have to tweak your search to get A) only what you want, and B) returns fewer than 100 cars (which is the max results per page). You can simply copy/paste my existing URL in to a web browser to get a good starting point.

### Scraping

`m3scraper.rb`

This is the scraper script. Use this to fetch data and output to a file. Check the help output for options:

        ./m3scraper.rb -h

The first time you run the script, you'll want to use the `-H` flag to output column headers to your file. Something like this:

        ./m3scraper.rb -H > data/m3data.csv

After that, I use a cron task that redirects output to the file I initialized above. My cron task looks like this:

        0   8   *   *   *   /home/bradland/code/m3scraper/m3scraper.rb >> /home/bradland/code/m3scraper/data/m3data.csv

This runs the script every morning at 8 AM and appends data to m3data.csv. Note the use of >> to _append_ data, rather than overwriting the file.

### Analysis

`analyze.rb`

This is the analysis script. It consumes CSV generated by the scraper script, and outputs a report in human readable text or TSV format. TSV can be easily pasted in to spreadsheet applications like Excel or Google Drive Spreadsheets.

Run it without any arguments to see the help:

        ./analyze.rb

Pass a CSV file from the scraper script to see analysis:

        ./analyze.rb data/m3data.csv

Use the `-t` flag to get TSV output:

        ./analyze.rb -t data/m3data.csv

On OS X, you can send the output directly to your clipboard

        ./analyze.rb -t data/m3data.csv | pbcopy

See `man pbcopy` for details.

### Resources

* http://ruby.bastardsbook.com/chapters/web-scraping/
* http://ruby.bastardsbook.com/chapters/web-crawling/
* http://ruby.bastardsbook.com/chapters/mechanize/