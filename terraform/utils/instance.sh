#!/bin/bash
yum update -y
yum install wget -y
yum install unzip -y
yum install jq -y
yum install expect -y
yum install nc -y
# install docker
yum install -y docker
# install java 11
amazon-linux-extras install java-openjdk11 -y
# set environment
echo vm.max_map_count=262144 >> /etc/sysctl.conf
sysctl -w vm.max_map_count=262144
echo "    *       soft  nofile  65535
    *       hard  nofile  65535" >> /etc/security/limits.conf
sed -i -e 's/1024:4096/65536:65536/g' /etc/sysconfig/docker
# enable docker    
usermod -a -G docker ec2-user
service docker start
chkconfig docker on
curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-`uname -s`-`uname -m` | sudo tee /usr/local/bin/docker-compose > /dev/null
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# install KSQLDB Demo
cd /home/ec2-user
wget ${confluent_ksqldb_demo}
unzip master.zip
chown ec2-user:ec2-user -R /home/ec2-user/confluent-ksqldb-hands-on-workshop-master/
rm master.zip
chown ec2-user:ec2-user -R confluent-ksqldb-hands-on-workshop-master/*
cd /home/ec2-user/confluent-ksqldb-hands-on-workshop-master/
rm -rf terraform/


# set PUBLIC IP and change the Data in docker-compose.yaml
cd /home/ec2-user/confluent-ksqldb-hands-on-workshop-master/docker/
PUBIP=`curl http://169.254.169.254/latest/meta-data/public-ipv4`
SCRIPT1="sed -i 's/CONNECT_REST_ADVERTISED_HOST_NAME: connect-ext/CONNECT_REST_ADVERTISED_HOST_NAME: $PUBIP/g' docker-compose.yml;"
SCRIPT2="sed -i 's/CONTROL_CENTER_KSQL_WORKSHOP_ADVERTISED_URL: http:\/\/localhost:8088/CONTROL_CENTER_KSQL_WORKSHOP_ADVERTISED_URL: http:\/\/$PUBIP:8088/g' docker-compose.yml;"
#SCRIPT4="sed -i 's/KAFKA_ADVERTISED_LISTENERS: PLAINTEXT:\/\/kafka:29092,PLAINTEXT_HOST:\/\/localhost:9092/KAFKA_ADVERTISED_LISTENERS: PLAINTEXT:\/\/kafka:29092,PLAINTEXT_HOST:\/\/$PUBIP:9092/g' docker-compose.yml;"
# change docker-compose file with public IP for advertised properties 
bash -c "$SCRIPT1"
bash -c "$SCRIPT2"
#bash -c "$SCRIPT4"

