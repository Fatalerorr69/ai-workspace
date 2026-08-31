#!/bin/bash
# Soubor: final_addons.sh
# Popis: Integrace Mobile PWA, Discordu a Auto-Recovery
# Spuštění: sudo ./final_addons.sh

export INSTALL_ROOT="$(dirname "$(readlink -f "$0")")"
source "$INSTALL_ROOT/lib/config.sh"
source "$INSTALL_ROOT/lib/functions.sh"

clear
print_banner
info "Instalace finálních doplňků GameHub"

# 90. Mobile PWA Integration
section_start "Mobile Gateway (PWA)"
source "$INSTALL_ROOT/modules/90_mobile.sh"
setup_mobile_manifest
section_end "Mobilní přístup připraven"

# 91. Discord Integration
section_start "Discord Sync & Presence"
source "$INSTALL_ROOT/modules/91_discord.sh"
setup_discord_bot_core
section_end "Discord modul aktivován"

# 92. Game Workshop Automator
section_start "Modding & Workshop Automator"
source "$INSTALL_ROOT/modules/92_workshop.sh"
install_workshop_tools
section_end "Workshop manager připraven"

# 93. Watchdog & Recovery
section_start "Auto-Recovery System (Watchdog)"
source "$INSTALL_ROOT/modules/93_recovery.sh"
setup_watchdog_service
section_end "Systém automatické obnovy běží"

print_success "Všechny doplňky byly úspěšně integrovány!"
