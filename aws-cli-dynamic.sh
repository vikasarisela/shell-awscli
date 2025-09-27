#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-07e88823124a6dddf"

for instance in $@ 
do 
    Instance_ID=$(aws ec2 run-instances \
      --image-id $AMI_ID \
      --instance-type t2.micro \
      --security-group-ids $SG_ID \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
      --query 'Instances[0].InstanceId' \
      --output text
)

if [ $instance != "frontend" ];then
    IP=$(aws ec2 describe-instances \
      --instance-ids $Instance_ID \
      --query 'Reservations[0].Instances[0].PrivateIpAddress' \
      --output text)

else
    IP=$(aws ec2 describe-instances \
      --instance-ids $Instance_ID \
      --query 'Reservations[0].Instances[0].PublicIpAddress' \
      --output text)
fi
    echo "$instance : $IP" 
done

