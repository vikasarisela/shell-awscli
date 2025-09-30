#!/bin/bash

# USERID=$(id -u)
# R="\e[31m"
# G="\e[32m"
# Y="\e[33m"
# N="\e[0m"

# LOGS_FOLDER="/var/log/shell-script"
# SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
# LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/16-logs.log
# SCRIPT_DIR=$PWD
# mkdir -p $LOGS_FOLDER
# echo "Script started executed at: $(date)" | tee -a $LOG_FILE

# if [ $USERID -ne 0 ]; then
#     echo "ERROR:: Please run this script with root privelege"
#     exit 1 # failure is other than 0
# fi

# VALIDATE(){ # functions receive inputs through args just like shell script args
#     if [ $1 -ne 0 ]; then
#         echo -e " $2 ... $R FAILURE $N" | tee -a $LOG_FILE
#         exit 1
#     else
#         echo -e " $2 ... $G SUCCESS $N" | tee -a $LOG_FILE
#     fi
# }

# dnf module disable nodejs -y &>>$LOG_FILE
# VALIDATE $? "Disabling Current Module"
# dnf module enable nodejs:20 -y &>>$LOG_FILE
# VALIDATE $? "Enabling  Module"
# dnf install nodejs -y &>>$LOG_FILE
# VALIDATE $? "Installing Node JS"

# id roboshop 
# if [$? -ne 0]; then
# useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
# VALIDATE $? "Adding Application User"
# else
# echo -e "User already exist ... skipping.."
# fi

# mkdir -p /app 
# VALIDATE $? "Making directory app"

# curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
# VALIDATE $? "Downloading application code to temporary place"

# cd /app 
# VALIDATE $? "cd into  app directory"

# rm -rf /app/*
# VALIDATE $? "removing exisiting code"

# unzip /tmp/catalogue.zip &>>$LOG_FILE
# VALIDATE $? "Unzipping..."

# cd /app 
# VALIDATE $? "cd into  app directory"

# npm install &>>$LOG_FILE
# VALIDATE $? "download the dependencies.."

# cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
# VALIDATE $? "Copying Catalogue service "

# systemctl daemon-reload &>>$LOG_FILE
# VALIDATE $? "Daemon Reload"

# systemctl enable catalogue 
# VALIDATE $? "Enabling Catlogue Service"

# systemctl start catalogue
# VALIDATE $? "Start Catalogue Service"

# cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
# VALIDATE $? "Copying Mongodb to mongo repo"

# dnf install mongodb-mongosh -y &>>$LOG_FILE
# VALIDATE $? "Installing Mongodb "

# INDEX=$(mongosh 172.31.28.91 --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')") 
# if [ $INDEX -le 0 ]; then
#     mongosh --host 172.31.28.91 </app/db/master-data.js &>>$LOG_FILE
#     VALIDATE $? "Load catalogue products"
# else
#     echo -e "Catalogue products already loaded ... $Y SKIPPING $N"
# fi

# systemctl restart catalogue
# VALIDATE $? "Restarted catalogue"

#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-script"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
SCRIPT_DIR=$PWD
MONGODB_HOST=172.31.16.39
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/16-logs.log

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege"
    exit 1 # failure is other than 0
fi

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

##### NodeJS ####
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling NodeJS"
dnf module enable nodejs:20 -y  &>>$LOG_FILE
VALIDATE $? "Enabling NodeJS 20"
dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing NodeJS"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "User already exist ... $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading catalogue application"

cd /app 
VALIDATE $? "Changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "unzip catalogue"

npm install &>>$LOG_FILE
VALIDATE $? "Install dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copy systemctl service"

systemctl daemon-reload
systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "Enable catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copy mongo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Install MongoDB client"

INDEX=$(mongosh $MONGODB_HOST --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Load catalogue products"
else
    echo -e "Catalogue products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue
VALIDATE $? "Restarted catalogue"