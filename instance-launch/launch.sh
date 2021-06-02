#!/bin/bash

COMPONENT=$1

## -z validates the variable emplty, true if it is empty
if [ -z "${COMPONENT}" ]; then
  echo "COMPONENT Input is needed"
  exit 1
fi

LID=lt-00ef9747f61617ee0
LVER=3

## Validate if instance is already there
INSTANCE_STATE=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${COMPONENT}"  | jq .Reservations[].Instances[].State.Name | xargs -n1)
if [ "${INSTANCE_STATE}" = "running" ]; then
  echo "Instance already exists!!"
  exit 1
fi

if [ "${INSTANCE_STATE}" = "stopped" ]; then
  echo "Instance already exists!!"
  exit 1
fi

aws ec2 run-instances --launch-template LaunchTemplateId=${LID},Version=${LVER}  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}]" | jq