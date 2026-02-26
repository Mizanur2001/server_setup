#!/bin/bash

set -e

# ─── Color & Style Codes ───
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
WHITE="\e[97m"
DIM="\e[2m"
BOLD="\e[1m"
RESET="\e[0m"
BG_GREEN="\e[42m"
BG_CYAN="\e[46m"
BG_RED="\e[41m"

CHECKMARK="${GREEN}✔${RESET}"
ARROW="${CYAN}▶${RESET}"
ROCKET="${YELLOW}🚀${RESET}"
GEAR="${CYAN}⚙${RESET}"
SHIELD="${GREEN}🛡${RESET}"
LOCK="${YELLOW}🔒${RESET}"
PACKAGE="${CYAN}📦${RESET}"

TOTAL_STEPS=10
START_TIME=$(date +%s)

# ─── Helper Functions ───
line() {
    echo -e "${DIM}${CYAN}──────────────────────────────────────────────────${RESET}"
}

section() {
    local step=$1
    local title=$2
    local icon=$3
    echo ""
    line
    echo -e "  ${icon}  ${BOLD}${WHITE}[${step}/${TOTAL_STEPS}]${RESET}  ${BOLD}${CYAN}${title}${RESET}"
    line
}

success() {
    echo -e "  ${CHECKMARK}  ${GREEN}$1${RESET}"
}

info() {
    echo -e "  ${DIM}${WHITE}$1${RESET}"
}

elapsed() {
    local now=$(date +%s)
    local diff=$((now - START_TIME))
    local min=$((diff / 60))
    local sec=$((diff % 60))
    echo -e "  ${DIM}⏱  Elapsed: ${min}m ${sec}s${RESET}"
}

# ─── Banner ───
clear
echo ""
echo -e "${BOLD}${CYAN}"
echo "  ┌──────────────────────────────────────────────┐"
echo "  │                                              │"
echo -e "  │   ${WHITE} SERVER SETUP (V2.1.0) ${CYAN}                    │"
echo "  │    Server Configuration Script               │"
echo "  │                                              │"
echo -e "  │   ${DIM}Date : $(date '+%B %d, %Y  %H:%M %Z')${CYAN}        │"
echo -e "  │   ${DIM}Host : $(hostname)${CYAN}                           │"
echo "  │                                              │"
echo "  └──────────────────────────────────────────────┘"
echo -e "${RESET}"
echo ""

# ─── [1/10] Update & Upgrade ───
section 1 "Updating & Upgrading System" "${GEAR}"
sudo apt update -y && sudo apt upgrade -y
success "System updated and upgraded"
elapsed

# ─── [2/10] Install Utilities ───
section 2 "Installing Core Utilities" "${PACKAGE}"
sudo apt install -y curl wget git ufw fail2ban software-properties-common btop
success "Utilities installed: curl, wget, git, ufw, fail2ban, btop"
elapsed

# ─── [3/10] Install Node.js ───
section 3 "Installing Node.js LTS 24.11.1" "${PACKAGE}"
NODE_VERSION="v24.11.1"
NODE_DISTRO="linux-x64"

cd /tmp
wget https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-${NODE_DISTRO}.tar.xz
sudo tar -xJf node-${NODE_VERSION}-${NODE_DISTRO}.tar.xz -C /usr/local --strip-components=1

success "Node.js installed  →  $(node -v)"
info "NPM version        →  $(npm -v)"
elapsed

# ─── [4/10] Install PM2 ───
section 4 "Installing PM2 Process Manager" "${GEAR}"
sudo npm install pm2 -g
sudo pm2 startup systemd --silent
success "PM2 installed and startup configured"
elapsed

# ─── [5/10] Install NGINX ───
section 5 "Installing NGINX Web Server" "${PACKAGE}"
sudo apt install -y nginx
sudo systemctl enable nginx
success "NGINX installed and enabled"
elapsed

# ─── [6/10] Firewall Configuration ───
section 6 "Configuring UFW Firewall" "${SHIELD}"
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable
success "Firewall active — OpenSSH & Nginx Full allowed"
elapsed

# ─── [7/10] Fail2ban ───
section 7 "Configuring Fail2ban" "${SHIELD}"
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
success "Fail2ban enabled and running"
elapsed

# ─── [8/10] Unattended Upgrades ───
section 8 "Enabling Unattended Upgrades" "${GEAR}"
sudo apt install -y unattended-upgrades
echo 'unattended-upgrades unattended-upgrades/enable_auto_updates boolean true' | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure -plow unattended-upgrades
success "Unattended upgrades configured"
elapsed

# ─── [9/10] Certbot ───
section 9 "Installing Certbot for SSL" "${LOCK}"
sudo apt install -y certbot python3-certbot-nginx
success "Certbot installed — ready for SSL certificates"
elapsed

# ─── [10/10] Install Croc ───
section 10 "Installing Croc (File Transfer)" "${PACKAGE}"
curl https://getcroc.schollz.com | bash
success "Croc installed"
elapsed

# ─── Final Summary ───
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
DURATION_MIN=$((DURATION / 60))
DURATION_SEC=$((DURATION % 60))

echo ""
echo ""
echo -e "${BOLD}${GREEN}"
echo "  ┌──────────────────────────────────────────────┐"
echo "  │                                              │"
echo -e "  │   ${WHITE}✅  SERVER SETUP COMPLETE${GREEN}                  │"
echo "  │                                              │"
echo "  └──────────────────────────────────────────────┘"
echo -e "${RESET}"
echo ""
echo -e "  ${BOLD}${WHITE}Installed Components${RESET}"
line
echo -e "  ${CHECKMARK}  ${WHITE}Node.js    ${DIM}→${RESET}  $(node -v)"
echo -e "  ${CHECKMARK}  ${WHITE}NPM        ${DIM}→${RESET}  $(npm -v)"
echo -e "  ${CHECKMARK}  ${WHITE}PM2        ${DIM}→${RESET}  $(pm2 -v)"
echo -e "  ${CHECKMARK}  ${WHITE}NGINX      ${DIM}→${RESET}  $(nginx -v 2>&1)"
echo -e "  ${CHECKMARK}  ${WHITE}Certbot    ${DIM}→${RESET}  $(certbot --version 2>&1)"
echo -e "  ${CHECKMARK}  ${WHITE}Croc       ${DIM}→${RESET}  $(croc --version 2>&1)"
echo -e "  ${CHECKMARK}  ${WHITE}Firewall   ${DIM}→${RESET}  UFW Active"
echo -e "  ${CHECKMARK}  ${WHITE}Fail2ban   ${DIM}→${RESET}  Running"
line
echo ""
echo -e "  ${DIM}⏱  Total time: ${DURATION_MIN}m ${DURATION_SEC}s${RESET}"
echo -e "  ${DIM}📅  Completed: $(date '+%B %d, %Y at %H:%M %Z')${RESET}"
echo ""