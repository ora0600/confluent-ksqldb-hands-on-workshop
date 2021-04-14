# Create Confluent Cloud clusters

This script create cluster with ksqlDB Apps based on the attendees.txt file. Each entry will get an entry.
## Prerequisites

* Confluent Cloud Org
* ccloud cli installed

## Getting Started
Create for each attendee in `attendes.txt` a cluster in Confluent Cloud. Max 20 clusters can be created.
```
cd ccloud
./00_create_ccloudclusters.sh
```

Destroy the confluent cloud environment including all clusters:
```bash
cd ccloud
./02_drop_ccloudcluster.sh
```