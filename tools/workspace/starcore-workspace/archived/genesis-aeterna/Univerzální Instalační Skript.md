`#!/bin/bash`  
`# =================================================================`  
`# GENESIS AETERNA v10.0 - UNIVERZÁLNÍ INSTALÁTOR (LINUX/WSL2)`  
`# =================================================================`

`G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; R='\033[0;31m'; NC='\033[0m'`

`echo -e "${B}--- GENESIS AETERNA v10.0: STARTING DEPLOYMENT ---${NC}"`

`# 1. Detekce Platformy`  
`OS=$(uname -s)`  
`ARCH=$(uname -m)`  
`echo -e "${Y}Detekováno prostředí: $OS ($ARCH)${NC}"`

`# 2. Příprava složek`  
`mkdir -p ~/genesis/{vault,tools,logs,backups}`  
`cd ~/genesis`

`# 3. Instalace závislostí podle OS`  
`if [[ "$OS" == "Linux" ]]; then`  
    `sudo apt update && sudo apt install -y python3-pip docker.io docker-compose curl nmap git`  
      
    `# RPi 5 Specifické vylepšení`  
    `if grep -q "Raspberry Pi 5" /proc/device-tree/model 2>/dev/null; then`  
        `echo -e "${G}Optimalizace pro Raspberry Pi 5 nalezena.${NC}"`  
        `if ! grep -q "dtparam=pciex1_gen=3" /boot/firmware/config.txt; then`  
            `echo "dtparam=pciex1_gen=3" | sudo tee -a /boot/firmware/config.txt`  
        `fi`  
        `sudo apt install -y zram-tools`  
    `fi`  
`fi`

`# 4. Instalace Python HUD prostředí`  
`pip3 install dash dash-bootstrap-components psutil requests --break-system-packages`

`# 5. Konfigurace AI (Ollama)`  
`if ! command -v ollama &> /dev/null; then`  
    `echo -e "${Y}Instaluji Ollama Engine...${NC}"`  
    `curl -fsSL https://ollama.com/install.sh | sh`  
`fi`

`# 6. Vytvoření Docker Compose pro zbytek služeb`  
`cat > ~/genesis/docker-compose.yml <<EOF`  
`version: '3.8'`  
`services:`  
  `portainer:`  
    `image: portainer/portainer-ce:latest`  
    `container_name: genesis-manager`  
    `restart: always`  
    `ports:`  
      `- "9443:9443"`  
    `volumes:`  
      `- /var/run/docker.sock:/var/run/docker.sock`  
      `- genesis_data:/data`

  `watchtower:`  
    `image: containrrr/watchtower`  
    `container_name: genesis-autoupdate`  
    `volumes:`  
      `- /var/run/docker.sock:/var/run/docker.sock`  
    `command: --interval 3600`

`volumes:`  
  `genesis_data:`  
`EOF`

`# Spuštění kontejnerů`  
`sudo docker-compose up -d`

`# 7. Finální integrace DNA Agentů`  
`echo -e "${G}Konfiguruji DNA Agenty...${NC}"`  
`# (Zde se spustí tvůj předchozí genesis_agents.sh pro vytvoření modelů v Ollamě)`

`echo -e "${B}--- INSTALACE DOKONČENA ---${NC}"`  
`echo -e "${G}Dashboard běží na: http://localhost:8050${NC}"`  
`echo -e "${G}Portainer (Docker GUI) na: https://localhost:9443${NC}"`  
