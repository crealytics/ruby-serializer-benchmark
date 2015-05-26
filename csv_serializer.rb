require 'csv'

class CsvSerializer

  attr_reader :title, :csv_opts, :filename

  def initialize(title = self.class.to_s, csv_opts = {})
    @title = title
    @filename = 'tmp/data.csv'
    @csv_opts = csv_opts
  end

  def write
    CSV.open(filename, 'wb+') do |csv|
      yield Conv.new(csv)
    end
  end

  def read
    CSV.foreach(filename, csv_opts.merge(headers: true)) do |row|
      yield row.to_hash
    end
  end

  def to_s
    title
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
