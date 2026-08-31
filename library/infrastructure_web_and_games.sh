#!/bin/bash
# Soubor: web_and_games.sh
# Popis: Webová GUI rozhraní a hloubkové nastavení her
# Spuštění: sudo ./web_and_games.sh

export INSTALL_ROOT="$(dirname "$(readlink -f "$0")")"
source "$INSTALL_ROOT/lib/config.sh"
source "$INSTALL_ROOT/lib/functions.sh"

clear
print_banner
info "Spouštím Fázi 4: WebGUI & Game Engine Tuning"

# 30. Nginx Proxy Manager (Grafická správa domén a SSL)
section_start "Nginx Proxy Manager"
source "$INSTALL_ROOT/modules/30_proxy_manager.sh"
deploy_proxy_manager
section_end "Proxy Manager běží na portu 81"

# 31. Pterodactyl Panel (Panel pro herní servery)
section_start "Pterodactyl Server Panel"
source "$INSTALL_ROOT/modules/31_pterodactyl.sh"
install_pterodactyl_dependencies
# Poznámka: Kompletní instalace panelu vyžaduje interakci uživatele (nastavení hesel)
section_end "Základy panelu připraveny"

# 32. Herní Servery - Hloubkové nastavení
section_start "Optimalizace Herních Serverů"
source "$INSTALL_ROOT/modules/32_game_engine.sh"
setup_minecraft_paper
setup_steam_autoupdate
section_end "Herní engine optimalizován"

# 33. Rozšířené Web API
section_start "Web-GUI Rozšíření"
source "$INSTALL_ROOT/modules/33_web_features.sh"
setup_web_terminal
section_end "Webové funkce přidány"

print_success "Fáze 4 dokončena. Váš server je nyní plnohodnotný herní hosting."
