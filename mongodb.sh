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

cp /home/centos/roboshop/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOG_FILE

VALIDATE $? "Copying Mongo.Repo"

dnf install mongodb-org -y &>> $LOG_FILE 

VALIDATE $? "Installing Mongodb"

systemctl enable mongod &>> $LOG_FILE

VALIDATE $? "Enabling Mongodb"

systemctl start mongod &>> $LOG_FILE

VALIDATE $? "Starting Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf #&>> $LOG_FILE

VALIDATE $? "Enabling Remote Access"

systemctl restart mongod &>> $LOG_FILE

VALIDATE $? "Restarting Mongodb"