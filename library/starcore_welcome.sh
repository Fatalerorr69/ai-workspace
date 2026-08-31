#!/bin/bash
# STARCORE Mobile Welcome Screen v2.2

cd ~/STARCORE 2>/dev/null || return

# ASCII Logo
echo ""
echo -e "\033[1;36m"
echo "  ███████╗████████╗ █████╗ ██████╗  ██████╗ ██████╗ ███████╗"
echo "  ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔═══██╗██╔══██╗██╔════╝"
echo "  ███████╗   ██║   ███████║██████╔╝██║   ██║██████╔╝█████╗  "
echo "  ╚════██║   ██║   ██╔══██║██╔══██╗██║   ██║██╔══██╗██╔══╝  "
echo "  ███████║   ██║   ██║  ██║██║  ██║╚██████╔╝██║  ██║███████╗"
echo "  ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝"
echo -e "\033[0m"
echo -e "\033[1;33m  STARCORE Mobile v0.1.0 – Termux Edition\033[0m"
echo ""

# Získání statusu
VERSION=$(./starcore version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "N/A")
SERVICES=$(./starcore status 2>/dev/null | grep -c "running" | tr -d ' ' | tr -d '\n')
if [ -z "$SERVICES" ]; then SERVICES=0; fi
HIVE=$(./starcore hive-status 2>/dev/null | grep "Engine" | grep -o "Running" || echo "Stopped")
AI=$(./starcore ai-status 2>/dev/null | grep "Runtime" | grep -o "Running" || echo "Stopped")
IP=$(ifconfig 2>/dev/null | grep -oE 'inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | grep -v 127.0.0.1 | head -1 | cut -d' ' -f2)
if [ -z "$IP" ]; then IP="N/A"; fi

echo -e "\033[1;34m┌─────────────────────────────────────────────────────┐\033[0m"
echo -e "\033[1;34m│\033[0m  \033[1;32m📊 STARCORE STATUS\033[0m                                \033[1;34m│\033[0m"
echo -e "\033[1;34m├─────────────────────────────────────────────────────┤\033[0m"
printf "\033[1;34m│\033[0m  Verze: \033[1;33m%-35s\033[0m \033[1;34m│\033[0m\n" "$VERSION"
printf "\033[1;34m│\033[0m  Služby: \033[1;33m%-35s\033[0m \033[1;34m│\033[0m\n" "$SERVICES běží"
printf "\033[1;34m│\033[0m  HIVE Engine: \033[1;33m%-35s\033[0m \033[1;34m│\033[0m\n" "$HIVE"
printf "\033[1;34m│\033[0m  AI Runtime: \033[1;33m%-35s\033[0m \033[1;34m│\033[0m\n" "$AI"
printf "\033[1;34m│\033[0m  IP adresa: \033[1;33m%-35s\033[0m \033[1;34m│\033[0m\n" "$IP"
echo -e "\033[1;34m└─────────────────────────────────────────────────────┘\033[0m"
echo ""

echo -e "\033[1;36m📌 DOSTUPNÉ PŘÍKAZY:\033[0m"
echo -e "  \033[1;32mstarcore\033[0m version | info | doctor | verify"
echo -e "  \033[1;32mstarcore\033[0m start | stop | status | logs | restart"
echo -e "  \033[1;32mstarcore\033[0m hive-start | hive-status | hive-stop | hive-schedule"
echo -e "  \033[1;32mstarcore\033[0m ai-start | ai-stop | ai-status | ai-query | ai-test"
echo -e "  \033[1;32mstarcore\033[0m ai-config <key> <value>"
echo ""

echo -e "\033[1;33m💡 TIPY:\033[0m"
echo -e "  • Dashboard: \033[1;32m./starcore start dashboard\033[0m → http://$IP:8000"
echo -e "  • OpenRouter klíč: \033[1;34mhttps://openrouter.ai/keys\033[0m"
echo ""

if [ "$SERVICES" -eq 0 ]; then
    echo -e "\033[1;31m⚠ Žádné služby neběží – spusť: ./starcore start test\033[0m"
fi
if [ "$AI" = "Stopped" ]; then
    echo -e "\033[1;31m⚠ AI Runtime je zastaven – spusť: ./starcore ai-start\033[0m"
fi

echo ""
echo -e "\033[1;30m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
