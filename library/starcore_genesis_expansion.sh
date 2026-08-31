#!/bin/bash
# =================================================================
# GENESIS AETERNA - SEKTOR 2: OMNI-EXPANSION
# =================================================================

G='\033[0;32m'; R='\033[0;31m'; B='\033[0;34m'; Y='\033[1;33m'; NC='\033[0m'
LOG_DIR="$HOME/genesis/logs"
mkdir -p "$LOG_DIR"

echo -e "${B}--- SPUŠTĚNÍ EXPANSION MODULU (Sektory 07-10) ---${NC}"

# --- [OPRAVA KONFLIKTŮ Z LOGŮ] ---
echo -e "${Y}Opravuji konflikty z předchozí instalace...${NC}"
# Portainer fix
sudo docker stop portainer 2>/dev/null && sudo docker rm portainer 2>/dev/null
sudo docker run -d -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer-ce
# ZRAM fix
sudo systemctl stop dphys-swapfile 2>/dev/null
sudo systemctl disable dphys-swapfile 2>/dev/null
sudo systemctl restart zramswap

# --- [SEKTOR 07: GHOST TUNNEL] ---
echo -e "${G}[7] Instalace Ghost Tunnel (Tailscale)...${NC}"
curl -fsSL https://tailscale.com/install.sh | sh
# Po restartu budeš muset zadat: sudo tailscale up

# --- [SEKTOR 08: TELEGRAM NERVOVÝ SYSTÉM] ---
echo -e "${G}[8] Nastavení Telegram Notifikátoru...${NC}"
cat > ~/genesis/tools/tele-notify.sh <<EOF
#!/bin/bash
# Vyplň své údaje pro aktivaci
TOKEN="TVUJ_BOT_TOKEN"
CHAT_ID="TVOJE_CHAT_ID"
MESSAGE="🚨 GENESIS EXPANSION COMPLETE: \$(hostname) is fully armed."
if [ "\$TOKEN" != "TVUJ_BOT_TOKEN" ]; then
    curl -s -X POST "https://api.telegram.org/bot\$TOKEN/sendMessage" -d "chat_id=\$CHAT_ID&text=\$MESSAGE"
fi
EOF
chmod +x ~/genesis/tools/tele-notify.sh

# --- [SEKTOR 09: CYBER-SECURITY AUDIT] ---
echo -e "${G}[9] Integrace Security Tools (Nmap Automation)...${NC}"
cat > ~/genesis/tools/net_audit.sh <<EOF
#!/bin/bash
DATE=\$(date +%F_%H-%M)
echo "--- SECURITY AUDIT \$DATE ---" > $LOG_DIR/security_\$DATE.log
nmap -sV -T4 \$(hostname -I | awk '{print \$1}')/24 >> $LOG_DIR/security_\$DATE.log
echo "Audit dokončen: $LOG_DIR/security_\$DATE.log"
EOF
chmod +x ~/genesis/tools/net_audit.sh

# --- [SEKTOR 10: AI ANALÝZA SYSTÉMU] ---
echo -e "${G}[10] Aktivace AI Log Analyzeru...${NC}"
# Tento python skript propojí Dashboard s Ollamou pro analýzu chyb
cat > ~/genesis/tools/log_ai.py <<EOF
import requests, os
def analyze():
    log_path = "$LOG_DIR/genesis_v8_global.log"
    if os.path.exists(log_path):
        with open(log_path, "r") as f:
            data = f.readlines()[-30:]
        prompt = f"Identify errors in these logs and suggest Linux commands to fix them: {' '.join(data)}"
        try:
            r = requests.post("http://localhost:11434/api/generate", json={"model": "llama3", "prompt": prompt, "stream": False})
            print(r.json().get('response', 'AI neodpovídá.'))
        except: print("Ollama není dostupná.")
if __name__ == "__main__": analyze()
EOF

# --- [FINÁLNÍ UPDATE DASHBOARDU] ---
echo -e "${G}Upgraduji HUD na verzi 'Omni-Control'...${NC}"
# (Zde by byl kód pro přidání tlačítek 'Audit' a 'Analyze' do tvého genesis_hud.py)

echo -e "${B}--------------------------------------------------${NC}"
echo -e "${G}SEKTOR 2 (EXPANSION) BYL NAINSTALOVÁN.${NC}"
echo -e "Zadej 'sudo tailscale up' pro aktivaci Ghost Tunnel."
echo -e "${B}--------------------------------------------------${NC}"
