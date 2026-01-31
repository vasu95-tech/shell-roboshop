#!/bin/bash

userid=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
script_dir=$pwd
log_folder="/var/log/shell-roboshop"
mkdir -p $log_folder
script_name=$( echo $0 | cut -d "." -f1 )
log_file="$log_folder/$script_name.log"

if [ $userid -ne 0 ]; then
  echo "Run the script with root privelege"
  exit 12
  fi

validate(){
    if [ $1 -ne 0 ]; then
    echo -e "$2...$R FAILURE $N " |  tee -a $log_file
    exit 12
    else 
    echo -e "$2...$G SUCCESS $N" |  tee -a $log_file
    fi
}

dnf module disable nodejs -y &>>$log_file
validate $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$log_file
validate $? "enabling nodejs:20"
dnf install nodejs -y &>>$log_file
validate $? "installing nodejs"
if [ id roboshop -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log_file
validate $? "creating user"
else
echo -e " user already exist $Y Skipping $N"
fi
mkdir -p /app 
validate $? "creating app directory"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$log_file
validate $? "downloading the catalogue application code"
cd /app 
validate $? "changing directory to app"
rm -rf /app/*
validate $? "removing existing code"
unzip /tmp/catalogue.zip &>>$log_file
validate $? "unzipping catalogue code"
cd /app 
validate $? "changing directory to app"
npm install &>>$log_file
validate $? "installing dependencies"
cp $script_dir/catalogue.service /etc/systemd/system/catalogue.service
validate $? "copy catalogue service"
systemctl daemon-reload
validate $? "daemon-reload"
systemctl enable catalogue &>>$log_file
validate $? "enabling catalogue"
systemctl start catalogue
validate $? "starting catalogue"

cp $script_dir/mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "copy mongo repo"
dnf install mongodb-mongosh -y &>>$log_file
validate $? "installing mongodb client"
mongosh --host mongodb.daws-86vasu.fun </app/db/master-data.js &>>$log_file
validate $? "load catalogue products"
systemctl restart catalogue
validate $? "catalogue restarted"

