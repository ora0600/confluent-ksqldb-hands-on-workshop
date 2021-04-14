#!/bin/bash

###### set environment variables
# CCloud environment for KSQLDB Workshop
# CCloud environment CMWORKSHOPS
export CCLOUD_ENV=$(awk '/id:/{print $NF}' environment)
filename='to_be_deleted_users.txt'
# DELETE CCLOUD cluster 
ccloud login
# set environment and cluster
echo "delete environment with all clusters"
ccloud environment delete $CCLOUD_ENV

# Delete users
if [ -s $filename ] 
then
     echo "users file exists"
else 
     echo "no users files"
     exit
fi
n=0
while read line; do
    # reading each line
    echo "Delete User $n : $line"
    ccloud admin user delete $line
    n=$((n+1))
done < $filename

# delete files
rm -rf environment
rm -rf attendees_cluster.txt
rm -rf to_be_deleted_users.txt
rm -rf clusterid
rm -rf ksqldbid
rm -rf principal
rm *.properties

# Finish
echo "ksqlDB Workshop environment and all Clusters deleted"
