#!/bin/bash

source components/common.sh
rm -f /tmp/roboshop.log
set-hostname catalogue

NODEJS "catalogue"