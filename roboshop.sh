#!/bin/bash


INSTANCE=("mongo" "redis" "mysql" "rabbitmq" "cart" "catalogue" "user" "shipping" "payments" "web" )
ZONE_ID="Z0019687Y19PLA2QV1E9"
DOMAIN_NAME="jagadishdaws.online"





for i in "${INSTANCE[@]}"

do
    if [ $i == "mongo" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then    
        INSTANCE_TYPE="t3.small"
    else    
        INSTANCE_TYPE="t2.micro"
    fi

        IP_ADDRESS=$(aws ec2 run-instances --image-id ami-03265a0778a880afb --instance-type $INSTANCE_TYPE --security-group-ids sg-0c55d53f300d3cd20 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)

            echo "$i: $IP_ADDRESS"

     #create R53 record, make sure you delete existing record
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "CREATE"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP_ADDRESS'"
            }]
        }
        }]
    }
        '
done