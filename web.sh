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
        echo -e "\e[31m Installation \e[0m of $2 $R Failed...$N"
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

dnf install nginx -y &>> $LOG_FILE

VALIDATE $? "Nginx Installation"

systemctl enable nginx &>> $LOG_FILE

VALIDATE $? "Enabling Nginx"

systemctl start nginx &>> $LOG_FILE

VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>> $LOG_FILE 

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOG_FILE

VALIDATE $? "Downloading Frontend"

cd /usr/share/nginx/html &>> $LOG_FILE

unzip /tmp/web.zip &>> $LOG_FILE

VALIDATE $? "Extracting Frontend"

cp ~\Desktop\DEVOPS PRACTICE\roboshop\roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOG_FILE 

VALIDATE $? "Copying Roboshop Config"

systemctl restart nginx &>> $LOG_FILE 

VALIDATE $? "Restarting Nginx"
