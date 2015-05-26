require 'csv'

class CsvSerializer

  def initialize
    @filename = 'tmp/data.csv'
  end

  def write
    CSV.open(@filename, 'wb+') do |csv|
      yield Conv.new(csv)
    end
  end

  def read
    CSV.foreach(@filename, converters: :all, headers: true) do |row|
      yield row.to_hash
    end
  end

  class Conv
    def initialize(csv)
      @csv = csv
      @first_row = true
    end

    def <<(hash)
      if @first_row
        @csv << hash.keys
        @first_row = false
      end

      @csv << hash.values
    end
  end

end
