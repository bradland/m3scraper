#!/usr/bin/env ruby

$: << File.expand_path('../lib', __FILE__)
require 'ostruct'
require 'optparse'
require 'awesome_print'
require 'csv'
require 'pry'
require 'i18n'
require 'active_support/core_ext/string/inflections'
require 'action_view'
require 'set' # this should only be required until i18n updates to new rev
require 'car'

I18n.enforce_available_locales = true # I18n warns unless this is set


class Analyze
  class Util
    attr_accessor :debug

    def initialize
      @debug = false
    end

    def dbm(msg, indent=0)
      $stderr.puts "#{'  ' * indent}#{msg}" if @debug
    end
  end

  include ActionView::Helpers::NumberHelper

  ::Version = [0,0,1]

  attr_accessor :options

  def initialize(args)
    @options = OpenStruct.new
    @options.format = :list
    @util = Util.new

    opt_parser = OptionParser.new do |opt|
      opt.banner = "Usage: #{$0} [OPTION]... [FILE]..."

      opt.on("-t","--tsv","Output TSV format instead of standard list.") do
        @options.format = :tsv
      end

      opt.on("-d", "--debug", "Run with debug messages enabled.") do
        @util.debug = true
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

    # ARGV check - must include at least 1 file arg
    unless ARGV.length >= 1
      $stderr.puts "Error: You must provide at least one file argument."
      $stderr.puts opt_parser
      exit 64 # EX_USAGE
    end
  end

  def run!
    cars = Car::Store.new(ARGV.shift).cars

    # binding.pry # DEBUG

    # Construct data rows
    data = cars.map do |car|
      next if car.records.size < 1
      {
        label: car.label,
        records: car.records_count,
        kept: car.records_kept,
        starting_price: car.starting_price,
        latest_price: car.latest_price,
        drop: car.drop,
        days_listed: car.days_listed,
        start_time: car.start_time,
        latest_time: car.latest_time,
        year: car.year,
        mileage: car.mileage,
        avg_price_mile: car.average_dollars_per_mile,
        link: car.link
      }
    end.reject! { |row| row.nil? }

    # Report
    case @options.format
    when :list
      data.each do |row|
        report row[:label], 0
        report "Kept %s out of %s records" % [row[:kept], row[:records]], 1
        report "Starting price: $%d" % [row[:starting_price]], 1
        report "Latest price:   $%d" % [row[:latest_price]], 1
        report "Price drop:     $%d" % [row[:drop]], 1
        report "Days listed:    %d days" % [row[:days_listed]], 1
        report "Starting date:  %s" % [row[:start_time]], 1
        report "Lastest date:   %s" % [row[:latest_time]], 1
        report "Year model:     %s" % [row[:year]], 1
        report "Mileage:        %s" % [row[:mileage]], 1
        report "Avg price/mile: $%01.2f" % [row[:avg_price_mile]], 1
        # report "Link: %s" % [car.records.last[:link]], 1
      end
    when :tsv
      puts data.first.keys.join("\t")
      data.each do |row|
        puts row.values.join("\t")
      end
    end
  end

  def report(msg, indent=0)
    $stdout.puts "#{'  ' * indent}#{msg}"
  end

end

begin
  if $0 == __FILE__
    Analyze.new(ARGV).run!
  end
rescue Interrupt
  # Ctrl^C
  exit 130
rescue Errno::EPIPE
  # STDOUT was closed
  exit 74 # EX_IOERR
end
