#!/bin/bash

SG_ID="sg-059bc57f32dfd1979"
AMI_ID="ami-0220d79f3f480ecf5"

# Using 'i' for the loop variable to keep it simple
for i in $@
do
    echo "Creating instance for: $i"

    # 1. No spaces around '='. Fixed Query string.
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --security-group-ids "$SG_ID" \
        --instance-type "t3.micro" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" \
        --query 'Instances[0].InstanceId' \
        --output text)

    echo "Instance Created: $INSTANCE_ID"

    # 2. Logic to get Public or Private IP
    if [ "$i" == "frontend" ]; then 
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
            --output text)
    else 
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query 'Reservations[0].Instances[0].PrivateIpAddress' \
            --output text)
    fi
     
    echo "IP Address for $i: $IP"
done