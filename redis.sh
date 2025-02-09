#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
VALIDATE $? "Insatlling remi"

dnf module enable redis:remi-6.2 -y
VALIDATE $? "Enable redis"

dnf install redis -y
VALIDATE $? "Insatlling redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf
VALIDATE $? "chanining acess"

systemctl enable redis
VALIDATE $? "Enable redis"

systemctl start redis
VALIDATE $? "starting redis"
