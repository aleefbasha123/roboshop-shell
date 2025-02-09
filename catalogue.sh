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

dnf module disable nodejs -y
VALIDTAE $? "Disable nodejs"

dnf module enable nodejs:18 -y
VALIDATE $? "Enable Nodejs"

dnf install nodejs -y
VALIDTAE $? "Insatlling Nodejs"

useradd roboshop
VALIDATE $? "Adding roboshop user"

mkdir /app
VALIDATE $? "Cretaing ap directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALDIATE $? "Downloading catalogue application"

cd /app 

unzip /tmp/catalogue.zip
VALIDATE $? "Unzipping catalogue application"

npm install 
VALIDATE $? "Insatting depedences"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Coping catalogue services"

systemctl daemon-reload
VALDIATE $? "catalogie deamon reload"

systemctl enable catalogue
VALIDATE $? "catalogue enable "

systemctl start catalogue
VALIDATE $? "starting catalogue"


cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "coping mongo repo"

dnf install mongodb-org-shell -y
VALIDATE $? "insatlling mongodb-org-shell"

mongo --host 172.31.36.138 </app/schema/catalogue.js
VALIDATE $? "Loading catalogue data inot mongobd"


