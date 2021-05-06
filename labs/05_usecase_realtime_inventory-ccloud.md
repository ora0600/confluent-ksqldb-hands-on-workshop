# Use case: Real-time Inventory (Ready for Confluent Cloud)

This use case is useful for inventory management. It demonstrates how to create a ksqlDB stream based on a Kafka topic, then aggregate the item quantity and group the inventory by product item.

## Create a stream
In the Confluent Cloud environment, the required topic is already created.
Now, create a stream on the topic and load some demo data in the ksqlDB Editor.

```bash
ksql> CREATE STREAM inventory_stream (
			id STRING key,
			cid STRING,
			item STRING,
			qty INTEGER,
			price DOUBLE,
			balance INTEGER)
		with (VALUE_FORMAT='json',
		      KAFKA_TOPIC='inventory');
```

## Add some demo data
```bash
kqsql> insert into inventory_stream (id, cid,item,qty,price) values ('1', '1', 'Apple Magic Mouse 2', 10, 99);
insert into inventory_stream (id, cid,item,qty,price) values ('2', '2', 'iPhoneX', 25, 999);
insert into inventory_stream (id, cid,item,qty,price) values ('3', '3', 'MacBookPro13', 100, 1799);
insert into inventory_stream (id, cid,item,qty,price) values ('4', '4', 'iPad4', 20, 340);
insert into inventory_stream (id, cid,item,qty,price) values ('5', '5', 'Apple Pencil', 10, 79);
insert into inventory_stream (id, cid,item,qty,price) values ('5', '5', 'PhoneX', 10, 899);
insert into inventory_stream (id, cid,item,qty,price) values ('4', '4', 'iPad4', -20, 399);
insert into inventory_stream (id, cid,item,qty,price) values ('3', '3', 'MacBookPro13', 10, 1899);
insert into inventory_stream (id, cid,item,qty,price) values ('4', '4', 'iPad4', 20, 399);
```
Why do we have two id's? 
Is this technically required? What could be a potential reason for that?

## Check topic and stream data
```bash
ksql> print 'inventory' from beginning;
ksql> SET 'auto.offset.reset'='earliest';
ksql> SET 'commit.interval.ms' = '1000'
ksql> select * from inventory_stream emit changes;
```

## Make the most up2date information via stateful table
```bash
ksql> CREATE TABLE inventory_stream_table
	WITH (kafka_topic='inventory_table') AS
	SELECT
		item,
		SUM(qty) AS item_qty
	FROM
		inventory_stream
	GROUP BY
		item emit changes;

ksql> describe inventory_stream_table;
```
The group by clause 're-keys' the message in the newly created topic. Check also the Cloud UI topic viewer to see the results.
What do you think, is the 'cleanup.policy' of this topic? Why?

## Output of our inventory via push query
```bash
ksql> select * from inventory_stream_table emit changes;
```
## Output of our inventory via pull query
```bash
ksql> select * from inventory_stream_table where item='iPad4';
ksql> select * from inventory_stream_table where item='iPhoneX';
```

## Add some more data and 
```bash
kqsql> insert into inventory_stream (id, cid,item,qty,price) values ('11', '11', 'Apple Magic Mouse 2', 15, 90);
insert into inventory_stream (id, cid,item,qty,price) values ('12', '12', 'iPhoneX', 10, 900);
```

Keep an eye on the existing push query against table 'INVENTORY_STREAM_TABLE' while inserting new data.

Where is topic INVENTORY_STREAM_TABLE and what it is?
```bash
ksql> list tables;
ksql> list topics;
ksql> exit;
````
Check also the running queries in ksqlDB UI in Control Center and compare SINK and SOURCE of CTAS_INVENTORY_STREAM_TABLE_5. Is that what you expected?

End lab5

[go back to Agenda](https://github.com/ora0600/confluent-ksqldb-hands-on-workshop/blob/master/README.md#hands-on-agenda-and-labs)
