#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=mongodb.jagadishdaws.online

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

dnf module disable mysql -y &>> $LOG_FILE

VALIDATE $? "Disable current MySQL version"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOG_FILE

VALIDATE $? "Copied MySQl repo"

dnf install mysql-community-server -y &>> $LOG_FILE

VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>> $LOG_FILE 

VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld &>> $LOG_FILE

VALIDATE $? "Starting  MySQL Server" 

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOG_FILE

VALIDATE $? "Setting  MySQL root password"