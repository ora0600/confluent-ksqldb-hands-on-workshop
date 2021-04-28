# Use case TRACK & TRACE (Ready for Confluent Cloud)
In retail you will send your orders to your customer, right? For this a shipment have be created and you should able to follow the shipment (and of course the logistic service partner and your customers too).

![image](https://user-images.githubusercontent.com/73937355/116419389-4b9d3f00-a83d-11eb-91e2-fec868d32424.png)


## Create a stream (DDL for Orders)
```bash
ksql> CREATE STREAM orders_stream (
			orderid VARCHAR key,
			order_ts VARCHAR,
			shop VARCHAR,
			product VARCHAR,
			order_placed VARCHAR,
			total_amount DOUBLE,
			customer_name VARCHAR)
		with (KAFKA_TOPIC='orders',
		      VALUE_FORMAT='JSON',
		      TIMESTAMP='order_ts',
		      TIMESTAMP_FORMAT='yyyy-MM-dd''T''HH:mm:ssX');
```

## Add some demo data for orders
```bash
kqsql> insert into orders_stream (orderid, order_ts, shop, product, order_placed, total_amount, customer_name) values ('1', '2021-04-22T11:58:25Z', 'Otto', 'iPhoneX', 'BERLIN', 462.11, 'Carsten Muetzlitz');
insert into orders_stream (orderid, order_ts, shop, product, order_placed, total_amount, customer_name) values ('2', '2021-04-22T12:58:25Z', 'Apple', 'MacBookPro13', 'BERLIN', 3462.11, 'Carsten Muetzlitz');
insert into orders_stream (orderid, order_ts, shop, product, order_placed, total_amount, customer_name) values ('3', '2021-04-22T13:58:25Z', 'Amazon', 'Apple Pencil', 'BERLIN', 62.11, 'Carsten Muetzlitz');
```

## Check topic and stream data
```bash
ksql> print 'orders' from beginning;
ksql> SET 'auto.offset.reset' = 'earliest';
ksql> select * from orders_stream emit changes;
ksql> describe orders_stream;
```

## Create a stream (DDL for Shipments)
```bash
ksql> CREATE STREAM shipments_stream (
				shipmentid varchar key,
				shipment_id VARCHAR,
				shipment_ts VARCHAR,
				order_id VARCHAR,
				delivery VARCHAR)
			with (KAFKA_TOPIC='shipments',
			     VALUE_FORMAT='JSON',
			     TIMESTAMP='shipment_ts',
			     TIMESTAMP_FORMAT='yyyy-MM-dd''T''HH:mm:ssX');
```

## Add some demo data for shipments
```bash
kqsql> insert into shipments_stream (shipmentid, shipment_id, shipment_ts, order_id, delivery) values ('ship-ch83360', 'ship-ch83360', '2021-04-22T12:13:39Z', '1', 'UPS');
insert into shipments_stream (shipmentid, shipment_id, shipment_ts, order_id, delivery) values ('ship-xf72808', 'ship-xf72808', '2021-04-22T13:04:13Z', '2', 'DHL');
insert into shipments_stream (shipmentid, shipment_id, shipment_ts, order_id, delivery) values ('ship-kr47454', 'ship-kr47454', '2021-04-22T14:13:39Z', '3', 'HERMES');
```

## Check topic and stream data
```bash
ksql> print 'shipments' from beginning;
ksql> select * from shipments_stream emit changes;
ksql> describe shipments_stream;
```

## Create a new stream for shipped orders
```bash
ksql> CREATE STREAM shipped_orders AS
	SELECT
		o.orderid AS order_id,
		TIMESTAMPTOSTRING(o.rowtime, 'yyyy-MM-dd HH:mm:ss') AS order_ts,
		o.total_amount,
		o.customer_name,
		s.shipment_id,
		TIMESTAMPTOSTRING(s.rowtime, 'yyyy-MM-dd HH:mm:ss') AS shipment_ts,
		s.delivery, 
		(s.rowtime - o.rowtime) / 1000 / 60 AS ship_time
	FROM
		orders_stream o INNER JOIN shipments_stream s
	WITHIN
		30 DAYS
	ON
		o.orderid = s.order_id;
```

## Check the shipped orders stream
```bash
ksql> describe shipped_orders;
ksql> select * from shipped_orders emit changes;
```

## Create a new stream for shipped statuses
```bash
ksql> CREATE STREAM shipment_statuses_stream (
			shipment_id VARCHAR,
			status VARCHAR,
			warehouse VARCHAR)
		WITH (KAFKA_TOPIC='shipment_status',
		      VALUE_FORMAT='JSON');
```

## Add some demo data for shipments
```bash
kqsql> insert into shipment_statuses_stream (shipment_id, status, warehouse) values ('ship-kr47454', 'in delivery', 'FRANKFURT');
insert into shipment_statuses_stream (shipment_id, status, warehouse) values ('ship-kr47454', 'in delivery', 'BERLIN');
insert into shipment_statuses_stream (shipment_id, status, warehouse) values ('ship-kr47454', 'delivered', '@customer');
```

## Check, if the shipment statuses stream works properly
```bash
ksql> describe shipment_statuses_stream;
ksql> select * from shipment_statuses_stream emit changes;
```

## You can also try to insert new data via 'insert statements' and then check the stream again
```bash
ksql> INSERT INTO orders_stream (orderid, order_ts, shop, product, order_placed, total_amount, customer_name) VALUES ('"10"', '2019-03-29T06:01:18Z', 'Otto', 'iPhoneX','Berlin', 133548.84, 'Mark Mustermann');
INSERT INTO shipments_stream (shipmentid, shipment_id, shipment_ts, order_id, delivery) VALUES ('"ship-ch83360"','ship-ch83360', '2019-03-31T18:13:39Z', '10', 'UPS');
INSERT INTO shipment_statuses_stream (shipment_id, status, warehouse) VALUES ('ship-ch83360', 'in delivery', 'BERLIN');
INSERT INTO shipment_statuses_stream (shipment_id, status, warehouse) VALUES ('ship-ch83360', 'in delivery', 'FRANKFURT');
INSERT INTO shipment_statuses_stream (shipment_id, status, warehouse) VALUES ('ship-ch83360', 'delivered', '@customer');
ksql> select * from shipment_statuses_stream emit changes;
```

## Symmetric update to table
The topic behind is compacted unlimited retention. Here some aggregation functions of ksqlDB are used.
```bash
ksql> CREATE TABLE shipment_statuses_table AS
	SELECT
		shipment_id,
		histogram(status) as status_counts,
		collect_list('{ "status" : "' + status + '"}') as status_list,
		histogram(warehouse) as warehouse_counts,
		collect_list('{ "warehouse" : "' + warehouse + '"}') as warehouse_list
	FROM
		shipment_statuses_stream
	WHERE
		status is not null
	GROUP BY
		shipment_id;

ksql> describe shipment_statuses_table;
ksql> select * from shipment_statuses_table emit changes;
```

Also go and create a pull query for a given shipment id.
```bash
ksql> select * from shipment_statuses_table where SHIPMENT_ID='ship-ch83360';
```

Asymmetric join
```bash
ksql> CREATE STREAM shipments_with_status_stream AS
	SELECT
		ep.shipment_id as shipment_id,
		ep.order_id as order_id,
		ps.status_counts as status_counts,
		ps.status_list as status_list,
		ps.warehouse_counts as warehouse_counts,
		ps.warehouse_list as warehouse_list
	FROM
		shipments_stream ep LEFT JOIN shipment_statuses_table ps
	ON
		ep.shipment_id = ps.shipment_id;

ksql> describe shipments_with_status_stream;
ksql> select * from shipments_with_status_stream emit changes;
```

Result seems to be same, but add a new status to shipment ship-ch83360 and you will see the stream is not changed
```bash
ksql> INSERT INTO shipment_statuses_stream (shipment_id, status, warehouse) VALUES ('ship-ch83360', 'post-update', '@attendee');

# No change
ksql> select * from shipments_with_status_stream emit changes;

# But in table status is seen
ksql> select * from shipment_statuses_table where shipment_id='ship-ch83360';

ksql> exit;
````

End lab6

[go back to Agenda](https://github.com/ora0600/confluent-ksqldb-hands-on-workshop/blob/master/README.md#hands-on-agenda-and-labs)
