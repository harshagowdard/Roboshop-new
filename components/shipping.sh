#!/bin/bash

source components/common.sh
rm -f /tmp/roboshop.log
set-hostname shipping

MAVEN "shipping"