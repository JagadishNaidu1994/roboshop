#!/bin/bash


ID=$(id -u) 
TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE="/tmp/$0-$TIMESTAMP.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Script started running at $TIMESTAMP" &>> $LOG_FILE

VALIDATE (){
    if [ $1 = 0 ]
    then 
        echo -e "$2 $G Success....!!!!$N"
    else   
        echo -e "$2 $R Failed...$N"
    fi
}

#ROOT ACCESS CHECK
if [ $ID -ne 0 ]
then 
    echo -e "$R Error : Root Access Needed !!! $N"
    exit 1
else 
    echo -e "$G You Are Root :) $N"
fi

cp /home/centos/roboshop/mongo.repo /etc/yum.repos.d/mongo.repo 

VALIDATE $? "Copying Mongo.Repo"

dnf install mongodb-org -y 

VALIDATE $? "Installing Mongodb"

systemctl enable mongod

VALIDATE $? "Enabling Mongodb"

systemctl start mongod

VALIDATE $? "Starting Mongodb"

sed -i s/127.0.0.1/0.0.0.0 /etc/mongod.conf

VALIDATE $? "Enabling Remote Access"

systemctl restart mongod

VALIDATE $? "Restarting Mongodb"