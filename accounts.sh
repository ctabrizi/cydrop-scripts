#!/bin/bash

# To run this script:
# bash accounts.sh [NEW_USER]

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

echo "[accounts.sh] starting!"
echo "in this directory: $(pwd)"
NEW_USER="$1"
echo "for new user: $NEW_USER"
checkpoint "0: Look okay?"

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
if [ "$USER_PASSWORD" != "$DOUBLE_CHECK_1" ]; then
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
if [ "$FRONT_DOOR_PASSWORD" != "$DOUBLE_CHECK_2" ]; then
	echo "Passwords didn't match. Aborting"
	exit 1
fi

#----------------------------------------------
# SSH into the machine
# Will prompt user for private key password
checkpoint "1: Passwords entered correctly"

# Automated system upgrade
apt update
DEBIAN_FRONTEND=noninteractive apt -yq upgrade
checkpoint "2: Upgrade packages"

# Hide commands that start with a space
export HISTCONTROL=ignorespace
checkpoint "3: Allowed for hidden commands"

# Enable SSH access
ufw allow OpenSSH
ufw enable
checkpoint "4: Enabled SSH through Firewall"

# Create new accounts
adduser $NEW_USER —gecos ",,,," —disabled-password
adduser frontdoor —gecos ",,,," —disabled-password
checkpoint "5: Created accounts"

# Create account passwords
 echo "$NEW_USER:$USER_PASSWORD" | chpasswd
 echo "frontdoor:$FRONT_DOOR_PASSWORD" | chpasswd
checkpoint "6: Added passwords"

# Upgrade to superuser
usermod -aG sudo $NEW_USER
checkpoint "7: Upgraded $NEW_USER to superuser"

# Copy SSH device keys from root to new user
rsync --archive --chown="$NEW_USER:$NEW_USER" ~/.ssh /home/$NEW_USER
checkpoint "8: Copied SSH keys for external devices to $NEW_USER"

#----------------------------------------------
# Generate new SSH keys for internal use
ssh-keygen
echo -ne "\n" | su -c ssh-keygen frontdoor
echo -ne "\n" | su -c ssh-keygen $NEW_USER
checkpoint "9: Made new keys for everyone"

# Copy root's public key to other users
# so that root can SSH into them
cat ~/.ssh/id_rsa.pub >> /home/frontdoor/.ssh/authorized_keys
cat ~/.ssh/id_rsa.pub >> /home/$NEW_USER/.ssh/authorized_keys

# Copy new user's key into root
# so that it can SSH into root
cat /home/$NEW_USER/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# Same thing with the Front Door
cat /home/frontdoor/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
checkpoint "10: Copied the keys around"

#----------------------------------------------
# Disable all logins for root account
# It can only be SSH'd into by the new user and Front Door
sudo sed -i -e 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config

# Disable password access for everyone except the Front Door
sudo sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication no\nMatch User frontdoor\n\tPasswordAuthentication yes/g' /etc/ssh/sshd_config

# Reload the SSH file
sudo systemctl reload sshd
checkpoint "11: Changed SSHD access settings and reloaded"

#----------------------------------------------
# Return to console
logout
echo "[accounts.sh] Completed successfully"
