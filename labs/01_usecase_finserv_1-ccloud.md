# Finacial services case: Payment Status check (need to be rewrite for Confluent Cloud)

We are going to build data pipeline which should look like this:
![Financial Services Use cases as flow](img/Financial_datapipe.png)

1. Login to Confluent Cloud ksqlDB APP of your cluster and edit in ksqlDB Editor
```bash
ksql> show topics;
ksql> show streams;
```
Check the properties set for ksqlDB.
```bash
ksql> show properties;
```
2. Create Streams and convert it automatically to AVRO.
```bash
ksql> create stream payments(PAYMENT_ID INTEGER KEY, CUSTID INTEGER, ACCOUNTID INTEGER, AMOUNT INTEGER, BANK VARCHAR) with(kafka_topic='Payment_Instruction', value_format='json');
```
Check your creation with describe and select. You can also use Confluent Control Center for this inspection.
```bash
ksql> describe payments;
```
Create the other streams
```bash
ksql> create stream aml_status(PAYMENT_ID INTEGER, BANK VARCHAR, STATUS VARCHAR) with(kafka_topic='AML_Status', value_format='json');
ksql> create stream funds_status (PAYMENT_ID INTEGER, REASON_CODE VARCHAR, STATUS VARCHAR) with(kafka_topic='Funds_Status', value_format='json');
ksql> list streams;
ksql> CREATE TABLE customers (
          ID INTEGER PRIMARY KEY, 
          FIRST_NAME VARCHAR, 
          LAST_NAME VARCHAR, 
          EMAIL VARCHAR, 
          GENDER VARCHAR, 
          STATUS360 VARCHAR) 
          WITH(kafka_topic='CUSTOMERS_FLAT', value_format='JSON');
ksql> list tables;        
```
3. Load Data:
go to ksqlDB Editor and copy and paste data
```bash
# customer data
ksql> INSERT INTO customers (id, FIRST_NAME, LAST_NAME, EMAIL, GENDER, STATUS360) values (20,'Anselma','Rook','arookj@europa.eu','Female','gold');
INSERT INTO customers (id, FIRST_NAME, LAST_NAME, EMAIL, GENDER, STATUS360) values (19,'Josiah','Brockett','jbrocketti@com.com','Male','gold');
INSERT INTO customers (id, FIRST_NAME, LAST_NAME, EMAIL, GENDER, STATUS360) values (18,'Waldon','Keddey','wkeddeyh@weather.com','Male','gold');
INSERT INTO customers (id, FIRST_NAME, LAST_NAME, EMAIL, GENDER, STATUS360) values (17,'Brianna','Paradise','bparadiseg@nifty.com','Female','bronze');
INSERT INTO customers (id, FIRST_NAME, LAST_NAME, EMAIL, GENDER, STATUS360) values (16,'Clair','Vardy','cvardyf@reverbnation.com','Male','bronze');
INSERT INTO customers (id, FIRST_NAME, LAST_NAME, EMAIL, GENDER, STATUS360) values (15,'Rodrique','Silverton','rsilvertone@umn.edu','Male','gold');
INSERT INTO customers (id, FIRST_NAME, LAST_NAME, EMAIL, GENDER, STATUS360) values (14,'Isabelita','Talboy','italboyd@imageshack.us','Female','gold');
INSERT INTO customers (id, FIRST_NAME, LAST_NAME, EMAIL, GENDER, STATUS360) values (13,'Laney','Toopin','ltoopinc@icio.us','Female','platinum');
ksql> INSERT INTO customers (id, FIRST_NAME, LAST_NAME, EMAIL, GENDER, STATUS360) values (12,'Sheryl','Hackwell','shackwellb@paginegialle.it','Female','gold');
INSERT INTO customers (id, FIRST_NAME, LAST_NAME, EMAIL, GENDER, STATUS360) values (11,'Alexandro','Peeke-Vout','apeekevouta@freewebs.com','Male','gold');
INSERT INTO customers (id, FIRST_NAME, LAST_NAME, EMAIL, GENDER, STATUS360) values (10,'Brena','Tollerton','btollerton9@furl.net','Female','silver');
INSERT INTO customers (id, FIRST_NAME, LAST_NAME, EMAIL, GENDER, STATUS360) values (9,'Even','Tinham','etinham8@facebook.com','Male','silver');
INSERT INTO customers (id, FIRST_NAME, LAST_NAME, EMAIL, GENDER, STATUS360) values (8,'Patti','Rosten','prosten7@ihg.com','Female','silver');
INSERT INTO customers (id, FIRST_NAME, LAST_NAME, EMAIL, GENDER, STATUS360) values (7,'Fay','Huc','fhuc6@quantcast.com','Female','bronze');
INSERT INTO customers (id, FIRST_NAME, LAST_NAME, EMAIL, GENDER, STATUS360) values (6,'Robinet','Leheude','rleheude5@reddit.com','Female','platinum');
INSERT INTO customers (id, FIRST_NAME, LAST_NAME, EMAIL, GENDER, STATUS360) values (5,'Hansiain','Coda','hcoda4@senate.gov','Male','platinum');
INSERT INTO customers (id, FIRST_NAME, LAST_NAME, EMAIL, GENDER, STATUS360) values (4,'Hashim','Rumke','hrumke3@sohu.com','Male','platinum');
INSERT INTO customers (id, FIRST_NAME, LAST_NAME, EMAIL, GENDER, STATUS360) values (3,'Mariejeanne','Cocci','mcocci2@techcrunch.com','Female','bronze');
INSERT INTO customers (id, FIRST_NAME, LAST_NAME, EMAIL, GENDER, STATUS360) values (2,'Ruthie','Brockherst','rbrockherst1@ow.ly','Female','platinum');
INSERT INTO customers (id, FIRST_NAME, LAST_NAME, EMAIL, GENDER, STATUS360) values (1,'Rica','Blaisdell','rblaisdell0@rambler.ru','Female','bronze');
ksql> select * from customers emit changes;
# payment_instructions
ksql> insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (1,1,1234000,100,'DBS');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (3,2,1234100,200,'Barclays Bank');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (5,3,1234200,300,'BNP Paribas');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (7,4,1234300,400,'Wells Fargo');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (9,5,1234400,500,'DBS');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (11,6,1234500,600,'Royal Bank of Canada');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (13,7,1234600,700,'DBS');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (15,8,1234700,800,'DBS');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (17,9,1234800,900,'DBS');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (19,10,1234900,1000,'United Overseas Bank');
ksql> insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (21,11,1234000,1100,'Royal Bank of Canada');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (23,12,1234100,1200,'BNP Paribas');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (25,13,1234200,1300,'Wells Fargo');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (27,14,1234300,1400,'Commonwealth Bank of Australia');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (29,15,1234400,1500,'DBS');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (31,16,1234500,1600,'Commonwealth Bank of Australia');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (33,17,1234600,1700,'Royal Bank of Canada');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (35,18,1234700,1800,'DBS');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (37,19,1234800,1900,'Royal Bank of Canada');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (39,20,1234900,2000,'Barclays Bank');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (41,21,1234000,2100,'Citi');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (43,22,1234100,2200,'Barclays Bank');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (45,23,1234200,2300,'Citi');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (47,24,1234300,2400,'Deutsche Bank');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (49,1,1234400,2500,'Deutsche Bank');
insert into payments (PAYMENT_ID, CUSTID, ACCOUNTID, AMOUNT, BANK) values (51,2,1234500,2600,'Royal Bank of Canada');
ksql> select * from payments emit changes;
# aml_status
ksql> insert into aml_status(PAYMENT_ID,BANK,STATUS) values (1,'Wells Fargo','OK');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (3,'Commonwealth Bank of Australia','OK');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (5,'Deutsche Bank','OK');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (7,'DBS','OK');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (9,'United Overseas Bank','OK');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (11,'Citi','OK');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (13,'Commonwealth Bank of Australia','OK');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (15,'Barclays Bank','OK');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (17,'United Overseas Bank','OK');
ksql> insert into aml_status(PAYMENT_ID,BANK,STATUS) values (19,'Royal Bank of Canada','OK');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (21,'Commonwealth Bank of Australia','OK');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (23,'Deutsche Bank','OK');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (25,'DBS','OK');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (27,'Wells Fargo','OK');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (29,'Wells Fargo','OK');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (31,'Barclays Bank','OK');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (33,'Bank of Spain','FAIL');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (35,'Citi','OK');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (37,'Royal Bank of Canada','OK');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (39,'United Overseas Bank','OK');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (41,'Royal Bank of Canada','OK');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (43,'Barclays Bank','OK');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (45,'DBS','FAIL');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (47,'DBS','OK');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (49,'Citi','OK');
insert into aml_status(PAYMENT_ID,BANK,STATUS) values (51,'Barclays Bank','FAIL');
ksql> select * from aml_status emit changes;
# funds_status
ksql> insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (1,'00','OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (3,'99','OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (5,'30','OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (7,'00','OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (9,'00','OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (11,'00','NOT OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (13,'30','OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (15,'00','OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (17,'10','OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (19,'10','OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (21,'30','OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (23,'10','OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (25,'99','OK');
ksql> insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (27,'10','OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (29,'20','NOT OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (31,'99','OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (33,'00','OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (35,'20','OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (37,'00','OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (39,'20','OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (41,'30','OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (43,'00','OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (45,'99','OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (47,'10','OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (49,'10','OK');
insert into funds_status(PAYMENT_ID,REASON_CODE,STATUS) values (51,'10','NOT OK');
ksql> select * from funds_status emit changes;
```
4. Play with data
Select new table with push query:
```bash
ksql> set 'auto.offset.reset'='earliest';
ksql> select * from payments emit changes;
ksql> select * from customers emit changes;
ksql> select * from customers where id=1 emit changes;
ksql> exit;
```
5. Enriching Payments with Customer details
```bash
ksql> create stream enriched_payments as select
p.payment_id as payment_id,
p.custid as customer_id,
p.accountid,
p.amount,
p.bank,
c.first_name,
c.last_name,
c.email,
c.status360
from payments p left join customers c on p.custid = c.id;
ksql> describe ENRICHED_PAYMENTS;
ksql> select * from enriched_payments emit changes;
```
Now check in Confluent Cloud UI:
1) check in ksqlDB APP - the running queries. Take a look in the details (SINK: and SOURCE:) of the running queries.
2) check in ksqlDB APP the flow to follow the expansion easier. If it is not visible refresh the webpage in browser.

