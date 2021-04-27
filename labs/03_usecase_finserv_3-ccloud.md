# Fiancial services case: Stocktrades data (steps for Confluent Cloud)

In this lab we will create Stocktrades data and summarize it grouped by the user. 

## Create a stream
In the Confluent Cloud environment, the required topic is already created.
Now, create a stream on the topic and load some demo data in the ksqlDB Editor.

```bash
ksql> CREATE STREAM stocktrades_stream (
			userid STRING key,
			side STRING,
			symbol STRING,
			quantity INTEGER,
			price DOUBLE,
			account STRING)
		with (VALUE_FORMAT='json',
		      KAFKA_TOPIC='stocktrades');
```

## Add some demo data

```bash
insert into stocktrades_stream (userid, side, symbol, quantity, price, account) values ('1', 'BUY', 'ZJZZT', 10, 99, 'ABC123');
insert into stocktrades_stream (userid, side, symbol, quantity, price, account) values ('2', 'SELL', 'ZVZZT', 25, 999, 'LMN456');
insert into stocktrades_stream (userid, side, symbol, quantity, price, account) values ('3', 'BUY', 'ZJZZT', 100, 799, 'LMN456');
insert into stocktrades_stream (userid, side, symbol, quantity, price, account) values ('4', 'BUY', 'ZVZZT', 20, 340, 'XYZ789');
insert into stocktrades_stream (userid, side, symbol, quantity, price, account) values ('5', 'SELL', 'ZBZX', 10, 79, 'ABC123');
insert into stocktrades_stream (userid, side, symbol, quantity, price, account) values ('5', 'SELL', 'ZBZX', 10, 899, 'XYZ789');
insert into stocktrades_stream (userid, side, symbol, quantity, price, account) values ('4', 'SELL', 'ZTEST', 20, 399, 'XYZ789');
insert into stocktrades_stream (userid, side, symbol, quantity, price, account) values ('3', 'BUY', 'ZBZX', 10, 199, 'ABC123');
insert into stocktrades_stream (userid, side, symbol, quantity, price, account) values ('4', 'SELL', 'ZVZZT', 20, 399, 'LMN456');
```

## Check topic and stream data

```bash
ksql> print 'stocktrades' from beginning;
ksql> SET 'auto.offset.reset'='earliest';
ksql> select * from stocktrades_stream emit changes;
ksql> select userid, sum(quantity*price) as money_invested from stocktrades_stream group by userid emit changes;
ksql> exit;
```

End Lab 3

[go back to Agenda](https://github.com/ora0600/confluent-ksqldb-hands-on-workshop/blob/master/README.md#hands-on-agenda-and-labs)
