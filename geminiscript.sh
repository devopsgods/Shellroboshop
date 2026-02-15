#!/bin/bash

SG_ID="sg-059bc57f32dfd1979"
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z015439937GBQIS91RBN2"
DOMAIN_NAME="karegowdra.com"

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
            recordname="$DOMAIN_NAME"
    else 
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query 'Reservations[0].Instances[0].PrivateIpAddress' \
            --output text)
            recordname="$instance.$DOMAIN_NAME"
    fi
     
    echo "IP Address for $i: $IP"
#update route53
    aws route53 change-resource-record-sets \
    --hosted-zone-id  $ZONE_ID \
    --change-batch "
        {
        "Comment": "Updating the A record for my EC2 instance",
        "Changes": [
            {
                    "Action": "UPSERT",
                    "ResourceRecordSet": {
                    "Name": ""$recordname"",
                    "Type": "A",
                    "TTL": 1,
                    "ResourceRecords": [
                    {
                        "Value": "'172.31.22.151'"
                    }
                    ]
                }
                }
            ]
            }

        "
        echo "" record iupdated for $i
done