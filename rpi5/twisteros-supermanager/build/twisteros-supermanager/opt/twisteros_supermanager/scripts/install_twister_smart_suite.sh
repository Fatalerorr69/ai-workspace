#!/bin/bash
# ==================================================================
# install_twister_smart_suite.sh – Instalátor Twister Smart Suite
# Autor: Starko (2025)
# ==================================================================

set -euo pipefail

echo "🚀 Instaluji Twister Smart Suite..."

sudo apt update -y && sudo apt full-upgrade -y

sudo apt install -y git curl wget conky-all btop \
  retroarch libreoffice vlc chromium-browser unzip \
  docker.io docker-compose python3-pip nodejs npm realvnc-vnc-server

sudo systemctl enable docker
sudo systemctl start docker

# Web dashboard
sudo npm install -g http-server
mkdir -p ~/twister-dashboard

cat << 'EOF' > ~/twister-dashboard/index.html
<!DOCTYPE html>
<html><body style="background:#111;color:#eee;text-align:center;font-family:Arial">
<h1>🌀 Twister Smart Suite</h1>
<p>Home Assistant: <a href="http://rpi5.local:8123">8123</a></p>
<p>Node-RED: <a href="http://rpi5.local:1880">1880</a></p>
<p>Dashboard: 8080</p>
</body></html>
EOF

nohup http-server ~/twister-dashboard -p 8080 >/dev/null 2>&1 &

# Herní moduly
mkdir -p ~/Games/ROMs ~/Games/BIOS

echo "🔽 Stahuji ukázkový ROM pack..."
wget -O ~/Games/sample_rom.zip https://archive.org/download/retropie-roms-sample/retropie-roms-sample.zip || true
unzip -o ~/Games/sample_rom.zip -d ~/Games/ROMs || true

touch ~/Games/BIOS/SCPH1001.BIN

# Aktivace VNC
sudo systemctl enable vncserver-x11-serviced.service
sudo systemctl start vncserver-x11-serviced.service

echo "✅ Instalace dokončena!"
