#!/usr/bin/env ruby

$: << File.expand_path('../lib', __FILE__)
require 'ostruct'
require 'optparse'
require 'autotrader'

class M3Scraper

  ::Version = [0,0,1]

  attr_accessor :options

  def initialize(args)
    @options = OpenStruct.new

    opt_parser = OptionParser.new do |opt|
      opt.banner = "Usage: #{$0} [OPTION]... [FILE]..."

      opt.on("-H","--headers","Print headers with data.") do
        @options.headers = true
      end

      opt.on_tail("-h","--help","Print usage information.") do
        $stderr.puts opt_parser
        exit 0
      end

      opt.on_tail("--version", "Show version") do
        puts ::Version.join('.')
        exit 0
      end
    end

    begin
      opt_parser.parse!
    rescue OptionParser::InvalidOption => e
      $stderr.puts "Specified #{e}"
      $stderr.puts opt_parser
      exit 64 # EX_USAGE
    end
  end

  def run!
    at = Autotrader.new
    if @options.headers
      puts at.csv_headers
    end
    puts at.to_csv
  end

end

begin
  if $0 == __FILE__
    M3Scraper.new(ARGV).run!
  end
rescue Interrupt
  # Ctrl^C
  exit 130
rescue Errno::EPIPE
  # STDOUT was closed
  exit 74 # EX_IOERR
end
