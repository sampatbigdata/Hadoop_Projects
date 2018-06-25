-- REGISTER /home/cloudera/Desktop/Spark-Kafka-UseCase/Jar_Pig_Avro/avro.jar;
-- REGISTER /home/cloudera/Desktop/Spark-Kafka-UseCase/Jar_Pig_Avro/json-simple-1.1.jar;
-- REGISTER /home/cloudera/Desktop/Spark-Kafka-UseCase/Jar_Pig_Avro/piggybank.jar;
-- REGISTER /home/cloudera/Desktop/Spark-Kafka-UseCase/BigData_Projects-1.0-SNAPSHOT_java7.jar;

DEFINE AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();
DEFINE CSVExcelStorage org.apache.pig.piggybank.storage.CSVExcelStorage();
DEFINE UUID com.airline.project.pigudf.UUIDGenerator();

set aggregate.warning true;

planeData_raw =
            LOAD '${INPUT_PATH}'
            USING CSVExcelStorage(',','NO_MULTILINE','UNIX','SKIP_INPUT_HEADER')
            AS (tailnum:chararray,
                type:chararray,
                manufacturer:chararray,
                issue_date:chararray,
                model:chararray,
                status:chararray,
                aircraft_type:chararray,
                engine_type:chararray,
                year:chararray);


filter_planeData_raw_header = FILTER planeData_raw  BY ( tailnum != 'tailnum');

filter_planeData_raw_empty = FILTER filter_planeData_raw_header  BY ( type != '');

add_uuid_time_planeData_raw =
            FOREACH filter_planeData_raw_empty
               GENERATE
                  UUID() as uuid,
                  tailnum as tailnum,
                  type as type,
                  manufacturer as manufacturer,
                  issue_date as issue_date_format,
                  model as model,
                  status as status,
                  aircraft_type as aircraft_type,
                  engine_type as engine_type,
                  year as year;

STORE add_uuid_time_planeData_raw
    INTO '${OUTPUT_PATH}'
    USING org.apache.pig.piggybank.storage.avro.AvroStorage();