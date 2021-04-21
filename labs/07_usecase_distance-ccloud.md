# Calculate the distance in ksqlDB
This use case is useful for fleet management. Typically you will calculate EAT (expected arrival time) and for this you need to calculate the distnace between two locations.

## Load data first
In Confluent Cloud environment Topic is already created.
Now, create stream on topic and load data in ksqlDB Editor
```bash
ksql> CREATE STREAM atm_locations_stream ( id VARCHAR,
                            atm VARCHAR,
                            location1 STRUCT<lon DOUBLE,
                                            lat DOUBLE>,
                            location2 STRUCT<lon DOUBLE,
                                            lat DOUBLE>)
            WITH (KAFKA_TOPIC='atm_locations',
            VALUE_FORMAT='JSON');
kqsql> insert into atm_locations_stream (id,atm,location1,location2) values ('a746','NatWest', STRUCT(lat := 53.7982284, lon := -1.5469429), STRUCT(lat := 53.796226, lon := -1.5426083));
insert into atm_locations_stream (id,atm,location1,location2) values ('a746','NatWest', STRUCT(lat := 53.7982284, lon := -1.5469429), STRUCT(lat := 53.796226, lon := -1.5426083));
insert into atm_locations_stream (id,atm,location1,location2) values ('a674','Co Operative Bank', STRUCT(lat := 53.6914382, lon := -1.7997313), STRUCT(lat := 53.7986913, lon := -1.2518281));
insert into atm_locations_stream (id,atm,location1,location2) values ('a189','RBS', STRUCT(lat := 53.5540984, lon := -1.4816161), STRUCT(lat := 53.7015283, lon := -1.4630307));
insert into atm_locations_stream (id,atm,location1,location2) values ('a357','NatWest', STRUCT(lat := 53.798281, lon := -1.5469429), STRUCT(lat := 53.8018075, lon := -1.5442589));
insert into atm_locations_stream (id,atm,location1,location2) values ('a906','Halifax Building Society', STRUCT(lat := 53.9056907, lon := -1.694482), STRUCT(lat := 53.8687467, lon := -1.9042448));
insert into atm_locations_stream (id,atm,location1,location2) values ('a907','Post Office', STRUCT(lat := 53.8127993, lon := -1.6712572), STRUCT(lat := 53.8134854, lon := -1.6021803));
ksql> print 'atm_locations' from beginning;
ksql> SET 'auto.offset.reset'='earliest';
ksql> select * from atm_locations_stream emit changes;
```
Now, we can select the data and use a scalar function rto calculate the distance:
```bash
ksql> SELECT ID,
        CAST(GEO_DISTANCE(location1->lat, location1->lon, location2->lat, location2->lon, 'KM') AS INT) AS DISTANCE_BETWEEN_1and2_KM
FROM   atm_locations_stream emit changes;
```
Finally, check all function available in Confluent Cloud ksqlDB
```bash
ksql> show functions;
```

End lab7

[go back to Agenda](https://github.com/ora0600/confluent-ksqldb-hands-on-workshop/blob/master/README.md#hands-on-agenda-and-labs)
