#!/bin/bash
# Soubor: gamehub.sh
# Popis: Master Control pro GameHub Ultimate
# Použití: sudo ./gamehub.sh

export INSTALL_ROOT="$(dirname "$(readlink -f "$0")")"
source "$INSTALL_ROOT/lib/config.sh"
source "$INSTALL_ROOT/lib/functions.sh"

# Hlavní menu
show_menu() {
    clear
    echo -e "${MAGENTA}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║       GAMEHUB ULTIMATE MASTER CONTROL        ║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════════╝${NC}"
    echo -e " 1)  [Fáze 1-3] Základní Instalace & Core"
    echo -e " 2)  [Fáze 4-5] Hybrid Cloud & Pterodactyl"
    echo -e " 3)  [Fáze 6-7] Drivers, BIOS & Modern GUI"
    echo -e " ----------------------------------------------"
    echo -e " 4)  🚀 CONTENT MANAGER (Stáhnout hry/servery)"
    echo -e " 5)  🛠️  SYSTÉMOVÁ ÚDRŽBA (Update, Clean, Logy)"
    echo -e " 6)  📊 MONITORING (Glances / Netdata)"
    echo -e " 0)  Ukončit"
    echo -n " Vyberte možnost: "
}

# --- LOGIKA CONTENT MANAGERA ---
content_manager() {
    clear
    echo "=== GAMEHUB CONTENT MANAGER ==="
    echo "1) Instalovat Minecraft (Paper)"
    echo "2) Instalovat Counter-Strike 2 (SteamCMD)"
    echo "3) Stáhnout Retro ROM balíček"
    echo "4) Zpět do menu"
    read -p "Volba: " cm_choice
    
    case $cm_choice in
        1) bash "$INSTALL_ROOT/modules/32_game_engine.sh" ;; # Spustí specifickou funkci
        2) bash "$INSTALL_ROOT/modules/20_linuxgsm.sh" ;;
        3) bash "$INSTALL_ROOT/modules/62_roms.sh" ;;
    esac
}

# Spouštěcí smyčka
while true; do
    show_menu
    read choice
    case $choice in
        1) sudo bash ./install.sh && sudo bash ./extensions.sh ;;
        2) sudo bash ./web_and_games.sh && sudo bash ./hybrid_cloud.sh ;;
        3) sudo bash ./game_ready.sh && sudo bash ./gaming_experience.sh ;;
        4) content_manager ;;
        5) sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y ;;
        6) glances ;;
        0) exit 0 ;;
        *) echo "Neplatná volba" ; sleep 1 ;;
    esac
done
