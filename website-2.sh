#----------------------------------------------
# Install more certbot things
cd /opt/eff.org/certbot/venv
sudo su
source bin/activate
pip install --upgrade pip
pip install certbot-dns-digitalocean
su $NEW_USER
cd ~
checkpoint "8: Installed DNS API"

#----------------------------------------------
# Check that it's working
sudo certbot-auto plugins
checkpoint "9: The plugins look okay? (*/n)"

#----------------------------------------------
# Generate certificates

checkpoint "Now time to run certbot-auto\n..look carefully!"
sudo certbot-auto -i nginx --server https://acme-v02.api.letsencrypt.org/directory --preferred-challenges dns -d '*.$DOMAIN' -d '$DOMAIN' --dns-digitalocean --dns-digitalocean-credentials .secrets/digitalocean.ini --dns-digitalocean-propagation-seconds 240
# then enter
# 1
# nginx: [error] invalid PID number "" in "/run/nginx.pid"
# 
checkpoint "10: Finished running certbot. Continue? (*/n)"

sudo systemctl status nginx

# sudo netstat -tulpn
sudo fuser -k 80/tcp
sudo fuser -k 443/tcp

sudo systemctl restart nginx

# sudo cp /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/example.conf
# sudo cp nginx.conf /etc/nginx/sites-enabled/default

#----------------------------------------------
# Return to console
exit
echo "[website-2.sh] Completed successfully"