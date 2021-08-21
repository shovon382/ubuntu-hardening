#!/bin/sh

# config
INSTALL_HOSTS=1
INSTALL_ClamAV=1
INSTALL_rkhunter=1


# update and upgrade
sudo apt update && sudo apt upgrade -y

# clean
sudo apt-get autoremove -y
sudo apt-get autoclean -y

# install firewall
sudo apt install ufw -y

# install firewall gui
sudo apt install gufw -y

# firewall rules
sudo ufw default allow outgoing
sudo ufw default deny incoming

# enable firewall
sudo ufw enable

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