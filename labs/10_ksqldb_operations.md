# Scale KSQLDB
First of all we add a new KSQLDB Name in our Control Center setup, but this is not scaling:
## Control Center
```bash
docker-compose down -v
vi docker-compose.yml
  # add under control-center in environment
      CONTROL_CENTER_KSQL_KALLE_ADVERTISED_URL: "http://localhost:8088"
      CONTROL_CENTER_KSQL_KALLE_URL: "http://ksqldb-server:8088"
docker-compose up -d
```
Check Control Center. A new KSQLDB App is visible but it shares the same ksqlDB Server. Now, we create a new KSQLDB Cluster for real scaling. In general this is a recommended way, to have for each use case own ksqldb cluster.

```bash
docker-compose down -v
vi docker-compose.yml
# add new cluster
  ksqldb-server1:
    image: confluentinc/cp-ksqldb-server:6.1.0
    container_name: workshop-ksqldb-server1
    depends_on:
      - kafka
      - schema-registry
    volumes:
      - ./extensions:/etc/ksqldb/ext
    cpus: 1.0
    ports:
      - 8089:8089
    environment:
      KSQL_CONFIG_DIR: "/etc/ksqldb"
      KSQL_KSQL_EXTENSION_DIR: "/etc/ksqldb/ext/"
      KSQL_CUB_KAFKA_TIMEOUT: 120
      KSQL_BOOTSTRAP_SERVERS: kafka:29092
      KSQL_LISTENERS: http://0.0.0.0:8089
      KSQL_KSQL_SCHEMA_REGISTRY_URL: http://schema-registry:8081
      KSQL_KSQL_SERVICE_ID: kalle_
      KSQL_KSQL_CONNECT_URL: http://connect-ext:8083
      # uncomment this one to launch a Connect worker INSIDE the KSQL JVM
      # KSQL_KSQL_CONNECT_WORKER_CONFIG: /etc/ksql/worker.properties
      KSQL_KSQL_LOGGING_PROCESSING_TOPIC_AUTO_CREATE: "true"
      KSQL_KSQL_LOGGING_PROCESSING_STREAM_AUTO_CREATE: "true"
      KSQL_KSQL_LOGGING_PROCESSING_TOPIC_PARTITIONS: 2
      KSQL_KSQL_LOGGING_PROCESSING_TOPIC_REPLICATION_FACTOR: 1
      KSQL_PRODUCER_INTERCEPTOR_CLASSES: "io.confluent.monitoring.clients.interceptor.MonitoringProducerInterceptor"
      KSQL_CONSUMER_INTERCEPTOR_CLASSES: "io.confluent.monitoring.clients.interceptor.MonitoringConsumerInterceptor"
      KSQL_KSQL_COMMIT_INTERVAL_MS: 2000
      KSQL_KSQL_CACHE_MAX_BYTES_BUFFERING: 10000000
    healthcheck:
      disable: true 
 ```     
 Also change control-center setup to add new ksqldb cluster:
 ```bash 
 vi docker-compose.yml
control-center:
    image: confluentinc/cp-enterprise-control-center:6.1.0
    hostname: control-center
    container_name: workshop-control-center
    depends_on:
      - zookeeper
      - kafka
      - schema-registry
      - connect-ext
      - ksqldb-server
      - ksqldb-server1
    cpus: 0.8
    ports:
      - "9021:9021"
    environment:
      CONTROL_CENTER_BOOTSTRAP_SERVERS: 'kafka:29092'
      CONTROL_CENTER_ZOOKEEPER_CONNECT: 'zookeeper:2181'
      CONTROL_CENTER_CONNECT_WORKSHOP_CLUSTER: 'http://connect-ext:8083'
      CONTROL_CENTER_KSQL_WORKSHOP_URL: "http://ksqldb-server:8088"
      CONTROL_CENTER_KSQL_WORKSHOP_ADVERTISED_URL: http://ksqldb-server:8088
      CONTROL_CENTER_KSQL_NEWKSQLDB_URL: "http://ksqldb-server1:8089"
      CONTROL_CENTER_KSQL_NEWKSQLDB_ADVERTISED_URL: http://ksqldb-server1:8089
      CONTROL_CENTER_SCHEMA_REGISTRY_URL: "http://schema-registry:8081"
      CONTROL_CENTER_REPLICATION_FACTOR: 1
      CONTROL_CENTER_INTERNAL_TOPICS_PARTITIONS: 1
      CONTROL_CENTER_INTERNAL_TOPICS_REPLICATION: 1
      CONTROL_CENTER_MONITORING_INTERCEPTOR_TOPIC_PARTITIONS: 1
      CONTROL_CENTER_MONITORING_INTERCEPTOR_TOPIC_REPLICATION: 1
      CONTROL_CENTER_METRICS_TOPIC_PARTITIONS: 1
      CONTROL_CENTER_METRICS_TOPIC_REPLICATION: 1
      CONTROL_CENTER_COMMAND_TOPIC_REPLICATION: 1
      CONFLUENT_METRICS_TOPIC_REPLICATION: 1
      CONTROL_CENTER_STREAMS_NUM_STREAM_THREADS: 2
      CONTROL_CENTER_STREAMS_CACHE_MAX_BYTES_BUFFERING: 104857600
      CONTROL_CENTER_DEPRECATED_VIEWS_ENABLE: "true"
      CONTROL_CENTER_LOG4J_ROOT_LOGLEVEL: WARN
      CONTROL_CENTER_REST_LISTENERS: "http://0.0.0.0:9021"
      PORT: 9021
````
Now start docker again and you will see the new cluster in control-center:
```bash
docker-compose up -d
# connect to cluster via cli
# new
docker exec -it workshop-ksqldb-cli ksql http://ksqldb-server1:8089
# old
docker exec -it workshop-ksqldb-cli ksql http://ksqldb-server:8088
```
Now, we run two real ksqldb cluster. Again this is the recommended way to on-boarding your use case on a dedicated ksqdb cluster. One use case per ksqldb cluster.

Please have a look [how to scale](https://docs.ksqldb.io/en/latest/operate-and-deploy/capacity-planning/#scaling-ksqldb)

## run new docker-compose file
We want to create two ksqlDB clusters:
* cluster 1 is for the user case 1
* cluster 2 is for the use case 2, which uses topics with 2 partitions that why we distribute cluster on two nodes.

![cluster setup](img/ksqldb_cluster.png)

End lab10

[go back to Agenda](https://github.com/ora0600/confluent-ksqldb-hands-on-workshop/blob/master/README.md#hands-on-agenda-and-labs)

