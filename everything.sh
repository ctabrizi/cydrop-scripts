#!/bin/bash

# To run this script:
# bash everything.sh [IP_ADDRESS] [NEW_USER]

IP_ADDRESS=$1
NEW_USER=$2
REPO_URL=$3

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
# Run everything.sh from local machine

echo "[everything.sh] starting!"
echo "setting up server at IP: " $IP_ADDRESS
echo "for new user: " $NEW_USER
echo "with repo: " $REPO_URL
checkpoint "0: Look okay? (*/n)"

#----------------------------------------------
# Install Git + Clone scripts repo

ssh root@$IP_ADDRESS << EOF
	mkdir scripts
	cd scripts
	sudo apt-get install git
	git clone $REPO_URL .
EOF
checkpoint "1: Installed repo? (*/n)"

#----------------------------------------------
# Run access.sh from root

ssh root@$IP_ADDRESS "cd scripts && bash accounts.sh $NEW_USER"
checkpoint "2: Ran 'access.sh' okay? (*/n)"

#----------------------------------------------
# Run website.sh from cyrus

ssh $NEW_USER@$IP_ADDRESS "cd scripts && bash website.sh"
checkpoint "3: Ran 'website.sh' okay? (*/n)"




