#!/bin/bash

# To run this script:
# bash everything.sh [IP ADDRESS] [NEW_USER] [SCRIPTS_REPO]

echo "[everything.sh] starting!"

#----------------------------------------------
# ASSUME ARGUMENTS ARE PROVIDED CORRECTLY
#----------------------------------------------
IP_ADDRESS = $1
NEW_USER = $2
SCRIPTS_REPO = $3

#----------------------------------------------
echo "setting up server at IP: " $IP_ADDRESS
echo "for new user: " $NEW_USER

bash accounts.sh $IP_ADDRESS $NEW_USER
bash website.sh $IP_ADDRESS $NEW_USER $SCRIPTS_REPOs
#bash projects.sh

