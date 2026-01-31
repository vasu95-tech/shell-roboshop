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


cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "adding mongo repo"

dnf list installed mongodb-org &>>$log_file
if [ $? -ne 0 ]; then
dnf install mongodb-org -y &>>$log_file
validate $? "mongodb installation" 
else 
echo -e "mongodb already installed $Y SKIPPING $N" |  tee -a $log_file
fi

systemctl enable mongod &>>$log_file
validate $? "enabling mongodb"
systemctl start mongod 
validate $? "starting mongodb"

sed -i's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "allowing remote connections to mongodb"

systemctl restart mongod
validate $? "mongodb restarted"
 