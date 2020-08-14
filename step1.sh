#!/bin/bash

#----- How to run this   ----------------

# From a UNIX machine, call "bash FILENAME.sh [..args..]" 
# (where FILENAME is whatever this script is called
# and with the following arguments supplied, in this order:

# 1) [IP ADDRESS]
# 2) [USERNAME]

# The third argument will be the user's password.
# For your security, this script was written without
# assuming that your terminal history is protected.
# Instead of getting the argument through the command line, it is accepted by prompt

# 3) [USER PASSWORD]

#----- The actual script ----------------

# Ask for user password
echo Type in password for $2@$1:
read password

# copy command line arguments into variables
address=$1
username=$2

# SSH into the Droplet
ssh root@$address

# Get information about system packages
apt update

# Automated upgrade of all packages
DEBIAN_FRONTEND=noninteractive apt -yq upgrade

# Hide commands with space at the beginning
export HISTCONTROL=ignorespace

# Create non-root user
adduser $username --gecos ",,,," --disabled-password
 echo "$username:$password" | chpasswd

# Upgrade user to superuser
usermod -aG sudo $username

# Copy ssh keys from root to the new user
rsync --archive --chown=$username:$username ~/.ssh /home/$username

# Set up firewall
ufw allow OpenSSH
ufw enable

# Logout as root and log in as new user
logout
ssh $username@$address



