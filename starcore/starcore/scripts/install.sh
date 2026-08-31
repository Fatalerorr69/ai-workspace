#!/bin/bash
# STARCORE Mobile – Instalační skript
# Verze 1.0

set -euo pipefail

# Barvy
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}  STARCORE Mobile – Instalace${NC}"
echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════════${NC}"
echo ""

# 1. Kontrola Termux
if ! command -v termux-info &> /dev/null; then
    echo -e "${RED}❌ Tento skript je určen pro Termux.${NC}"
    exit 1
fi

# 2. Aktualizace balíčků
echo -e "${CYAN}📦 Aktualizace balíčků...${NC}"
pkg update -y && pkg upgrade -y

# 3. Instalace základních balíčků
echo -e "${CYAN}📦 Instalace základních balíčků...${NC}"
pkg install -y python git tmux openssh rsync curl wget termux-api termux-tools

# 4. Instalace Python balíčků
echo -e "${CYAN}📦 Instalace Python balíčků...${NC}"
pip install --upgrade pip
pip install typer rich httpx fastapi uvicorn jinja2 apscheduler sqlite-utils openai

# 5. Kontrola existujícího adresáře
if [ -d "$HOME/STARCORE" ] && [ "$PWD" != "$HOME/STARCORE" ]; then
    echo -e "${YELLOW}⚠️  Adresář STARCORE již existuje.${NC}"
    echo -e "${CYAN}Přejíždím do existujícího adresáře...${NC}"
    cd "$HOME/STARCORE"
fi

# 6. Nastavení oprávnění
chmod +x starcore
chmod +x scripts/*.sh

# 7. Nastavení Termux:Boot
mkdir -p ~/.termux/boot
cat > ~/.termux/boot/starcore.sh << 'EOL'
#!/bin/bash
cd ~/STARCORE
./starcore start test
./starcore start dashboard
./starcore hive-start
./starcore ai-start
if command -v ollama &>/dev/null; then
    nohup ollama serve > /dev/null 2>&1 &
fi
termux-notification --title "STARCORE" --content "Systém byl spuštěn" --priority high
EOL
chmod +x ~/.termux/boot/starcore.sh

# 8. Spuštění inicializace
echo -e "${CYAN}🚀 Spouštím inicializaci...${NC}"
./starcore doctor
./starcore verify

# 9. Zobrazení dokončení
echo ""
echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}  ✅ STARCORE Mobile byl úspěšně nainstalován!${NC}"
echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "📌 Základní příkazy:"
echo -e "  ${CYAN}starcore${NC} status     – stav služeb"
echo -e "  ${CYAN}starcore${NC} doctor     – diagnostika"
echo -e "  ${CYAN}starcore${NC} battery    – stav baterie"
echo -e "  ${CYAN}starcore${NC} --help     – nápověda"
echo ""
IP=$(ifconfig 2>/dev/null | grep -oE 'inet [0-9.]+' | grep -v 127.0.0.1 | head -1 | cut -d' ' -f2)
echo -e "🌐 Dashboard: http://${IP:-localhost}:8000"
echo ""
echo -e "📖 Pro více informací viz README.md"
