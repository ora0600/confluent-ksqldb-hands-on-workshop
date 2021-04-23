# Set up the environment Confluent Cloud for ksqlDB Hands-on Workshop

The Confluent Cloud environment is prepared for you. You got the access credentials via Email.
If you choose your own Confluent Cloud account please follow the steps from you [here](../ccloud/README.md) to run the setup by script.
If you would like to create everything manually execute the following steps:
* create cluster in GUI or via ccloud cli in a choosen environment `ccloud kafka cluster create NAME --cloud aws --region us-east2 --type basic -o yaml`
* create api keys in GUI or via cli `ccloud api-key create --resource ID-from-Created-Cluster --description "API Key for cluster" -o yaml`; please save the key and secret
* enable Schema Registry in GUI or via cli `ccloud schema-registry cluster enable --cloud aws --geo us --environment your-environment-id`
* create Schema Registry API key in GUI or via cli `ccloud api-key create --resource ID-of-Schema-Registry --description "API Key for ksqlDB Hands-on Workshop" -o yaml` ; please save the key and secret
* create ksqlDB via GUI or cli `ccloud ksql app create ksqlDB-Hands-om --csu 4 --api-key CCLOUD_KEY --api-secret CCLOUD_SECRET --environment your-environment-id --cluster ID-from-Created-Cluster > ksqldbid`

Now, if want to create everything manually you have to create the topics for the Labs. If you did run the script based setup, everything is prepared.
```bash
cd ccloud/
    # Create topics
    # Normal Topics
    ccloud kafka topic create orders --partitions 1 --environment your-environment-id --cluster ID-from-Created-Cluster
    ccloud kafka topic create shipments --partitions 1 --environment your-environment-id --cluster ID-from-Created-Cluster
    ccloud kafka topic create inventory --partitions 1 --environment your-environment-id --cluster ID-from-Created-Cluster
    ccloud kafka topic create shipment_status --partitions 1 --environment your-environment-id --cluster ID-from-Created-Cluster
    ccloud kafka topic create transactions --partitions 1 --environment your-environment-id --cluster ID-from-Created-Cluster
    # Lab1 with Schema
    ccloud kafka topic create Payment_Instruction --partitions 1 --environment your-environment-id --cluster ID-from-Created-Cluster
    ccloud schema-registry schema create --subject Payment_Instruction-value --schema payment_instructions.json --type JSON --api-key CCLOUD_SRKEY --api-secret CCLOUD_SRSECRET --environment your-environment-id
    ccloud kafka topic create AML_Status --partitions 1 --environment your-environment-id --cluster ID-from-Created-Cluster
    ccloud schema-registry schema create --subject AML_Status-value --schema aml_status.json --type JSON --api-key CCLOUD_SRKEY --api-secret CCLOUD_SRSECRET --environment your-environment-id
    ccloud kafka topic create Funds_Status --partitions 1 --environment your-environment-id --cluster ID-from-Created-Cluster
    ccloud schema-registry schema create --subject Funds_Status-value --schema funds_status.json --type JSON --api-key CCLOUD_SRKEY --api-secret CCLOUD_SRSECRET --environment your-environment-id
    ccloud kafka topic create CUSTOMERS_FLAT --partitions 1 --environment your-environment-id --cluster ID-from-Created-Cluster --config cleanup.policy=compact
    ccloud schema-registry schema create --subject CUSTOMERS_FLAT-value --schema customers.json --type JSON --api-key CCLOUD_SRKEY --api-secret CCLOUD_SRSECRET --environment your-environment-id
    # lab 3
    # coming soon
    # lab 4
    # coming soon
    # lab 5
    # coming soon
    # lab 6
    # coming soon
    # lab 7
    # coming soon
    # lab 8 topics
    ccloud kafka topic create custcustomers --partitions 1 --environment your-environment-id --cluster ID-from-Created-Cluster
    ccloud kafka topic create custorders --partitions 1 --environment your-environment-id --cluster ID-from-Created-Cluster
    ccloud kafka topic create custitems --partitions 1 --environment your-environment-id --cluster ID-from-Created-Cluster
    # lab7
    ccloud kafka topic create atm_locations --partitions 1 --environment your-environment-id --cluster ID-from-Created-Cluster
```
Of course you could also use the kafka tools to create topics.
For this you would like to create a properties file. Replace the variables with your own entries 
```bash
echo "ssl.endpoint.identification.algorithm=https
          sasl.mechanism=PLAIN
          request.timeout.ms=20000
          bootstrap.servers=$CCLOUD_CLUSTERID_BOOTSTRAP
          retry.backoff.ms=500
          sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"$CCLOUD_KEY\" password=\"$CCLOUD_SECRET\";
          security.protocol=SASL_SSL
          # Schema Registry specific settings
          basic.auth.credentials.source=USER_INFO
          schema.registry.basic.auth.user.info=$CCLOUD_SRKEY:$CCLOUD_SRSECRET
          schema.registry.url=$CCLOUD_SRURL
          # Enable Avro serializer with Schema Registry (optional)
          key.serializer=io.confluent.kafka.serializers.KafkaAvroSerializer
          value.serializer=io.confluent.kafka.serializers.KafkaAvroSerializer" > ccloud_$line.properties
```
That's all. Now you can play around in Confluent Cloud

# Check Confluent Cloud control plane - Log-in into GUI
Open URL in Browser on your local machine and go to [Confluent Cloud](https://confluent.cloud) and login
You can use our [Quick-Start Guide](https://docs.confluent.io/cloud/current/get-started/index.html) for the first play-around session.

# Load data (Confluent Cloud)
If you running Confluent Cloud environment, we will insert data later in the labs.

[go back to Agenda](https://github.com/ora0600/confluent-ksqldb-hands-on-workshop/blob/master/README.md#hands-on-agenda-and-labs)
