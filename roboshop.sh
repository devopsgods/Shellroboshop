#!/bin/bash

SG_ID="sg-059bc57f32dfd1979"
AMI_ID="ami-0220d79f3f480ecf5"

for instance in $@
do
    instance_id = $( 
        aws ec2 run-instances \
        --image-id $AMI_ID \
        --security-group-ids $SG_ID \
        --instance-type "t3.micro" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE}]" \
        --query 'Instance[0]InstancesId' \
        --output text

        if[$instance == "frontend"];

        then 
        IP=$( aws ec2 describe-instances \
         --instance-ids $instance_id \
         --query 'Reservations[0].Instance[].PublicIpAddress' \
         --output text
)
else (
        aws ec2 describe-instances \
         --instance-ids $instance_id \
         --query 'Reservations[0].Instance[].PrivateIpAddress' \
         --output text
)

fi
     
     echo "IP Address $IP"
    )
done
