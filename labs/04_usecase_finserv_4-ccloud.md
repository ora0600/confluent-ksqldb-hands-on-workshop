# Financial services use case: Transaction cache (steps for Confluent Cloud)

In this lab we will create a transaction case. A typical activity on a bankaccount for a specific period.


## Create a stream
In the Confluent Cloud environment, the required topic is already created.
Now, create a stream on the topic and load some demo data in the ksqlDB Editor.

```bash
ksql> CREATE STREAM TRANSACTIONS_STREAM (IBAN VARCHAR KEY, SHIPMENT_TS VARCHAR, MOVEMENT_TYPE VARCHAR, ACCOUNT_NUMBER VARCHAR, BANK_CODE VARCHAR,
  BOOKING_TEXT VARCHAR, AMOUNT DOUBLE, CURRENCY VARCHAR, `PERIOD` VARCHAR )
WITH (
  TIMESTAMP='SHIPMENT_TS',
  TIMESTAMP_FORMAT='yyyy-MM-dd''T''HH:mm:ssX',
  KAFKA_TOPIC='transactions',
  VALUE_FORMAT='JSON');
```

### Option 1: Connect with CLI
#### Set up API-Keys

Use the `ccloud` cli to connect to your cluster. First make sure to set your environment:

`ccloud environment use <environment-id>`

and select the appropriate cluster with the information you were given:

`ccloud kafka cluster use <cluster-id>`

Store your API key with

`ccloud api-key use <API_KEY> --resource <cluster-id>`

and fill in the required fields you were given.


#### Produce to Topic

You may then use 

```bash
ccloud kafka topic produce transactions --parse-key --delimiter ":"
``` 

to produce to the `transactions` topic to create the data with the following:

```bash
"abcd00003":{"shipment_ts":"2021-05-06T09:13:39Z", "IBAN": "abcd00003","MOVEMENT_TYPE": "DEPOSITS","ACCOUNT_NUMBER": "A1","BANK_CODE": "14000","BOOKING_TEXT": "A1-14000","AMOUNT": 210.0,"CURRENCY": "EUR","PERIOD": "2021-05"}
"abcd00003":{"shipment_ts":"2021-05-06T09:13:39Z", "IBAN": "abcd00003","MOVEMENT_TYPE": "DEPOSITS","ACCOUNT_NUMBER": "A1","BANK_CODE": "14000","BOOKING_TEXT": "A1-14000","AMOUNT": 10.0,"CURRENCY": "EUR","PERIOD": "2021-05"}
"abcd00003":{"shipment_ts":"2021-05-06T09:13:39Z", "IBAN": "abcd00003","MOVEMENT_TYPE": "DEPOSITS","ACCOUNT_NUMBER": "A1","BANK_CODE": "14000","BOOKING_TEXT": "A1-14000","AMOUNT": 12.0,"CURRENCY": "EUR","PERIOD": "2021-05"}
"abcd00004":{"shipment_ts":"2021-05-06T09:13:39Z", "IBAN": "abcd00004","MOVEMENT_TYPE": "DEPOSITS","ACCOUNT_NUMBER": "A2","BANK_CODE": "14000","BOOKING_TEXT": "A2-14000","AMOUNT": 14.0,"CURRENCY": "EUR","PERIOD": "2021-05"}
```

### Option 2: Inserting the Data

If you don't feel comfortable producing to the topic, you may also insert the data through ksqlDB:

```bash
insert into transactions_stream (IBAN, SHIPMENT_TS, MOVEMENT_TYPE, ACCOUNT_NUMBER, BANK_CODE, BOOKING_TEXT, AMOUNT, CURRENCY, `PERIOD`) values ('abcd00003', '2021-05-06T09:13:39Z', 'DEPOSITS', 'A1', '14000', 'A1-14000', 210.0, 'EUR', '2021-05');
insert into transactions_stream (IBAN, SHIPMENT_TS, MOVEMENT_TYPE, ACCOUNT_NUMBER, BANK_CODE, BOOKING_TEXT, AMOUNT, CURRENCY, `PERIOD`) values ('abcd00003', '2021-05-06T09:13:39Z', 'DEPOSITS', 'A1', '14000', 'A1-14000', 10.0, 'EUR', '2021-05');
insert into transactions_stream (IBAN, SHIPMENT_TS, MOVEMENT_TYPE, ACCOUNT_NUMBER, BANK_CODE, BOOKING_TEXT, AMOUNT, CURRENCY, `PERIOD`) values ('abcd00003', '2021-05-06T09:13:39Z', 'DEPOSITS', 'A1', '14000', 'A1-14000', 12.0, 'EUR', '2021-05');
insert into transactions_stream (IBAN, SHIPMENT_TS, MOVEMENT_TYPE, ACCOUNT_NUMBER, BANK_CODE, BOOKING_TEXT, AMOUNT, CURRENCY, `PERIOD`) values ('abcd00004', '2021-05-06T09:13:39Z', 'DEPOSITS', 'A2', '14000', 'A2-14000', 14.0, 'EUR', '2021-05');
```


## Check topic and stream data

```bash
ksql> print 'transactions' from beginning;
ksql> SET 'auto.offset.reset' = 'earliest';
ksql> describe TRANSACTIONS_STREAM;
ksql> select * from TRANSACTIONS_STREAM emit changes;
```

## Build the cache with an aggregate function:
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
  ksql> SELECT TRANSACTION_PAYLOAD FROM TRANSACTIONS_CACHE_TABLE WHERE KSQL_COL_0='"abcd00003"|+|2021-05';
  ksql> output json;
  ksql> SELECT TRANSACTION_PAYLOAD FROM TRANSACTIONS_CACHE_TABLE WHERE KSQL_COL_0='"abcd00003"|+|2021-05';
  ksql> exit;
```

End lab 4

[go back to Agenda](https://github.com/ora0600/confluent-ksqldb-hands-on-workshop/blob/master/README.md#hands-on-agenda-and-labs)
