#!/bin/bash

# To run this script:
# bash website.sh [NEW_USER] [REPO_URL]

#----------------------------------------------
# Functions
function checkpoint {
    echo "--> Reached checkpoint $1"
    read CONTINUE
    if [ "$CONTINUE" == 'n' ]; then
    	echo "You chose to abort."
    	echo "Logging out!"
    	exit 1
    fi
}  

#----------------------------------------------
# Make sure we're starting correctly

echo "[website.sh] starting!"
echo "in this directory: $(pwd)"
NEW_USER="$1"
echo "for new user: $NEW_USER"
checkpoint "0: Look okay?"


#----------------------------------------------
# Prompt user for sudo password
sudo ls

# Enable HTTP and HTTPS
sudo ufw allow http
sudo ufw allow https
sudo ufw enable

#----------------------------------------------

# Install nginx
# sudo apt-get install nginx

# cd scripts

# sudo cp /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/example.conf
# sudo cp nginx.conf /etc/nginx/sites-enabled/default


