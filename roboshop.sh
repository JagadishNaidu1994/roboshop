#!/bin/bash


INSTANCE=("mongo" "redis" "mysql" "rabbitmq" "cart" "catalogue" "user" "shipping" "payments" "web" )



for i in "${INSTANCE[@]}"

do
    if [$i=="mongo"] || [$i=="mysql"] || [$i=="shipping"]
    then    
        INSTANCE_TYPE="t3.small"
    else    
        INSTANCE_TYPE="t2.micro"
    fi

        aws ec2 run-instances --image-id ami-03265a0778a880afb --instance-type $INSTANCE_TYPE --security-group-ids sg-0c55d53f300d3cd20

done