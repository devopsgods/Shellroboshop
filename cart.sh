#!/bin/bash

USER_ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGS_FILE="/tmp/$0-$TIMESTAMP.log"
LOGS_FOLDER="/var/log/Shellroboshop"
LOGS_FILES="$LOGS_FOLDER/0.log"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.karegowdra.com

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USER_ID -ne 0 ]; then
    echo -e "$R run with root user access $N" | tee -a $LOGS_FILES
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2...... $N failed" | tee -a $LOGS_FILES
        exit 1
        else
        echo -e "$2 .......$N" GREAT SUCCESS| tee -a $LOGS_FILES
    fi
}

dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "disablling previous nodejs"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "ENABLING NODEJS:20"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "installing nodejs"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "user already exist $Y Skipping $N"
fi

mkdir -p /app
VALIDATE $? "creating system user"

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip  &>>$LOGS_FILE
VALIDATE $? "Downloading cart code"

cd /app
VALIDATE $? "moving to app directory"

rm -rf /app/*
VALIDATE $? "removing existing code"

unzip /tmp/cart.zip
VALIDATE $? "unzip cart code"

npm install &>> $LOGS_FILE 

cp /home/ec2-user/Shellroboshop/cart.service /etc/systemd/system/cart.service
VALIDATE $? "created systemctl service"

systemctl daemon-reload
systemctl enable cart
systemctl start cart
VALIDATE $? "starting and running cart"