6. Combining the status streams
```bash
ksql> CREATE STREAM payment_statuses AS SELECT payment_id, status, 'AML' as source_system FROM aml_status;
ksql> INSERT INTO payment_statuses SELECT payment_id, status, 'FUNDS' as source_system FROM funds_status;
ksql> describe payment_statuses;
ksql> set 'auto.offset.reset'='latest';
ksql> select * from payment_statuses emit changes;
```
Combine payment and status events in 1 hour window. Why we need a timing window for stream-stream join?
```bash
ksql> CREATE STREAM payments_with_status AS SELECT
  ep.payment_id as payment_id,
  ep.accountid,
  ep.amount,
  ep.bank,
  ep.first_name,
  ep.last_name,
  ep.email,
  ep.status360,
  ps.status,
  ps.source_system
  FROM enriched_payments ep LEFT JOIN payment_statuses ps WITHIN 1 HOUR ON ep.payment_id = ps.payment_id ;
ksql> describe payments_with_status;
ksql> select * from payments_with_status emit changes;
ksql> select * from payments_with_status emit changes limit 10;
```
7. Check in the ksqldb area the ksqldb flow to follow the expansion easier

Aggregate into consolidated records
```bash
ksql> CREATE TABLE payments_final AS SELECT
  payment_id,
  histogram(status) as status_counts,
  collect_list('{ "system" : "' + source_system + '", "status" : "' + STATUS + '"}') as service_status_list
  from payments_with_status
  where status is not null
  group by payment_id;
ksql> describe PAYMENTS_FINAL ;
ksql> select * from payments_final emit changes limit 1;
```
Pull queries, check value for a specific payment (snapshot lookup). Pull Query is a Preview feature.
```bash
ksql> set 'auto.offset.reset'='earliest';
ksql> select * from payments_final where payment_id=1;
ksql> exit;
```

8. Query by REST Call
Get the REST Endpoint from `ccloud ksql app list` and execute query with your credentials copies from properties File
```bash
curl -X "POST" "https://yourserver.europe-west1.gcp.confluent.cloud:443/query" \
     -u KEY:SECRET \
     -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
     -d $'{"ksql": "select * from payments_final where payment_id=1;","streamsProperties": {}}' | jq
```
list streams via curl
```bash
curl -X "POST" "https://yourserver.europe-west1.gcp.confluent.cloud:443/ksql" \
     -u KEY:SECRET \
     -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
     -d $'{"ksql": "LIST STREAMS;","streamsProperties": {}}' | jq        
```

END Lab 1 

Final table with payment statuses
![Financial Services Final Result](img/payments_final_status.png)


[go back to Agenda](https://github.com/ora0600/confluent-ksqldb-hands-on-workshop/blob/master/README.md#hands-on-agenda-and-labs)
