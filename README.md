## quick benchmark: serialize bigger datasets

A quick comparison of different ways to serialize a flat dataset with
mixed types.

The goal for a serializer implementation is to translate from/to ruby
hashes while maintaining proper ruby types.

### Assumptions

* Everything fits into memory (at least for the test setup)

### Implementations

#### MarshalSerializer

* Builds internal buffer and dumps it in one go

#### AvroSerializer

* Uses a proper Avro data schema
* Does not support date types (yet?)
* [Types supported](https://avro.apache.org/docs/1.7.7/spec.html#schema_primitive)

#### CsvSerializer

* With or without data type converters (note that the latter then does
  not fulfil the requirements - it just passes strings back)
* Standard ruby implementation

### Sample Output

On my machine (ruby MRI 2.1.3) this yields:
```
number of records: 500000
                                     user     system      total
real
Avro#write                      16.160000   0.610000  16.770000 (16.803215)
Avro#read                       32.010000   0.000000  32.010000 (32.045160)
Marshal#write                   21.970000   0.420000  22.390000 (22.572216)
Marshal#read                    24.470000   0.580000  25.050000 (25.081736)
CSV(converters)#write           14.650000   0.120000  14.770000 (14.807527)
CSV(converters)#read           162.000000   0.130000 162.130000(162.634628)
CSV(no-converters)#write        15.080000   0.170000  15.250000 (15.301996)
CSV(no-converters)#read         34.030000   0.050000  34.080000 (34.268313)
```
