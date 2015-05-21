require 'bigdecimal'
require 'car/store'

class Car
  attr_reader :id, :name, :records, :all_records, :stats


  def initialize(id, name, records)
    @id = id
    @name = name
    @all_records = records.sort_by { |row| row[:timestamp] }
    @records = format_records(@all_records)
  end

  # Calculates average dollars per mile.
  def average_dollars_per_mile
    @records.reduce([]) do |memo, row|
      next if row[:mileage] == 0
      row[:price].to_f / row[:mileage].to_f
    end
  end

  def days_listed
    (records.last[:timestamp] - records.first[:timestamp])/(24 * 60 * 60)
  end

  def drop
    records.first[:price] - records.last[:price]
  end

  def label
    "%s [%s]" % [name, id]
  end

  def latest_price
    records.last[:price]
  end

  def latest_time
    records.last[:time]
  end

  def link
    records.last[:link]
  end

  def mileage
    records.last[:mileage]
  end

  def records_count
    all_records.count
  end

  def records_kept
    records.count
  end

  def start_time
    records.first[:time]
  end

  def starting_price
    records.first[:price]
  end

  def year
    year_str = label.scan /[0-9]{4} /
    year_str.empty? ? "N/A" : year_str[0].strip
  end

  private

  # Reformats basic hash rows with correct types.
  def format_records(records)
    records = records.map do |row|
      row[:timestamp] = row[:timestamp].to_i
      row[:time] = Time.at(row[:timestamp].to_i)
      row[:price] = row[:price].to_i
      row[:mileage] = row[:mileage].to_i
      row[:distance] = row[:distance].to_i
      row
    end
    records.reject! { |row| row[:price] == 0}
    records.reject! { |row| row[:mileage] == 0}
    records
  end
end
