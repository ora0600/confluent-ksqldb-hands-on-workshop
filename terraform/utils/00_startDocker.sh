#!/bin/bash

AWS_KEY="<your-aws-key-with-path>/hackathon-temp-key.pem"
AWS_SSH_USER="ec2-user"
# copy all IsP from terraform output into this file, each IP on line
AWS_HOSTS="aws_compute"

# Start docker on AWS compute

for AWS_PUBLIC_IP in $(<$AWS_HOSTS)
do
  echo "Login AWS ${AWS_PUBLIC_IP} and start docker"
  ssh -i ${AWS_KEY} ${AWS_SSH_USER}@${AWS_PUBLIC_IP} << 'EOF'
    cd /home/ec2-user/confluent-ksqldb-hands-on-workshop-master/docker
    echo "start docker"
    docker-compose up -d
    exit;
EOF
done
