# Financial services use case: Transaction cache (steps for Confluent Cloud)

In this lab we will create a transaction case. A typical activity on a bankaccount for a specific period.

## Create a stream
In the Confluent Cloud environment, the required topic is already created.
Now, create a stream on the topic and load some demo data in the ksqlDB Editor.

```bash
ksq> CREATE STREAM TRANSACTIONS_STREAM (IBAN VARCHAR KEY, SHIPMENT_TS VARCHAR, MOVEMENT_TYPE VARCHAR, ACCOUNT_NUMBER VARCHAR, BANK_CODE VARCHAR,
  BOOKING_TEXT VARCHAR, AMOUNT DOUBLE, CURRENCY VARCHAR, `PERIOD` VARCHAR )
WITH (
  TIMESTAMP='SHIPMENT_TS',
  TIMESTAMP_FORMAT='yyyy-MM-dd''T''HH:mm:ssX',
  KAFKA_TOPIC='transactions',
  VALUE_FORMAT='JSON');
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
  ksql> SELECT TRANSACTION_PAYLOAD FROM TRANSACTIONS_CACHE_TABLE WHERE KSQL_COL_0='"abcd00003"|+|2021-02';
  ksql> output json;
  ksql> SELECT TRANSACTION_PAYLOAD FROM TRANSACTIONS_CACHE_TABLE WHERE KSQL_COL_0='"abcd00003"|+|2021-02';
  ksql> exit;
```

End lab 4

[go back to Agenda](https://github.com/ora0600/confluent-ksqldb-hands-on-workshop/blob/master/README.md#hands-on-agenda-and-labs)
