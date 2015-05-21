require 'nokogiri'
require 'open-uri'
require 'mechanize'
require 'time'
require 'csv'

class Autotrader
  HEADERS_HASH = {"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36"}
  PAGE_URL = "http://www.autotrader.com/cars-for-sale/Used+Cars/Coupe/BMW/M3/Vero+Beach+FL-32960?bodyStyleCodes=COUPE&endYear=2015&incremental=All&lastExec=1421363475000&listingType=used&listingTypes=used&makeCode1=BMW&maxMileage=60000&mmt=%5BBMW%5BM3%5B%5D%5D%5B%5D%5D&modelCode1=M3&numRecords=100&searchRadius=300&showcaseListingId=385223532&showcaseOwnerId=51167445&sortBy=derivedpriceASC&startYear=2011&vehicleStyleCodes=COUPE&Log=0"

  def initialize
    @timestamp = lambda { Time.now.to_i }
    @time_str = lambda { Time.now.iso8601 }
    data
  end

  # Extracts data from the page
  def data
    timestamp = @timestamp.call
    time_str = @time_str.call
    @data ||= listings.map do |listing|
      {
        id: listing['id'],
        timestamp: timestamp,
        time_str: time_str,
        title: listing.css('h2 > a > span.atcui-truncate.ymm > span').text,
        # price: listing.css('.primary-price').text.delete("$").delete(","),
        price: listing.css('.primary-price span').text.delete("$").delete(","),
        mileage: listing.css('.mileage .atcui-bold').text.delete(","),
        color: listing.css('.color .atcui-block').text,
        distance: listing.css('.distance-cont').text.split(' ')[0],
        image: listing.css('.media-img').css('img')[0]['src'],
        link: "http://www.autotrader.com#{listing.css('a').first['href']}"
      }
    end
  end

  # Extracts listings from the page
  def listings
    @listings ||= page.parser.css('.listing-findcar')
  end

  # Fetches the page
  def page
    @page ||= mech.get(PAGE_URL)
  end

  # Instantiates a new Mechanize instance 
  def mech
    @mech ||= Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
  end

  def to_csv
    data.map { |row| row.values.to_csv }.join
  end

  def csv_headers
    data.first.keys.to_csv
  end
end