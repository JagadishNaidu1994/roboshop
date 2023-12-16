#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=mongodb.daws76s.online

TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOG_FILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

dnf module disable nodejs -y &>> $LOG_FILE

VALIDATE $? "Disabling current NodeJS"

dnf module enable nodejs:18 -y  &>> $LOG_FILE

VALIDATE $? "Enabling NodeJS:18"

dnf install nodejs -y  &>> $LOG_FILE

VALIDATE $? "Installing NodeJS:18"

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app

VALIDATE $? "creating app directory"

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip  &>> $LOG_FILE

VALIDATE $? "Downloading user application"

cd /app 

unzip -o /tmp/user.zip  &>> $LOG_FILE

VALIDATE $? "unzipping user"

npm install  &>> $LOG_FILE

VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop/user.service /etc/systemd/system/user.service

VALIDATE $? "Copying user service file"

systemctl daemon-reload &>> $LOG_FILE

VALIDATE $? "user daemon reload"

systemctl enable user &>> $LOG_FILE

VALIDATE $? "Enable user"

systemctl start user &>> $LOG_FILE

VALIDATE $? "Starting user"

cp /home/centos/roboshop/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOG_FILE

VALIDATE $? "Installing MongoDB client"

mongo --host $MONGDB_HOST </app/schema/user.js &>> $LOG_FILE

VALIDATE $? "Loading user data into MongoDB"