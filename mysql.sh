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

dnf install mysql-server -y &>>$LOGS_FILE
VALIDATE $? "Install MySQL server"

systemctl enable mysqld &>>$LOGS_FILE
systemctl start mysqld  
VALIDATE $? "Enable and start mysql"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Setup root password"