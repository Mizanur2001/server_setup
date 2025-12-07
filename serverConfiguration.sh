#!/bin/bash

set -e

# Color codes
GREEN="\e[32m"
BOLD="\e[1m"
RESET="\e[0m"

# Helper function for section titles
section() {
    echo -e "${GREEN}==========================================${RESET}"
    echo -e "${BOLD}${GREEN}$1${RESET}"
    echo -e "${GREEN}==========================================${RESET}"
}

section "   Initial Server Configuration Script   "

# Update & Upgrade
section "[1/10] Updating system..."
sudo apt update -y && sudo apt upgrade -y

# Install required packages
section "[2/10] Installing utilities..."
sudo apt install -y curl wget git ufw fail2ban software-properties-common btop

# Install Node.js LTS 24.11.1
section "[3/10] Installing Node.js LTS 24.11.1..."
NODE_VERSION="v24.11.1"
NODE_DISTRO="linux-x64"

cd /tmp
wget https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-${NODE_DISTRO}.tar.xz
sudo tar -xJf node-${NODE_VERSION}-${NODE_DISTRO}.tar.xz -C /usr/local --strip-components=1

echo "Node version installed: $(node -v)"
echo "NPM version installed:  $(npm -v)"

# Install PM2 globally
section "[4/10] Installing PM2..."
sudo npm install pm2 -g
echo "Configuring PM2 startup..."
sudo pm2 startup systemd --silent

# Install NGINX
section "[5/10] Installing NGINX..."
sudo apt install -y nginx
sudo systemctl enable nginx

# Firewall configuration
section "[6/10] Configuring UFW firewall..."
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

# Fail2ban
section "[7/10] Starting fail2ban..."
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Enable unattended upgrades
section "[8/10] Enabling unattended upgrades..."
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades

# Install Certbot (Let's Encrypt)
section "[9/10] Installing Certbot for SSL..."
sudo apt install -y certbot python3-certbot-nginx

echo -e "${GREEN}Certbot installed successfully!${RESET}"

# Final summary
section "[10/10] Setup finished!"
echo " Server Setup Completed Successfully!"
echo " Node:     $(node -v)"
echo " PM2:      $(pm2 -v)"
echo " NGINX:    $(nginx -v 2>&1)"
echo " Certbot:  $(certbot --version)"
echo " Firewall: UFW Active"
echo -e "${GREEN}==========================================${RESET}"