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

dnf module disable nodejs -y &>> LOG_FILE

VALIDATE $? "Disabling nodejs Module"

dnf module enable nodejs:18 -y &>> LOG_FILE

VALIDATE $? "Enabling nodejs-18 Module"

dnf install nodejs -y  &>> $LOG_FILE 

VALIDATE $? "Installing Nodejs-18"

useradd roboshop &>> $LOG_FILE 

VALIDATE $? "Adding User"

mkdir /app &>> $LOG_FILE 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOG_FILE 

VALIDATE $? "Downloading Required Content"

cd /app &>> $LOG_FILE 

unzip -o /tmp/catalogue.zip &>> $LOG_FILE  

VALIDATE $? "Unzipping to tmp"

cd /app

npm install &>> $LOG_FILE  

VALIDATE $? "Installing Dependencies and Libraries"

cp /home/centos/roboshop/catalogue.service /etc/systemd/system/catalogue.service &>> $LOG_FILE 

VALIDATE $? "Adding Catalogue.service"

systemctl daemon-reload &>> $LOG_FILE 

VALIDATE $? "Reloading Daemon"

systemctl enable catalogue &>> $LOG_FILE 

VALIDATE $? "Enabling Catalogue Service"

systemctl start catalogue &>> $LOG_FILE 

VALIDATE $? "Restarting Catalogue Service"

cp /home/centos/roboshop/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOG_FILE 

VALIDATE $? "Adding Mongo Repo"

dnf install mongodb-org-shell -y &>> $LOG_FILE  

VALIDATE $? "Installing Mongodb-Shell"

mongo --host mongodb.jagadishdaws.online </app/schema/catalogue.js &>> $LOG_FILE 

VALIDATE $? "Adding Host to Mongo db"
