#!/bin/bash
# Soubor: gaming_experience.sh
# Popis: Vylepšené GUI a modul pro stahování/správu her
# Spuštění: sudo ./gaming_experience.sh

export INSTALL_ROOT="$(dirname "$(readlink -f "$0")")"
source "$INSTALL_ROOT/lib/config.sh"
source "$INSTALL_ROOT/lib/functions.sh"

clear
print_banner
info "Spouštím Fázi 7: Vylepšené prostředí a Content Manager"

# 70. Moderní Webové GUI (Vylepšení dashboardu)
section_start "Moderní Web-GUI (GameHub OS Style)"
source "$INSTALL_ROOT/modules/70_modern_gui.sh"
update_dashboard_to_v3
section_end "Dashboard vylepšen na verzi 3.0"

# 71. Game Downloader & Manager (Podpora pro Steam, Itch.io, ROMs)
section_start "Game Content Manager"
source "$INSTALL_ROOT/modules/71_game_manager.sh"
install_game_fetcher
setup_auto_installer
section_end "Content Manager připraven"

# 72. Metadata & Scraper (Obrázky a info o hrách)
section_start "Metadata Scraper"
source "$INSTALL_ROOT/modules/72_scraper.sh"
install_skraper_cli
section_end "Scraper nakonfigurován"

print_success "Herní ekosystém je nyní kompletní a připraven k akci!"
