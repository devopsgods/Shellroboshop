#!/bin/bash

USER_ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGS_FILE="/tmp/$0-$TIMESTAMP.log"
LOGS_FOLDER="/var/log/Shellroboshop"
LOGS_FILES="$LOGS_FOLDER/0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

SCRIPT_DIR=$PWD
MYSQL_HOST=mysql.karegowdra.com

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

dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
VALIDATE $? "Installing python"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip  &>>$LOGS_FILE
VALIDATE $? "Downloading payment code"

cd /app
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/payment.zip &>>$LOGS_FILE
VALIDATE $? "Uzip payment code"

cd /app 
pip3 install -r requirements.txt &>>$LOGS_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Created systemctl service"

systemctl daemon-reload
systemctl enable payment &>>$LOGS_FILE
systemctl start payment
VALIDATE $? "Enabled and started payment"