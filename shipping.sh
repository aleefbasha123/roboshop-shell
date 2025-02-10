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

dnf install maven -y
VALIDATE $? "Insatting maven"

id roboshop
if [ $? -ne 0 ]
then
   useradd roboshop   
   VALIDATE $? "Creating roboshop user"
else 
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p  /app
VALIDATE $? "Creating  app direcoty"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip
VALIDATE $? "Downalidng shipping application"
cd /app

unzip -o /tmp/shipping.zip
VALIDATE $? "Unzipping applcaition"

mvn clean package
VALIDATE $? "Insatting dependences"

mv target/shipping-1.0.jar shipping.jar
VALIDATE $? "renaming "

cp /home/centos/roboshop-shell/shipping.service  /etc/systemd/system/shipping.service
VALIDATE $? "Coping shipping services"

systemctl daemon-reload
VALIDATE $? "shipping deamin reload "

systemctl enable shipping 
VALIDATE $? " enabling"

systemctl start shipping
VALIDATE $? "starting"

dnf install mysql -y
VALIDATE $? "Installing mysql"

mysql -h 172.31.34.154 -uroot -pRoboShop@1 < /app/db/schema.sql 
VALIDATE $? "loading schema file"

systemctl restart shipping
VALIDATE $? "restarting"






