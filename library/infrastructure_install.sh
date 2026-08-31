#!/bin/bash
# Soubor: install.sh
# Popis: Hlavní řídící skript pro instalaci GameHub
# Spuštění: sudo ./install.sh

# Nastavení cesty
export INSTALL_ROOT="$(dirname "$(readlink -f "$0")")"
export LOG_FILE="/var/log/gamehub-install.log"

# Import konfigurace a funkcí
source "$INSTALL_ROOT/lib/config.sh"
source "$INSTALL_ROOT/lib/functions.sh"

# ==============================================================================
# HLAVNÍ SMYČKA
# ==============================================================================

clear
print_banner

# 1. Kontrola prostředí
section_start "Kontrola prostředí"
check_root
check_os
check_resources
section_end "Prostředí OK"

# 2. Příprava systému
section_start "Příprava systému"
source "$INSTALL_ROOT/modules/00_system.sh"
update_system
install_dependencies
configure_firewall
create_users_groups
section_end "Systém připraven"

# 3. Databáze
section_start "Instalace databází"
source "$INSTALL_ROOT/modules/01_database.sh"
install_mariadb
install_redis
configure_databases
section_end "Databáze nainstalovány"

# 4. GameHub Core (API)
section_start "Instalace GameHub Core"
source "$INSTALL_ROOT/modules/02_core.sh"
install_nodejs
setup_core_api
setup_systemd
section_end "Core nainstalováno"

# 5. Dashboard (Web)
section_start "Instalace Dashboardu"
source "$INSTALL_ROOT/modules/03_dashboard.sh"
setup_nginx
deploy_frontend
section_end "Dashboard nasazen"

# 6. Herní moduly (Volitelné)
section_start "Instalace herních modulů"
source "$INSTALL_ROOT/modules/04_gaming.sh"
install_steam
install_emulators
install_streaming
section_end "Herní moduly hotovy"

# Závěr
print_success "Instalace dokončena!"
print_access_info
