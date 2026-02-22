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
MYSQL_HOST=mysql.karegegowdra.com

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

dnf module disable nginx -y &>>$LOGS_FILE
dnf module enable nginx:1.24 -y &>>$LOGS_FILE
dnf install nginx -y &>>$LOGS_FILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx  &>>$LOGS_FILE
systemctl start nginx 
VALIDATE $? "Enabled and started nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Remove default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOGS_FILE
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOGS_FILE
VALIDATE $? "Downloaded and unzipped frontend"

rm -rf /etc/ngnix/ngnix.conf 

cp $SCRIPT_DIR/nginx.conf /etc/nginx/ngnix.conf
VALIDATE $? "replaced ngnic conf file"

systemctl restart ngnix
VALIDATE $? "restart Ngnix"

