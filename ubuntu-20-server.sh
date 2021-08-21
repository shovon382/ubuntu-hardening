#!/bin/bash

# config
USER_NAME="demouser"
SSH_PORT="222"
INSTALL_HOSTS=0
INSTALL_ClamAV=0
INSTALL_rkhunter=0

# update and upgrade
sudo apt update && sudo apt upgrade -y

# clean
sudo apt-get autoremove -y
sudo apt-get autoclean -y

# add user
sudo adduser $USER_NAME
sudo usermod -aG sudo $USER_NAME

# ssh harden
# block root from ssh access
sed -i -e 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config

#change ssh port
sed -i -e "s/#Port 22/Port $SSH_PORT/g" /etc/ssh/sshd_config

#change max auth tries
sed -i -e 's/#MaxAuthTries/MaxAuthTries/g' /etc/ssh/sshd_config

# install firewall
sudo apt install ufw -y

# firewall rules
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow $SSH_PORT
sudo ufw allow 'Nginx Full'

# enable firewall
sudo ufw enable

#sysctl.conf rules
sed -i -e 's/#net.ipv4.conf.default.rp_filter=1/net.ipv4.conf.default.rp_filter=1/g' /etc/sysctl.conf
sed -i -e 's/#net.ipv4.conf.all.rp_filter=1/net.ipv4.conf.all.rp_filter=1/g' /etc/sysctl.conf
sed -i -e 's/#net.ipv4.tcp_syncookies=1/net.ipv4.tcp_syncookies=1/g' /etc/sysctl.conf
sed -i -e 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=0/g' /etc/sysctl.conf

#install fail2ban
sudo apt-get install fail2ban -y

# fail2ban rules
echo "[DEFAULT]
bantime = 8h
ignoreip = 127.0.0.1/8 xxx.xxx.xxx.xxx
ignoreself = true

[sshd]
enabled = true
port = $SSH_PORT
filter = sshd
logpath = /var/log/auth.log
maxretry = 3" >> /etc/fail2ban/jail.local

service fail2ban restart


# install rkhunter
if [[ "$INSTALL_rkhunter" == 1 ]]; then
sudo apt-get install rkhunter -y
fi

# install cleam anti virus
if [[ "$INSTALL_ClamAV" == 1 ]]; then
sudo apt-get install clamav clamav-daemon -y
sudo systemctl stop clamav-freshclam
freshclam
sudo systemctl start clamav-freshclam
sudo systemctl enable clamav-freshclam
fi

# install hosty
if [[ "$INSTALL_HOSTS" == 1 ]]; then
sudo apt install bash curl gawk gnupg cron p7zip-full gzip -y
curl -L git.io/hosty | sh
fi