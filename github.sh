#!/bin/bash

# Run this script from your local machine:
# bash github.sh [SSH_ADDRESS] s[GIT_USER] [REPO_NAME]

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
echo "[github.sh] starting!"
echo "from this directory: $(pwd)"
SSH_ADDRESS="$1"
GIT_USER="$2"
REPO_NAME="$3"

echo "going to instal this repo: $REPO_NAME"
echo "at this address: $SSH_ADDRESS" 
echo "using Github user: $GIT_USER"
checkpoint "0: Look okay?"

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
# Log in and clone repo

c1="export HISTCONTROL=ignorespace"
c2="mkdir -p scripts"
c3="rm -rf scripts"
c4="mkdir scripts"
c5="cd scripts"
c6="sudo apt-get install git"
c7="git clone https://$GIT_USER:$GIT_PASSWORD@github.com/$GIT_USER/$REPO_NAME.git ."

 ssh $SSH_ADDRESS "$c1 && $c2 && $c3 && $c4 && $c5 && $c6 && $c7"

checkpoint "2: Installed repo? (*/n)"






