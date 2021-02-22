# Stock pricing with UDF
Consider a topic of stock price events that you want to calculate the volume-weighted average price (VWAP) for each event, publishing the result to a new topic.
There is no built-in function for VWAP, so we'll write a custom ksqlDB UDF that performs the calculation.
see [official tutorial](https://kafka-tutorials.confluent.io/udf/ksql.html?_ga=2.223343775.583678155.1587977444-275217082.1587977444)

In our workshop the UDF is already prepared for you and linked into ksqlDB. Please see the tutorial description and check proceedings.
Start this lab:
```bash
docker exec -it workshop-ksqldb-cli ksql http://ksqldb-server:8088
ksql> SHOW FUNCTIONS;
ksql> DESCRIBE FUNCTION VWAP;
ksql> CREATE STREAM raw_quotes(ticker varchar key, bid int, ask int, bidqty int, askqty int)
    WITH (kafka_topic='stockquotes', value_format='avro', partitions=1);
ksql> INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZTEST', 15, 25, 100, 100);
INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZVV',   25, 35, 100, 100);
INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZVZZT', 35, 45, 100, 100);
INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZXZZT', 45, 55, 100, 100);
INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZTEST', 10, 20, 50, 100);
INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZVV',   30, 40, 100, 50);
INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZVZZT', 30, 40, 50, 100);
INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZXZZT', 50, 60, 100, 50);
INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZTEST', 15, 20, 100, 100);
INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZVV',   25, 35, 100, 100);
INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZVZZT', 35, 45, 100, 100);
INSERT INTO raw_quotes (ticker, bid, ask, bidqty, askqty) VALUES ('ZXZZT', 45, 55, 100, 100);
ksql> SET 'auto.offset.reset' = 'earliest';
ksql> SELECT * FROM raw_quotes EMIT CHANGES LIMIT 12;
ksql> SELECT ticker, vwap(bid, bidqty, ask, askqty) AS vwap FROM raw_quotes EMIT CHANGES LIMIT 12;
ksql> CREATE STREAM vwap WITH (kafka_topic = 'vwap', partitions = 1) AS
    SELECT ticker,
           vwap(bid, bidqty, ask, askqty) AS vwap
    FROM raw_quotes
    EMIT CHANGES;
ksql> PRINT 'vwap' FROM BEGINNING LIMIT 12;
ksql> exit;
```

End of Lab 2

[go back to Agenda](https://github.com/ora0600/confluent-ksqldb-hands-on-workshop/blob/master/README.md#hands-on-agenda-and-labs)
