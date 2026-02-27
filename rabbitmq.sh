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

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "added Rabbitmq.repo"

dnf install rabbitmq-server -y
VALIDATE $? "installing rabbitmq.server"

systemctl enable rabbitmq-server
systemctl start rabbitmq-server
VALIDATE $? "enabling nad starting rabbirmq"

rabbitmqctl add_user roboshop roboshop123 &>>$LOGS_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOGS_FILE
VALIDATE $? "created user and given permissions"

