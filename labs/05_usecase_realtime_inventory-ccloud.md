# Use case: Real-time Inventory (need to be rewrite for Confluent Cloud)

Produce Inventory Data into Kafka
```bash
docker exec -it workshop-kafka bash -c 'cat /produce-data/Inventory.json | kafka-console-producer --topic inventory --broker-list localhost:9092  --property "parse.key=true" --property "key.separator=:"'
```
consume from inventory
```bash
docker exec -it workshop-kafka kafka-console-consumer --topic inventory --bootstrap-server localhost:9092 --from-beginning
```
Now, data from all Inventories are online, go to ksqlDB and create a centralized view:
```bash
docker exec -it workshop-ksqldb-cli ksql http://ksqldb-server:8088
ksql> CREATE STREAM inventory_stream (cid STRING, item STRING, qty INTEGER, price DOUBLE, balance INTEGER) with (VALUE_FORMAT='json',  KAFKA_TOPIC='inventory');
ksql> SET 'auto.offset.reset' = 'earliest';
ksql> select * from inventory_stream emit changes;
```
Make the most up2date information via stateful table
```bash
ksql> CREATE TABLE inventory_stream_table AS SELECT item, SUM(qty) AS item_qty FROM inventory_stream GROUP BY item emit changes;
ksql> describe inventory_stream_table;
```
output of our inventory via push query
```bash
ksql> select * from inventory_stream_table emit changes;
```
output of our inventory via pull query
```bash
ksql> select * from inventory_stream_table where item='iPad4';
ksql> select * from inventory_stream_table where item='iPhoneX';
```
Where is topic INVENTORY_STREAM_TABLE and what it is?
```bash
ksql> list tables;
ksql> list topics;
ksql> exit;
````
Check also the running queries in ksqlDB UI in Control Center and compare SINK and SOURCE of CTAS_INVENTORY_STREAM_TABLE_5. Is that what you expected?

End lab5

[go back to Agenda](https://github.com/ora0600/confluent-ksqldb-hands-on-workshop/blob/master/README.md#hands-on-agenda-and-labs)
