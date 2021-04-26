#!/bin/bash

# env vars
source ./env-vars
###### set environment variables
# CCloud environment for KSQLDB Workshop
# CCloud environment CMWORKSHOPS
attendees='to_be_deleted_users.txt'
clusters='attendees_cluster.txt'
export CCLOUD_ENV=$XX_CCLOUD_ENV

echo "login to CCloud"
ccloud login
# USE cloud environment
echo "Use CCloud environment"
ccloud environment use $CCLOUD_ENV
# save context
ccloud login --save

# Delete users
if [ -s $attendees ] 
then
     echo "users  file exists"
else 
     echo "no users file"
     exit
fi
n=0
while read line; do
    # reading each line
    echo "Delete User $n : $line"
    ccloud admin user delete $line
    n=$((n+1))
done < $attendees

# Delete clusters
if [ -s $clusters ] 
then
     echo "users clusters file exists"
else 
     echo "no users clusters file"
     exit
fi

n=0

while read line; do
    # reading each line
    CCLOUD_CLUSTERID=$(echo $line | awk '{print $4}' | cut -d ":" -f2)
    CCLOUD_KSQLDB_ID=$(echo $line | awk '{print $8}' | cut -d ":" -f2)
    # FIRST DELETE SR API KEY
    if [ $n  -eq 0 ]
    then
          CCLOUD_SRKEY=$(echo $line | awk '{print $12}' | cut -d ":" -f2)
          ccloud api-key delete $CCLOUD_SRKEY
          echo "Schema Registry $CCLOUD_SRKEY deleted"
    else
          echo ""
    fi
    echo ">>>>>>>>>>>>>>$n"
    # delete ksqlDB
    echo "Delete ksqlDB $CCLOUD_KSQLDB_ID"
    ccloud ksql app delete $CCLOUD_KSQLDB_ID --environment $CCLOUD_ENV
    # delete cluster
    echo "Delete cluster $CCLOUD_CLUSTERID"
    ccloud kafka cluster delete $CCLOUD_CLUSTERID --environment $CCLOUD_ENV
    echo "$n>>>>>>>>>>>>>>"
    n=$((n+1))
done < $clusters

# delete files
rm -rf environment
rm -rf attendees_cluster.txt
rm -rf to_be_deleted_users.txt
rm -rf clusterid
rm -rf ksqldbid
rm -rf principal
rm -rf apikey1
rm -rf srinfos
rm -rf srkey
rm -rf attendees_cluster_googlesheet.txt
rm *.properties

# Finish
echo "ksqlDB Workshop all Clusters and users deleted"
