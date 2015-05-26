require 'avro'

AVRO_SCHEMA = <<-JSON
{ "type": "record",
  "name": "Row",
  "fields" : [
    {"name": "keyword_sk", "type": "long"},
    {"name": "date_sk", "type": "long"},
    {"name": "account_sk", "type": "long"},
    {"name": "adgroup_sk", "type": "long"},
    {"name": "campaign_sk", "type": "long"},
    {"name": "google_structure_sk", "type": "long"},
    {"name": "impressions", "type": "int"},
    {"name": "clicks", "type": "int"},
    {"name": "costs", "type": "double"},
    {"name": "keyword", "type": "string"},
    {"name": "keyword_normalized", "type": "string"},
    {"name": "account_name", "type": "string"},
    {"name": "campaign_name", "type": "string"},
    {"name": "adgroup_name", "type": "string"}
  ]}
JSON

class AvroSerializer

  def initialize
    @filename = 'tmp/avro.avr'
  end

  def write
    file = File.open(@filename, 'wb+')
    schema = Avro::Schema.parse(AVRO_SCHEMA)
    writer = Avro::IO::DatumWriter.new(schema)
    dw = Avro::DataFile::Writer.new(file, writer, schema)
    yield dw
    #dw << {"username" => "john", "age" => 25, "verified" => true, "date" => Date.today}
    #dw << {"username" => "ryan", "age" => 23, "verified" => false, "date" => Date.today}
    dw.close
  end

  def read(&block)
    file = File.open(@filename, 'r+')
    dr = Avro::DataFile::Reader.new(file, Avro::IO::DatumReader.new)
    dr.each(&block)
  end

  def to_s
    'Avro'
  end
end
