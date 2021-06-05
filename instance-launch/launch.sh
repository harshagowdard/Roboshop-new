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

DNS_UPDATE() {
  PRIVATEIP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${COMPONENT}" | jp.Reservations[].Instances[].PrivateIPAddress | xargs -n1)
  sed -e "s/COMPONENT/${COMPONENT}/" -e "s/IPADDRESS/${PRIVATEIP}/" record.json >/tmp/record.json
  aws route53 change-resource-record-sets --hosted-zone-id Z048208936LT81AGJ430Q --change-batch file:///tmp/record.json | jq
}
INSTANCE_CREATE() {
  INSTANCE_STATE=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${COMPONENT}"  | jq .Reservations[].Instances[].State.Name | xargs -n1)
  if [ "${INSTANCE_STATE}" = "running" ]; then
    echo "${COMPONENT} Instance already exists!!"
    DNS_UPDATE
    return 0
  fi

  if [ "${INSTANCE_STATE}" = "stopped" ]; then
    echo "${COMPONENT} Instance already exists!!"
    return 0
  fi

  echo -n Instance ${COMPONENT} created - IPADDRESS is
  aws ec2 run-instances --launch-template LaunchTemplateId=${LID},Version=${LVER}  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}]" | jq | grep  PrivateIpAddress  |xargs -n1
  sleep 10
  DNS_UPDATE
}

if [ "${1}" == "all" ]; then
  for component in frontend mongodb catalogue redis user cart mysql shipping rabbitmq payment ; do
    COMPONENT=$component
    INSTANCE_CREATE
  done
else
  COMPONENT=$1
  INSTANCE_CREATE
fi
