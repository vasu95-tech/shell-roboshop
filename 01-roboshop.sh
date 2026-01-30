#!/bin/bash

Ami_id=ami-0220d79f3f480ecf5
Security_group_id=sg-0b982697083aeaf23
zone_id=Z0596466KWSQSWXEO556
domain_name=daws-86vasu.fun

for instance in $@
do

  Instance_id=$(aws ec2 run-instances --image-id $Ami_id --instance-type t3.micro --security-group-ids $Security_group_id --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)
 if [ $instance != "frontend" ]; then
    ip=$(aws ec2 describe-instances --instance-ids $Instance_id --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
    record_name=$instance.$domain_name
 else  
    ip=$(aws ec2 describe-instances --instance-ids $Instance_id --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    record_name=$domain_name
    fi
  echo $instance: $ip

  aws route53 change-resource-record-sets \
        --hosted-zone-id $zone_id \
        --change-batch '
        {
            "Comment": "Updating a record set"
            ,"Changes": [{
            "Action"              : "UPSERT"
            ,"ResourceRecordSet"  : {
                "Name"              : "'$record_name'"
                ,"Type"             : "A"
                ,"TTL"              : 1
                ,"ResourceRecords"  : [{
                    "Value"         : "'$ip'"
                }]
            }
            }]
        }
        '
done

