#!/bin/bash

# To run this script:
# bash accounts.sh [IP_ADDRESS] [NEW_USER]

echo "[accounts.sh] starting!"

#----------------------------------------------
# ASSUME ARGUMENTS ARE PROVIDED CORRECTLY
#----------------------------------------------
IP_ADDRESS = $1
NEW_USER = $2

#----------------------------------------------
# Get user password
echo "Type in a CONVENIENT password for " $NEW_USER
stty -echo
read -s USER_PASSWORD
stty echo

# Confirm user password
echo "Okay, now confirm the password for " $NEW_USER
stty -echo
read -s DOUBLE_CHECK_1
stty echo

# Double check passwords
if[[ USER_PASSWORD != DOUBLE_CHECK_1 ]]
then
echo "Passwords didn't match. Aborting"
exit 1
fi

#----------------------------------------------
# Get user password
echo "Type in a CONVENIENT password for the Front Door"
stty -echo
read -s FRONT_DOOR_PASSWORD
stty echo

# Confirm user password
echo "Okay, now confirm the password for the Front Door "
stty -echo
read -s DOUBLE_CHECK_2
stty echo

# Double check passwords
if[[ FRONT_DOOR_PASSWORD != DOUBLE_CHECK_2 ]]
then
echo "Passwords didn't match. Aborting"
exit 1
fi

#----------------------------------------------
# SSH into the machine
# Will prompt user for private key password
ssh root@$IP_ADDRESS

# Automated system upgrade
apt update
DEBIAN_FRONTEND=noninteractive apt -yq upgrade

# Hide commands that start with a space
export HISTCONTROL=ignorespace

# Enable SSH access
ufw allow OpenSSH
ufw enable

# Create new accounts
adduser $NEW_USER —gecos ",,,," —disabled-password
adduser frontdoor —gecos ",,,," —disabled-password

# Create account passwords
 echo "$NEW_USER:$USER_PASSWORD" | chpasswd
 echo "frontdoor:$FRONT_DOOR_PASSWORD" | chpasswd

# Upgrade to superuser
usermod -aG sudo $NEW_USER

# Copy SSH device keys from root to new user
rsync --archive --chown=$NEW_USER:$NEW_USER ~/.ssh /home/$NEW_USER

#----------------------------------------------
# Generate new SSH keys for internal use
ssh-keygen
echo -ne "\n" | su -c ssh-keygen frontdoor
echo -ne "\n" | su -c ssh-keygen $NEW_USER

# Copy root's public key to other users
# so that root can SSH into them
cat ~/.ssh/id_rsa.pub >> /home/frontdoor/.ssh/authorized_keys
cat ~/.ssh/id_rsa.pub >> /home/$NEW_USER/.ssh/authorized_keys

# Copy new user's key into root
# so that it can SSH into root
cat /home/$NEW_USER/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# Same thing with the Front Door
cat /home/frontdoor/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

#----------------------------------------------
# Disable all logins for root account
# It can only be SSH'd into by the new user and Front Door
sudo sed -i -e 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config

# Disable password access for everyone except the Front Door
sudo sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication no\nMatch User frontdoor\n\tPasswordAuthentication yes/g' /etc/ssh/sshd_config

# Reload the SSH file
sudo systemctl reload sshd

#----------------------------------------------
# Return to console
logout
echo "[accounts.sh] Completed successfully"
