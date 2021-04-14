# Financial services use case: Transaction cache
In this lab we will create a transaction case. A typical activity on a bankaccount for a specific period.
If not prepared already in setup, please create topic and load data:
```bash
docker exec -it workshop-kafka  kafka-topics --create --topic transactions --bootstrap-server localhost:9092
# produce data transactions
docker exec -it workshop-kafka bash -c 'cat /produce-data/transactions.json | kafka-console-producer --topic transactions --broker-list localhost:9092  --property "parse.key=true" --property "key.separator=:"'
# or better you change the current shipment date and period to today and produce single records (today is 8.12.2020 choose your own today)
docker exec -it workshop-kafka bash -c 'kafka-console-producer --topic transactions --broker-list localhost:9092  --property "parse.key=true" --property "key.separator=:"'
# and copy
"abcd00003":{"shipment_ts":"2021-02-22T12:13:39Z", "IBAN": "abcd00003","MOVEMENT_TYPE": "DEPOSITS","ACCOUNT_NUMBER": "A1","BANK_CODE": "14000","BOOKING_TEXT": "A1-14000","AMOUNT": 210.0,"CURRENCY": "EUR","PERIOD": "2021-02"}
"abcd00003":{"shipment_ts":"2021-02-22T12:13:39Z", "IBAN": "abcd00003","MOVEMENT_TYPE": "DEPOSITS","ACCOUNT_NUMBER": "A1","BANK_CODE": "14000","BOOKING_TEXT": "A1-14000","AMOUNT": 10.0,"CURRENCY": "EUR","PERIOD": "2021-02"}
"abcd00003":{"shipment_ts":"2021-02-22T12:13:39Z", "IBAN": "abcd00003","MOVEMENT_TYPE": "DEPOSITS","ACCOUNT_NUMBER": "A1","BANK_CODE": "14000","BOOKING_TEXT": "A1-14000","AMOUNT": 12.0,"CURRENCY": "EUR","PERIOD": "2021-02"}
"abcd00004":{"shipment_ts":"2021-02-22T12:13:39Z", "IBAN": "abcd00004","MOVEMENT_TYPE": "DEPOSITS","ACCOUNT_NUMBER": "A2","BANK_CODE": "14000","BOOKING_TEXT": "A2-14000","AMOUNT": 14.0,"CURRENCY": "EUR","PERIOD": "2021-02"}
```
Create the Stream:
```bash
docker exec -it workshop-ksqldb-cli ksql http://ksqldb-server:8088
ksql> print 'transactions' from beginning;
ksq> CREATE STREAM TRANSACTIONS_STREAM (IBAN VARCHAR KEY, SHIPMENT_TS VARCHAR, MOVEMENT_TYPE VARCHAR, ACCOUNT_NUMBER VARCHAR, BANK_CODE VARCHAR,
  BOOKING_TEXT VARCHAR, AMOUNT DOUBLE, CURRENCY VARCHAR, `PERIOD` VARCHAR )
WITH (
  TIMESTAMP='SHIPMENT_TS',
  TIMESTAMP_FORMAT='yyyy-MM-dd''T''HH:mm:ssX',
  KAFKA_TOPIC='transactions',
  VALUE_FORMAT='JSON');
ksql> SET 'auto.offset.reset' = 'earliest';
ksql> describe TRANSACTIONS_STREAM;
ksql> select * from TRANSACTIONS_STREAM emit changes;
```
build the cache with an aggregate function:
```bash
ksql> CREATE TABLE TRANSACTIONS_CACHE_TABLE AS
  SELECT
    IBAN,
    `PERIOD`,
    COLLECT_LIST('{ "DATE": ' + SHIPMENT_TS + 
                 ', "IBAN": "' + IBAN + 
                 '", "MOVEMENT_TYPE": "' + MOVEMENT_TYPE + 
                 '", "ACCOUNT_NUMBER": "' + ACCOUNT_NUMBER + 
                 '", "BANK_CODE": "' + BANK_CODE + 
                 '", "BOOKING_TEXT": "' + BOOKING_TEXT + 
                 '", "AMOUNT": ' + CAST(AMOUNT AS VARCHAR) + 
                 ', "CURRENCY": "' + CURRENCY + 
                 '", "PERIOD": "' + `PERIOD` + '"}') AS TRANSACTION_PAYLOAD
  FROM TRANSACTIONS_STREAM
    WINDOW TUMBLING (SIZE 30 DAYS)
  GROUP BY IBAN, `PERIOD`
  EMIT CHANGES;
ksql> describe TRANSACTIONS_CACHE_TABLE;
```
Ask for what is happening in the last period in an bank account:  
```bash
  ksql> select * from TRANSACTIONS_CACHE_TABLE emit changes;
  ksql> SELECT TRANSACTION_PAYLOAD FROM TRANSACTIONS_CACHE_TABLE WHERE KSQL_COL_0='"abcd00003"|+|2021-02';
  ksql> output json;
  ksql> SELECT TRANSACTION_PAYLOAD FROM TRANSACTIONS_CACHE_TABLE WHERE KSQL_COL_0='"abcd00003"|+|2021-02';
  ksql> spool data.json;
  ksql> SELECT TRANSACTION_PAYLOAD FROM TRANSACTIONS_CACHE_TABLE WHERE KSQL_COL_0='"abcd00004"|+|2021-02';
  ksql> spool off;
  ksql> exit;
  docker exec -it workshop-ksqldb-cli cat /home/appuser/data.json
```

End lab 4

[go back to Agenda](https://github.com/ora0600/confluent-ksqldb-hands-on-workshop/blob/master/README.md#hands-on-agenda-and-labs)
