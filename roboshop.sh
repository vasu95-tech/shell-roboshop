#!/bin/bash

Ami_id=ami-0220d79f3f480ecf5
Security_group_id=sg-0ec1754eb45347fa5

for instance in $@
do

  Instance_id=$(aws ec2 run-instances --image-id $Ami_id --instance-type t3.micro --security-group-ids $Security_group_id 
  --tag-specifications"ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)
 if [ $instance != "frontend" ]; then
    ip=$(aws ec2 describe-instances --instance-ids $Instance_id --query 
    'Reservations[0].Instances[0].PrivateIpAddress' --output text)
 else  
    ip=$(aws ec2 describe-instances --instance-ids $Instance_id --query 
   'Reservations[0].Instances[0].PrivateIpAddress' --output text)
 fi
  echo $instance: $ip

done