# Calculate the distance in ksqlDB
This use case is useful for fleet management. Typically you will calculate EAT (expected arrival time) and for this you need to calculate the distnace between two locations.

## Load data first
```bash
# create topic
docker exec -it workshop-kafka  kafka-topics --create --topic atm_locations --bootstrap-server localhost:9092
docker exec -it workshop-kafka  bash -c 'cat /produce-data/atm_locations.json | kafka-console-producer --topic atm_locations --broker-list localhost:9092'
```
Create Streams on topic
```bash
docker exec -it workshop-ksqldb-cli ksql http://ksqldb-server:8088
ksql> print 'atm_locations' from beginning;
ksql> CREATE STREAM atm_locations_stream ( id VARCHAR,
                            atm VARCHAR,
                            location1 STRUCT<lon DOUBLE,
                                            lat DOUBLE>,
                            location2 STRUCT<lon DOUBLE,
                                            lat DOUBLE>)
            WITH (KAFKA_TOPIC='atm_locations',
            VALUE_FORMAT='JSON');
ksql> SET 'auto.offset.reset'='earliest';
```
Now, we can select the data and use a scalar function rto calculate the distance:
```bash
ksql> SELECT ID,
        CAST(GEO_DISTANCE(location1->lat, location1->lon, location2->lat, location2->lon, 'KM') AS INT) AS DISTANCE_BETWEEN_1and2_KM
FROM   atm_locations_stream emit changes;
ksql> exit;
```

End lab7

[go back to Agenda](https://github.com/ora0600/confluent-ksqldb-hands-on-workshop/blob/master/README.md#hands-on-agenda-and-labs)
