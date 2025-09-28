#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-script"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/16-logs.log

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege"
    exit 1 # failure is other than 0
fi

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e " $2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e " $2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling Current Module"
dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling  Module"
dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing Node JS"
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Adding Application User"
mkdir /app 
VALIDATE $? "Making directory app"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading application code to temporary place"
cd /app 
VALIDATE $? "cd into  app directory"
unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "Unzipping..."
cd /app 
VALIDATE $? "cd into  app directory"
npm install &>>$LOG_FILE
VALIDATE $? "download the dependencies.."
cp catalogue.service vim /etc/systemd/system/catalogue.service
VALIDATE $? "Copying Catalogue service "
systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon Reload"
systemctl enable catalogue 
VALIDATE $? "Enabling Catlogue Service"
systemctl start catalogue
VALIDATE $? "Start Catalogue Service"
cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying Mongodb to mongo repo"
dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing Mongodb "
mongosh --host 172.31.28.91 </app/db/master-data.js
VALIDATE $? "Connecting to Mongodb..."
mongosh --host 172.31.28.91
VALIDATE $? "Connect to mognodb"
show dbs
use catalogue
show collections
VALIDATE $? "show collections"