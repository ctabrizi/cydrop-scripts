#!/bin/bash

# To run this script:
# bash website.sh [IP_ADDRESS] [NEW_USER] [SCRIPTS_REPO] [REPO_NAME]

echo "[website.sh] starting!"

#----------------------------------------------
# ASSUME ARGUMENTS ARE PROVIDED CORRECTLY
#----------------------------------------------
IP_ADDRESS = $1
NEW_USER = $2
SCRIPTS_REPO = $3

#----------------------------------------------
# Make sure IP address was provided
if[[ -z $IP_ADDRESS ]]
then
	echo "No IP address provided."
	echo "Try: bash website.sh [IP ADDRESS] [NEW_USER] [NGINX_REPO]"
	echo "exiting"
	exit 1
fi

#----------------------------------------------
# Get user name
if[[ -z $NEW_USER ]]
then
	echo "No user name provided."
	echo "Try: bash website.sh [IP ADDRESS] [NEW_USER] [NGINX_REPO]"
	echo "exiting"
	exit 1
fi

#----------------------------------------------
# SSH into the machine
# Will prompt user for private key password
ssh $NEW_USER@$IP_ADDRESS

# Prompt user for sudo password
sudo ls

# Install git
sudo apt-get install git

# Enable HTTP and HTTPS
sudo ufw allow http
sudo ufw allow https
sudo ufw enable

# Install nginx
sudo apt-get install nginx

mkdir "scripts"
cd "scripts"
git clone $SCRIPTS_REPO .

sudo cp /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/example.conf
sudo cp nginx.conf /etc/nginx/sites-enabled/default




