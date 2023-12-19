#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=mongodb.jagadishdaws.online

TIMESTAMP=$(date +%F-%H-%M-%S)
LOG_FILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOG_FILE

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

dnf install python36 gcc python3-devel -y &>> $LOG_FILE

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOG_FILE

VALIDATE $? "creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOG_FILE

VALIDATE $? "Downloading payment"

cd /app 

unzip -o /tmp/payment.zip &>> $LOG_FILE

VALIDATE $? "unzipping payment"

pip3.6 install -r requirements.txt &>> $LOG_FILE

VALIDATE $? "Installing Dependencies"

cp /home/centos/roboshop/payment.service /etc/systemd/system/payment.service &>> $LOG_FILE

VALIDATE $? "Copying payment service"

systemctl daemon-reload &>> $LOG_FILE

VALIDATE $? "daemon reaload"

systemctl enable payment  &>> $LOG_FILE

VALIDATE $? "Enable payment"

systemctl start payment &>> $LOG_FILE

VALIDATE $? "Start payment"