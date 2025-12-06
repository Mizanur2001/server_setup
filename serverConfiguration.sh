#!/bin/bash

set -e

echo "=========================================="
echo "   Initial Server Configuration Script"
echo "=========================================="

# Update & Upgrade
echo "[1/9] Updating system..."
sudo apt update -y && sudo apt upgrade -y

# Install required packages
echo "[2/9] Installing utilities..."
sudo apt install -y curl wget git ufw fail2ban software-properties-common

# Install Node.js LTS 24.11.1
echo "[3/9] Installing Node.js LTS 24.11.1..."
NODE_VERSION="v24.11.1"
NODE_DISTRO="linux-x64"

cd /tmp
wget https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-${NODE_DISTRO}.tar.xz
sudo tar -xJf node-${NODE_VERSION}-${NODE_DISTRO}.tar.xz -C /usr/local --strip-components=1

echo "Node version installed: $(node -v)"
echo "NPM version installed:  $(npm -v)"

# Install PM2 globally
echo "[4/9] Installing PM2..."
sudo npm install pm2 -g
echo "Configuring PM2 startup..."
sudo pm2 startup systemd --silent

# Install NGINX
echo "[5/9] Installing NGINX..."
sudo apt install -y nginx
sudo systemctl enable nginx

# Firewall configuration
echo "[6/9] Configuring UFW firewall..."
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable

# Fail2ban
echo "[7/9] Starting fail2ban..."
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "[8/9] Enabling unattended upgrades..."
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades

# Install Certbot (Let's Encrypt)
echo "[9/10] Installing Certbot for SSL..."
sudo apt install -y certbot python3-certbot-nginx

echo "Certbot installed successfully!"

echo "[10/10] Setup finished!"
echo "=========================================="
echo " Server Setup Completed Successfully!"
echo "=========================================="
echo " Node:     $(node -v)"
echo " PM2:      $(pm2 -v)"
echo " NGINX:    $(nginx -v 2>&1)"
echo " Certbot:  $(certbot --version)"
echo " Firewall: UFW Active"
echo "=========================================="
