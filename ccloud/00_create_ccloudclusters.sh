#!/bin/bash

# env vars
source ./env-vars
# amount of attendees
n=0
sr=0

# Register to CCloud Org
echo "login to CCloud"
ccloud login
# USE cloud environment
echo "Use CCloud environment"
export CCLOUD_ENV=$XX_CCLOUD_ENV
ccloud environment use $CCLOUD_ENV
# save context
ccloud login --save

# read from attendes file
echo "Check Attendee File"
if [ -s $XX_CCLOUD_ATTENDEES ] 
then
     echo "attendees file is there, let's go"
else     
     echo "attendees file is empty, stop."
     exit
fi

# //\\|

# ******************************************************
# ***     CREATE Cluster for each attendee from File
# ******************************************************
while read line; do
# reading each line
    echo "Attendee-$n is : $line"
    export CCLOUD_CLUSTERNAME=$XX_CCLOUD_CLUSTERNAME-$n
    # create cluster
    echo "create cluster $CCLOUD_CLUSTERNAME for $line"
    ccloud kafka cluster create $CCLOUD_CLUSTERNAME --cloud $XX_CLOUD_PROVIDER --region $XX_CLOUD_REGION --type $XX_CLOUD_TYPE -o yaml > clusterid
    # set cluster id as parameter
    export CCLOUD_CLUSTERID=$(awk '/id:/{print $NF}' clusterid)
    export CCLOUD_CLUSTERID_BOOTSTRAP=$(awk '/endpoint: SASL_SSL:\/\//{print $NF}' clusterid | sed 's/SASL_SSL:\/\///g')
    ccloud api-key create --resource $CCLOUD_CLUSTERID --description "API Key for cluster user" -o yaml > apikey1
    export CCLOUD_KEY=$(awk '/key/{print $NF}' apikey1)
    export CCLOUD_SECRET=$(awk '/secret/{print $NF}' apikey1)
    if [ $sr  -eq 0 ]
    then
      #enable schema registry
      echo "Enable Schema Registry in $XX_CLOUD_PROVIDER for $XX_CLOUD_SRREGION"
      ccloud schema-registry cluster enable --cloud $XX_CLOUD_PROVIDER --geo $XX_CLOUD_SRREGION --environment $CCLOUD_ENV
      ccloud schema-registry cluster describe -o yaml > srinfos
      export CCLOUD_SRID=$(awk '/cluster_id/{print $NF}'  srinfos)
      export CCLOUD_SRURL=$(awk '/endpoint_url/{print $NF}'  srinfos) 
      # Create SCHEMA Registry API KEY
      echo "Create Schema Registry Keys"
      ccloud api-key create --resource $CCLOUD_SRID --description "API Key for ksqlDB Hands-on Workshop" -o yaml > srkey
      export CCLOUD_SRKEY=$(awk '/key/{print $NF}' srkey)
      export CCLOUD_SRSECRET=$(awk '/secret/{print $NF}' srkey)
      sr=1
    fi
    # create ksqlDB
    echo "create ksqlDB in cluster $CCLOUD_CLUSTERID for $line"
    ccloud ksql app create $CCLOUD_CLUSTERNAME --csu 4 --api-key $CCLOUD_KEY --api-secret $CCLOUD_SECRET --environment $CCLOUD_ENV --cluster $CCLOUD_CLUSTERID > ksqldbid
    export CCLOUD_KSQLDB_REST=$(sed 's/|//g' ksqldbid | awk '/Endpoint/{print $NF}')
    export CCLOUD_KSQLDB_ID=$(sed 's/|//g' ksqldbid | awk '/Id/{print $NF}')
    # create user and align cluster
    # Create user and do role binding
    echo "Create user and align cluster"
    ccloud admin user invite $line
    ccloud admin user list   |  grep $line > principal
    export PRINCIPAL=$(awk '{print $1}' principal)
    echo $PRINCIPAL >> to_be_deleted_users.txt
    echo "do role binding for $line principal $PRINCIPAL cluster $CCLOUD_CLUSTERID"
    XX_CCLOUD_RBAC=1 ccloud iam rolebinding create --principal User:$PRINCIPAL --role CloudClusterAdmin --environment $CCLOUD_ENV --cloud-cluster $CCLOUD_CLUSTERID
    echo "Give the cluster two minutes ..."
    sleep 120
    # Create topics
    # Normal Topics
    ccloud kafka topic create orders --partitions 1 --environment $CCLOUD_ENV --cluster $CCLOUD_CLUSTERID
    ccloud kafka topic create shipments --partitions 1 --environment $CCLOUD_ENV --cluster $CCLOUD_CLUSTERID
    ccloud kafka topic create inventory --partitions 1 --environment $CCLOUD_ENV --cluster $CCLOUD_CLUSTERID
    ccloud kafka topic create shipment_status --partitions 1 --environment $CCLOUD_ENV --cluster $CCLOUD_CLUSTERID
    ccloud kafka topic create transactions --partitions 1 --environment $CCLOUD_ENV --cluster $CCLOUD_CLUSTERID
    # Lab1 with Schema
    ccloud kafka topic create Payment_Instruction --partitions 1 --environment $CCLOUD_ENV --cluster $CCLOUD_CLUSTERID
    ccloud schema-registry schema create --subject Payment_Instruction-value --schema payment_instructions.json --type JSON --api-key $CCLOUD_SRKEY --api-secret $CCLOUD_SRSECRET --environment $CCLOUD_ENV
    ccloud kafka topic create AML_Status --partitions 1 --environment $CCLOUD_ENV --cluster $CCLOUD_CLUSTERID
    ccloud schema-registry schema create --subject AML_Status-value --schema aml_status.json --type JSON --api-key $CCLOUD_SRKEY --api-secret $CCLOUD_SRSECRET --environment $CCLOUD_ENV
    ccloud kafka topic create Funds_Status --partitions 1 --environment $CCLOUD_ENV --cluster $CCLOUD_CLUSTERID
    ccloud schema-registry schema create --subject Funds_Status-value --schema funds_status.json --type JSON --api-key $CCLOUD_SRKEY --api-secret $CCLOUD_SRSECRET --environment $CCLOUD_ENV
    ccloud kafka topic create CUSTOMERS_FLAT --partitions 1 --environment $CCLOUD_ENV --cluster $CCLOUD_CLUSTERID --config cleanup.policy=compact
    ccloud schema-registry schema create --subject CUSTOMERS_FLAT-value --schema customers.json --type JSON --api-key $CCLOUD_SRKEY --api-secret $CCLOUD_SRSECRET --environment $CCLOUD_ENV
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
    ccloud kafka topic create custcustomers --partitions 1 --environment $CCLOUD_ENV --cluster $CCLOUD_CLUSTERID
    ccloud kafka topic create custorders --partitions 1 --environment $CCLOUD_ENV --cluster $CCLOUD_CLUSTERID
    ccloud kafka topic create custitems --partitions 1 --environment $CCLOUD_ENV --cluster $CCLOUD_CLUSTERID
    # lab7
    ccloud kafka topic create atm_locations --partitions 1 --environment $CCLOUD_ENV --cluster $CCLOUD_CLUSTERID
    # Print Mapping
    if [ $n  -eq 0 ]
    then
          echo "email:$line  principal:$PRINCIPAL  cluster:$CCLOUD_CLUSTERNAME  clusterid:$CCLOUD_CLUSTERID  bootstrap:$CCLOUD_CLUSTERID_BOOTSTRAP  cluster-key:$CCLOUD_KEY  cluster-secret:$CCLOUD_SECRET  ksqlDBID:$CCLOUD_KSQLDB_ID   ksqlDBREST:$CCLOUD_KSQLDB_REST  ksqDB-URL:https://confluent.cloud/environments/$CCLOUD_ENV/clusters/$CCLOUD_CLUSTERID/ksql/$CCLOUD_KSQLDB_ID/editor  SR-URL:$CCLOUD_SRURL  SR-APIKEY:$CCLOUD_SRKEY  SR-SECRET:$CCLOUD_SRSECRET " > attendees_cluster.txt
          # for google sheet
          echo "SPLIT(\"$line , $PRINCIPAL , $CCLOUD_CLUSTERNAME , $CCLOUD_CLUSTERID , $CCLOUD_CLUSTERID_BOOTSTRAP , $CCLOUD_KEY  $CCLOUD_SECRET  , $CCLOUD_KSQLDB_ID  ,$CCLOUD_KSQLDB_REST  ,https://confluent.cloud/environments/$CCLOUD_ENV/clusters/$CCLOUD_CLUSTERID/ksql/$CCLOUD_KSQLDB_ID/editor  ,$CCLOUD_SRURL  ,$CCLOUD_SRKEY  ,$CCLOUD_SRSECRET\",\",\")\" " > attendees_cluster_googlesheet.txt
    else
          echo "email:$line  principal:$PRINCIPAL  cluster:$CCLOUD_CLUSTERNAME  clusterid:$CCLOUD_CLUSTERID  bootstrap:$CCLOUD_CLUSTERID_BOOTSTRAP  cluster-key:$CCLOUD_KEY  cluster-secret:$CCLOUD_SECRET  ksqlDBID:$CCLOUD_KSQLDB_ID   ksqlDBREST:$CCLOUD_KSQLDB_REST  ksqDB-URL:https://confluent.cloud/environments/$CCLOUD_ENV/clusters/$CCLOUD_CLUSTERID/ksql/$CCLOUD_KSQLDB_ID/editor  SR-URL:$CCLOUD_SRURL  SR-APIKEY:$CCLOUD_SRKEY  SR-SECRET:$CCLOUD_SRSECRET " >> attendees_cluster.txt
          # for google sheet
          echo "SPLIT(\"$line , $PRINCIPAL , $CCLOUD_CLUSTERNAME , $CCLOUD_CLUSTERID , $CCLOUD_CLUSTERID_BOOTSTRAP , $CCLOUD_KEY  $CCLOUD_SECRET  , $CCLOUD_KSQLDB_ID  ,$CCLOUD_KSQLDB_REST  ,https://confluent.cloud/environments/$CCLOUD_ENV/clusters/$CCLOUD_CLUSTERID/ksql/$CCLOUD_KSQLDB_ID/editor  ,$CCLOUD_SRURL  ,$CCLOUD_SRKEY  ,$CCLOUD_SRSECRET\",\",\")\" " >> attendees_cluster_googlesheet.txt
    fi
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
    n=$((n+1))
done < $XX_CCLOUD_ATTENDEES

echo "ksqlDB-Workshop Environment filled with all clusters for attendee"