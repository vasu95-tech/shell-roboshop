#!/bin/bash

userid=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

dnf module disable nodejs -y
validate $? "disabling nodejs"

dnf module enable nodejs:20 -y
validate $? "enabling nodejs:20"
dnf install nodejs -y
validate $? "installing nodejs"
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "creating user"
mkdir /app 
validate $? "creating app directory"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
validate $? "downloading the catalogue application code"
cd /app 
validate $? "changing directory to app"
unzip /tmp/catalogue.zip
validate $? "unzipping catalogue code"
cd /app 
validate $? "changing directory to app"
npm install 
validate $? "installing dependencies"
cp catalogue.service /etc/systemd/system/catalogue.service
validate $? "created .service file and updated mongodb ip "
systemctl daemon-reload
validate $? "daemon-reload"
systemctl enable catalogue 
validate $? "enabling catalogue"
systemctl start catalogue
validate $? "starting catalogue"

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "copy mongo repo"
dnf install mongodb-mongosh -y
validate $? "installing mongodb client"
mongosh --host mongodb.daws-86vasu.fun </app/db/master-data.js
validate $? "load catalogue products"
systemctl restart catalogue
validate $? "catalogue restarted"
