#!/bin/bash
# =================================================================
# GENESIS AETERNA v8.0 - FOUNDATION (Základní kámen)
# =================================================================

# --- KONFIGURACE BAREV ---
G='\033[0;32m'; R='\033[0;31m'; B='\033[0;34m'; NC='\033[0m'

echo -e "${B}--- SPUŠTĚNÍ ZÁKLADNÍ INSTALACE GENESIS AETERNA ---${NC}"

# --- [1] SYSTÉMOVÝ UPDATE & FIRMWARE ---
echo -e "${G}[1] Aktualizace systému a firmwaru...${NC}"
sudo apt update && sudo apt full-upgrade -y
sudo rpi-eeprom-update -a

# --- [2] HARDWARE: NVMe SSD (GEN3) & ZRAM ---
echo -e "${G}[2] Optimalizace RPi 5 Hardware (SSD Gen3 & ZRAM)...${NC}"
if ! grep -q "dtparam=pciex1_gen=3" /boot/firmware/config.txt; then
    echo "dtparam=pciex1_gen=3" | sudo tee -a /boot/firmware/config.txt
fi
sudo apt install -y zram-tools
echo "zram-size=4096" | sudo tee /etc/default/zramswap
sudo service zramswap restart

# --- [3] INSTALACE DOCKERU & NÁSTROJŮ ---
echo -e "${G}[3] Instalace Docker engine a systémových nástrojů...${NC}"
sudo apt install -y python3-full python3-pip adb fastboot nmap docker.io git curl wget tmux build-essential ufw
sudo usermod -aG docker $USER

# --- [4] LOKÁLNÍ AI (OLLAMA & OPEN WEBUI) ---
echo -e "${G}[4] Nasazování lokální AI (Ollama)...${NC}"
curl -fsSL https://ollama.com/install.sh | sh
# Fix Portainer conflict (odstraní starý, pokud existuje)
sudo docker stop portainer 2>/dev/null && sudo docker rm portainer 2>/dev/null
sudo docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer-ce

# --- [5] ZÁKLADNÍ HUD DASHBOARD ---
echo -e "${G}[5] Inicializace HUD Dashboardu...${NC}"
mkdir -p ~/genesis/tools
pip3 install dash dash-bootstrap-components psutil requests --break-system-packages

# --- [6] FINÁLNÍ REBOOT ---
echo -e "${B}Základní setup dokončen. Restartuji...${NC}"
sleep 5
sudo reboot
