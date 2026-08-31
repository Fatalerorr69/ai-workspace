#!/bin/bash
# AUTOMATICKÝ INSTALÁTOR GENESIS AETERNA
echo "--- STARTUJI KOMPLETNÍ INSTALACI ---"

sudo apt update && sudo apt upgrade -y
sudo apt install -y python3-full python3-pip adb fastboot nmap docker.io git curl wget tmux zram-tools

# PCIe Gen3 pro SSD
echo "dtparam=pciex1_gen=3" | sudo tee -a /boot/firmware/config.txt

# Ollama (Lokální AI)
curl -fsSL https://ollama.com/install.sh | sh

# Python závislosti pro HUD
pip3 install dash dash-bootstrap-components psutil requests --break-system-packages

# Ovladače pro 3.5" TFT (Waveshare/GoodTFT)
cd ~/genesis/tools
git clone https://github.com/goodtft/LCD-show.git
chmod -R 755 LCD-show

echo "INSTALACE HOTOVA. RESTARTUJI..."
sudo reboot
