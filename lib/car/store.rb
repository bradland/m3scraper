require 'car'

class Car
  class Store
    attr_accessor :cars, :csv

    def initialize(file, options={})
      @csv = load(file)
    end

    # Returns an array of Car objects.
    def cars
      groups.map do |id, records|
        Car.new(id, records.first[:title], records)
      end
    end

    # Returns a hash of grouped CSV rows, grouped by ID.
    def groups
      @groups ||= @csv.group_by { |row| row[:id] }
    end

    # Loads data from CSV file.
    def load(file)
      rows = CSV.read(file)
      headers = rows.shift.map { |col| col.parameterize.underscore.to_sym }
      rows.map! { |row| Hash[headers.zip(row)] }
    end
  end
end
