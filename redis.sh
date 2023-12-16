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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOG_FILE

VALIDATE $? "Installing REMI"

dnf module enable redis:remi-6.2 -y &>> $LOG_FILE

VALIDATE $? "Enabling redis-6.2"

dnf install redis -y &>> $LOG_FILE

VALIDATE $? "Installing Redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf &>> $LOG_FILE

VALIDATE $? "Allowingh remote"

systemctl enable redis &>> $LOG_FILE

VALIDATE $? "Enabling Redis"

systemctl start redis &>> $LOG_FILE

VALIDATE $? "Starting Redis"
