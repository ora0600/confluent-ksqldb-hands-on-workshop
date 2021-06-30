# Scale KSQLDB (Confluent Cloud steps)
Scaling in Confluent Cloud is little bit different.
Here we run so called CSU (Confluent Streaming units) with a ksqlDB cluster of 4 CSUs or 8 CSUs or 12 CSUs.
ksqlDB Apps with more than 4 CSUs are configured for HA automatically.
Additional you can have max 3 ksqlDB Apps per cluster.

You can not scale a 4 CSU ksqlDB App to 8 CSU. This is not possible. Instead provision a new ksqlDB App and migrate ksqldb scripts to the new app.

## Definition
* Application - A CCloud ksqlDB cluster, an isolated group of nodes working together to run a ksqlDB workload.
* CSU - Confluent Streaming Unit, the pricing/capacity unit for CCloud ksqlDB. Users pay for however many CSUs they have provisioned, regardless of application throughput and/or hardware resource utilization.

## ksqDB Editor in Confluent Cloud
But let us check what is the difference of a 4 CSU ksqlDB App and a 8 ksqlDB App
```bash
ksql> show properties;
# Output:
{
  "@type": "properties",
  "statementText": "show properties;",
  "properties": [
    ...
```
With a 4 CSU ksqlDB App you have a limit of 20 persistant queries and no HA setup.
You can also check cluster status of your ksqlDB App. For this do the following:
```bash
# Get Data from kslqwDB App
ccloud ksql app describe KSDQLDB-ID
+--------------+-----------------------------------------------------------+
| Id           | KSDQLDB-ID                                               |
| Name         | ksqlDB_app_0                                              |
| Topic Prefix | pksqlc-5wydg                                              |
| Kafka        | CLUSTERID                                                 |
| Storage      |                                                       500 |
| Endpoint     | https://ksqlDB.APP.gcp.confluent.cloud:443                |
| Status       | UP                                                        |
+--------------+-----------------------------------------------------------+
# create first API keys for your ksqlDB Cluster:
ccloud api-key create --resource KSQLDB-APP-ID
+---------+------------------------------------------------------------------+
| API Key | KEY                                                              |
| Secret  | SECRET                                                           |
+---------+------------------------------------------------------------------+
# Call cluster Status with endpoint of ksqlDB App :
curl --http1.1 -sX GET -u KEY:SECRET \
 "https://ksqlDB.APP.gcp.confluent.cloud:443/clusterStatus" | jq '.'
```
Please compare the out put later with the new 8 CSU cluster.

Now, create a new ksqlDB APP WITH 8 CSU (OPTIONALLY) and run the same command:
```bash
ksql> show properties;
# Output
{
  "@type": "properties",
  "statementText": "show properties;",
  "properties": ...
```
With a 8 CSU ksqlDB App you have still a limit of 20 persistant queries and HA is enabled.
The difference is:
* 8 CSU with standby replicas: ksql.streams.num.standby.replicas = 1
* 8 CSU can handle ~double throughput of 4 CSU ksqlDB Apps
* (12 CSU would serve tripple throughput of 4 CSU )

Run a cluster Status and compare output with 4 CSU cluster
```bash
# Get Data from kslqwDB App
ccloud ksql app describe KSDQLDB2-ID
+--------------+-----------------------------------------------------------+
| Id           | KSDQLDB2-ID                                               |
| Name         | ksqlDB2_app_0                                              |
| Topic Prefix | pksqlc-5wydg                                              |
| Kafka        | CLUSTERID                                                 |
| Storage      |                                                       500 |
| Endpoint     | https://ksqlDB.APP2.gcp.confluent.cloud:443                |
| Status       | UP                                                        |
+--------------+-----------------------------------------------------------+
# create first API keys for your ksqlDB Cluster:
ccloud api-key create --resource KSQLDB2-APP-ID
+---------+------------------------------------------------------------------+
| API Key | KEY                                                              |
| Secret  | SECRET                                                           |
+---------+------------------------------------------------------------------+
# Call cluster Status with endpoint of ksqlDB App :
curl --http1.1 -sX GET -u KEY:SECRET \
 "https://ksqlDB.APP2.gcp.confluent.cloud:443/clusterStatus" | jq '.'
```

## Sizing guideline
Based on your setup, please monitor persistent queries. You do that by switching to consumer monitoroning and watch consumer lag, this is main driver to activate sclaing.

Please have a look [how to scale](https://docs.ksqldb.io/en/latest/operate-and-deploy/capacity-planning/#scaling-ksqldb)

End lab10

[go back to Agenda](https://github.com/ora0600/confluent-ksqldb-hands-on-workshop/blob/master/README.md#hands-on-agenda-and-labs)

