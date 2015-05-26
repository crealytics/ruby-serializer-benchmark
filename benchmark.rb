require 'sequel'
require 'byebug'
require 'benchmark'
require_relative 'avro_serializer'
require_relative 'marshal_serializer'
require_relative 'csv_serializer'
require 'active_support/core_ext/hash/indifferent_access'

cache = 'tmp/dataset.dump'

data = unless File.exists?(cache)
         puts "Reloading cache file..."
         @db = Sequel.connect(ENV['DB_URI'])
         data = @db.fetch(<<-SQL).to_a.map(&:with_indifferent_access).each { |h| h['costs'] = h['costs'].to_f }
            SELECT
            keyword_sk,
            date_sk,
            account_sk,
            adgroup_sk,
            campaign_sk,
            google_structure_sk,
            impressions,
            clicks,
            costs,
            keyword,
            keyword_normalized,
            account_name,
            campaign_name,
            adgroup_name
            FROM keyword_costs
            JOIN keyword_dim USING (keyword_sk)
            LIMIT 100000
         SQL

         File.open(cache, 'wb+') do |io|
           io << Marshal.dump(data)
         end
         data
       else
         puts "Using cache file..."
         Marshal.load(File.read(cache))
       end

puts "number of records: #{data.size}"

sers = [AvroSerializer.new, MarshalSerializer.new, CsvSerializer.new('CSV(converters)', converters: :all), CsvSerializer.new('CSV(no-converters)')]

Benchmark.bm(30) do |x|
  sers.each do |ser|
    x.report("#{ser}#write") do
      ser.write do |out|
        data.each do |row|
          out << row
        end
      end
    end
    x.report("#{ser}#read") do
      count = 0
      ser.read do |row|
        count += 1
      end
    end
  end
end
