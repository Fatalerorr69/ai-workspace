#!/bin/bash
# Soubor: extensions.sh
# Popis: Instalační skript pro rozšíření a optimalizaci GameHub
# Spuštění: sudo ./extensions.sh

# Nastavení cesty
export INSTALL_ROOT="$(dirname "$(readlink -f "$0")")"
export LOG_FILE="/var/log/gamehub-extensions.log"

# Import konfigurace a funkcí (používá existující soubory z předchozí instalace)
if [ -f "$INSTALL_ROOT/lib/config.sh" ]; then
    source "$INSTALL_ROOT/lib/config.sh"
    source "$INSTALL_ROOT/lib/functions.sh"
else
    echo "CHYBA: Nenalezeny knihovny. Spouštíte skript ve správné složce 'gamehub-install'?"
    exit 1
fi

# ==============================================================================
# HLAVNÍ SMYČKA ROZŠÍŘENÍ
# ==============================================================================

clear
echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════╗"
echo "║     GameHub Extensions & Optimization        ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"

# 1. Kontrola základní instalace
if [ ! -d "$INSTALL_DIR" ]; then
    error "Základní instalace GameHub nebyla nalezena v $INSTALL_DIR. Nejdříve spusťte install.sh."
fi

# 2. Bezpečnostní Hardening
section_start "Hardening a Zabezpečení"
source "$INSTALL_ROOT/modules/10_security.sh"
install_certbot
configure_fail2ban
harden_ssh
section_end "Zabezpečení aplikováno"

# 3. Optimalizace Výkonu
section_start "Optimalizace Systému"
source "$INSTALL_ROOT/modules/11_performance.sh"
setup_swap
tune_kernel
section_end "Systém optimalizován"

# 4. Docker a Kontejnerizace
section_start "Docker a Portainer"
source "$INSTALL_ROOT/modules/12_docker.sh"
install_docker
deploy_portainer
section_end "Docker prostředí připraveno"

# 5. Monitoring a Správa
section_start "Monitoring (Netdata & Cockpit)"
source "$INSTALL_ROOT/modules/13_monitoring.sh"
install_netdata
install_cockpit
section_end "Monitoring aktivní"

# 6. Zálohování
section_start "Strategie Zálohování"
source "$INSTALL_ROOT/modules/14_backup.sh"
setup_backup_tools
create_backup_cron
section_end "Zálohování nastaveno"

# Závěr
print_success "Rozšíření byla úspěšně nainstalována!"
echo -e "${YELLOW}Důležité:${NC} Pro dokončení SSL certifikace spusťte příkaz 'certbot --nginx' ručně."
