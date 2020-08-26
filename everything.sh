#!/bin/bash

# To run this script:
# bash everything.sh [IP_ADDRESS] [NEW_USER] [GIT_USER] [REPO_NAME]

IP_ADDRESS=$1
NEW_USER=$2
GIT_USER=$3
REPO_NAME=$4
DOMAIN=$5
ENV_FILE=$6

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

echo "setting up server at IP:     $IP_ADDRESS"
echo "for new user named:          $NEW_USER"
echo "using Github repo:           $REPO_NAME"
echo "with this Git credential:    $GIT_USER"
echo "setting up this domain:      $DOMAIN"

checkpoint "0: Look okay? (*/n)"

#----------------------------------------------
# Install Git + Clone scripts repo from Github

bash github.sh "root@$IP_ADDRESS" $GIT_USER $REPO_NAME
checkpoint "1: Ran 'github.sh' okay? (*/n)"

#----------------------------------------------
# Run access.sh from root@[IP_ADDRESS]

ssh -t root@$IP_ADDRESS "cd scripts && bash accounts.sh $NEW_USER"
checkpoint "2: Ran 'access.sh' okay? (*/n)"

#----------------------------------------------
# Run website.sh from [NEW_USER]@[IP_ADDRESS]

source "$ENV_FILE"

ssh -t $NEW_USER@$IP_ADDRESS "cd scripts && bash website.sh $GIT_USER $DOMAIN $DO_API_KEY"
checkpoint "3: Ran 'website.sh' okay? (*/n)"




