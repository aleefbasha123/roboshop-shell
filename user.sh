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
VALIDATE $? "Disabling Nodejs"

dnf module enable nodejs:18 -y
VALIDATE $? "Enable Nodejs"

dnf install nodejs -y 
VALIDATE $? "Insatlling nodejs"

id roboshop
if [ $? -ne 0 ]
then
   useradd roboshop   
   VALIDATE $? "Creating roboshop user"
else 
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE 
VALIDATE $? "Cretaing ap directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "Downloading user application"

cd /app &>> $LOGFILE

unzip -o /tmp/user.zip &>> $LOGFILE
VALIDATE $? "Unzipping user application"

npm install  &>> $LOGFILE
VALIDATE $? "Insatting depedences"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE
VALIDATE $? "Coping user services"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "user deamon reload"

systemctl enable user &>> $LOGFILE
VALIDATE $? "user enable "

systemctl start user &>> $LOGFILE
VALIDATE $? "starting user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Coping mongo repo"

dnf install mongodb-org-shell -y
VALIDATE $? "Installing Mongodb-org-shell"

mongo --host 172.31.41.79 </app/schema/user.js
VALIDATE $? "Loading schema file"

