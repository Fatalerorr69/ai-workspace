#!/bin/bash
# GENESIS AETERNA - FINAL SYSTEM INTEGRATION
G='\033[0;32m'; B='\033[0;34m'; NC='\033[0m'

echo -e "${B}--- FINÁLNÍ INTEGRACE SYSTÉMU GENESIS ---${NC}"

# Vytvoření globálního komunikačního kanálu (Log)
touch ~/genesis/logs/genesis_v8_global.log
chmod 666 ~/genesis/logs/genesis_v8_global.log

# Propojení Sektorů přes symbolické odkazy
ln -sf ~/genesis/tools/genesis_hud.py ~/genesis/main_console.py

# Nastavení UFW pro finální porty
sudo ufw allow 8050/tcp  # HUD
sudo ufw allow 11434/tcp # Ollama API
sudo ufw allow 9000/tcp  # Portainer

# Finální kontrola integrity
if [ -d "~/genesis/vault" ]; then
    echo -e "${G}Integrace dokončena. Vault nalezen.${NC}"
else
    mkdir -p ~/genesis/vault
fi

echo -e "${B}SYSTÉM JE PŘIPRAVEN K NASAZENÍ (DEPLOYMENT READY).${NC}"
