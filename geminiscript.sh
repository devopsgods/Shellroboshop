#!/bin/bash

SG_ID="sg-0c6160bb88a682e78"
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z015439937GBQIS91RBN2"
DOMAIN_NAME="karegowdra.com"

# Using 'i' for the loop variable to keep it simple
for i in $@
do
    echo "DEBUG: SG_ID is $SG_ID"
    echo "DEBUG: AMI_ID is $AMI_ID"
    echo "Creating instance for: $i"

    # 1. No spaces around '='. Fixed Query string.
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --security-group-ids "$SG_ID" \
        --instance-type "t3.micro" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" \
        --query 'Instances[0].InstanceId' \
        --output text)

        # If Instance creation fails, stop the script for this item
        if [ -z "$INSTANCE_ID" ] || [ "$INSTANCE_ID" == "None" ]; then
            echo "Error: Instance creation failed for $i"
            continue
        fi

    echo "Instance Created: $INSTANCE_ID"

    # 2. Logic to get Public or Private IP
    if [ "$i" == "frontend" ]; then 
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
            --output text)
            RECORD_NAME="$DOMAIN_NAME"
    else 
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query 'Reservations[0].Instances[0].PrivateIpAddress' \
            --output text)
            RECORD_NAME="$instance.$DOMAIN_NAME"
    fi
     
    echo "IP Address for $i: $IP"
#update route53
    aws route53 change-resource-record-sets \
    --hosted-zone-id  $ZONE_ID \
    --change-batch='
                                # STEP 1: Create the JSON file (This happens first)
                            cat <<EOF > /tmp/route53.json
                        {
                            "Comment": "Updating the A record for $i",
                            "Changes": [
                                {
                                    "Action": "UPSERT",
                                    "ResourceRecordSet": {
                                        "Name": "$i.$DOMAIN_NAME",
                                        "Type": "A",
                                        "TTL": 1,
                                        "ResourceRecords": [
                                            {
                                                "Value": "$IP"
                                            }
                                        ]
                                    }
                                }
                            ]
                        }
                        EOF

                            # STEP 2: Tell AWS to use that file
                            # This is a separate command, not part of the cat block
                            aws route53 change-resource-record-sets \
                                --hosted-zone-id "$ZONE_ID" \
                                --change-batch "file:///tmp/route53.json"

                            echo "Record updated for: $i.$DOMAIN_NAME" 
                     '
        echo "" record updated for $i
done