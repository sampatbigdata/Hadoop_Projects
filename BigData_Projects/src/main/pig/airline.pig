DEFINE AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();
DEFINE CSVExcelStorage org.apache.pig.piggybank.storage.CSVExcelStorage();
DEFINE UUID com.airline.project.pigudf.UUIDGenerator();

set aggregate.warning true;

airlineData_07_08_raw =
            LOAD '${INPUT_PATH}'
            USING CSVExcelStorage(',','NO_MULTILINE','UNIX','SKIP_INPUT_HEADER')
            AS (Year:chararray,Month:chararray,DayofMonth:chararray,DayOfWeek:chararray,DepTime:chararray,
                CRSDepTime:chararray,ArrTime:chararray,CRSArrTime:chararray,UniqueCarrier:chararray,
                FlightNum:chararray,TailNum:chararray,ActualElapsedTime:chararray,CRSElapsedTime:chararray,
                AirTime:chararray,ArrDelay:chararray,DepDelay:chararray,Origin:chararray,Dest:chararray,
                Distance:chararray,TaxiIn:chararray,TaxiOut:chararray,Cancelled:chararray,
                CancellationCode:chararray,Diverted:chararray,CarrierDelay:chararray,WeatherDelay:chararray,
                NASDelay:chararray,SecurityDelay:chararray,LateAircraftDelay:chararray);

filter_airlineData_07_08_raw_header = FILTER airlineData_07_08_raw  BY ( CRSDepTime != 'CRSDepTime' );

add_uuid_time_airportData_raw =
            FOREACH filter_airportData_raw_header
               GENERATE
                  UUID() as uuid,
                  Year as year,
                  Month as month,
                  DayofMonth as dayOfMonth,
                  DayOfWeek as dayOfWeek,
                  DepTime as depTime,
                  CRSDepTime as crsDepTime,
                  ArrTime as arrTime,
                  CRSArrTime as csrArrTime,
                  UniqueCarrier as uniqueCarrier,
                  FlightNum as flightNum,
                  TailNum as tailNum,
                  ActualElapsedTime as actualElapsedTime,
                  CRSElapsedTime as crsElapsedTime,
                  AirTime as airTime,
                  ArrDelay as arrDelay,
                  DepDelay as depDelay,
                  Origin as origin,
                  Dest as dest,
                  Distance as distance,
                  TaxiIn as taxiIn,
                  TaxiOut as taxiOut,
                  Cancelled as cancelled,
                  CancellationCode as cancellationCode,
                  Diverted as diverted,
                  CarrierDelay as carrierDelay,
                  WeatherDelay as weatherDelay,
                  NASDelay as nasDelay,
                  SecurityDelay as securityDelay,
                  LateAircraftDelay as lateAircraftDelay;

STORE add_uuid_time_airportData_raw
    INTO '${OUTPUT_PATH}'
    USING AvroStorage;