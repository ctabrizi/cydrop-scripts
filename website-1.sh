#!/bin/bash

# Run this script from "NEW_USER":
# bash website.sh [GIT_USER] [DOMAIN]

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

cd ~
echo "in this directory: $(pwd)"
GIT_USER="$1"
DOMAIN="$2"
DO_API_KEY="$3"
USER=$(whoami)
echo "using Github user:       $GIT_USER"
echo "installing this domain:  $DOMAIN"
echo "while logged in as user: $USER"

checkpoint "0: Look okay?"

#----------------------------------------------
# Prompt user for sudo password
sudo ls
checkpoint "1: Prompted for sudo"

#----------------------------------------------
# Get password for Github account
echo "Type in password for Github account: " $GIT_USER
read -s GIT_PASSWORD

# Confirm user password
echo "Okay, now confirm password for " $GIT_USER
read -s DOUBLE_CHECK_1

# Double check passwords
if [ "$GIT_PASSWORD" != "$DOUBLE_CHECK_1" ]; then
    echo "Passwords didn't match. Aborting"
    exit 1
fi
checkpoint "1: Passwords entered correctly!"

#----------------------------------------------
# Clone website repo
sudo rm -rf /var/www/html
sudo git clone https://$GIT_USER:$GIT_PASSWORD@github.com/$GIT_USER/$DOMAIN.git /var/www/html
checkpoint "2: Cloned website repo to /var/www/html"

#----------------------------------------------
# Enable firewall
sudo ufw allow http
sudo ufw allow https
checkpoint "3: Added HTTP & HTTPS to firewall."

#----------------------------------------------
# Install NGINX
sudo apt-get install nginx
sudo systemctl start nginx
sudo systemctl stop nginx
sudo cp /etc/nginx/sites-available/default ~/nginx-default
sudo > /etc/nginx/sites-available/default
checkpoint "4: Installed NGINX"

#----------------------------------------------
# Install certbot
wget https://dl.eff.org/certbot-auto
checkpoint "5: Downloaded Certbot"

chmod a+x ./certbot-auto

checkpoint "To fill out certbot\n ...Enter email, Agree, No then Cancel"
sudo ./certbot-auto
# enter email
# A for Agree
# N for no (to receive emails)
# c to cancel


#----------------------------------------------
# Fix permissions on certbot
sudo mv certbot-auto /usr/local/bin

# restrict write access to superuser
sudo chown root /usr/local/bin/certbot-auto
sudo chmod 0755 /usr/local/bin/certbot-auto
checkpoint "6: Fixed Certbot permissions"

#----------------------------------------------
# add API key for automatic verification
mkdir -p .secrets
cd .secrets

DO_API_STRING="dns_digitalocean_token = $DO_API_KEY"
echo "$DO_API_STRING" >> digitalocean.ini
#file just contains
#dns_digitalocean_token = [the personal token]
#https://cloud.digitalocean.com/account/api/tokens
chmod 600 digitalocean.ini
cd ..
checkpoint "7: Made secret key file for Digital Ocean API token"

echo "[website-1.sh] Completed successfully. The rest you need to do manually"
