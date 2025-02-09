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

dnf module disable nodejs -y &>> $LOGFILE
VALIDTAE $? "Disable nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "Enable Nodejs"

dnf install nodejs -y &>> $LOGFILE
VALIDTAE $? "Insatlling Nodejs"

useradd roboshop &>> $LOGFILE
VALIDATE $? "Adding roboshop user"

mkdir /app &>> $LOGFILE
VALIDATE $? "Cretaing ap directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALDIATE $? "Downloading catalogue application"

cd /app &>> $LOGFILE

unzip /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "Unzipping catalogue application"

npm install  &>> $LOGFILE
VALIDATE $? "Insatting depedences"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "Coping catalogue services"

systemctl daemon-reload &>> $LOGFILE
VALDIATE $? "catalogie deamon reload"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "catalogue enable "

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "starting catalogue"


cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "coping mongo repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "insatlling mongodb-org-shell"

mongo --host 172.31.36.138 </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "Loading catalogue data inot mongobd"


