#!/bin/bash
# Soubor: advanced.sh
# Popis: Instalace pokročilých nástrojů a doplňkového software
# Spuštění: sudo ./advanced.sh

export INSTALL_ROOT="$(dirname "$(readlink -f "$0")")"
export LOG_FILE="/var/log/gamehub-advanced.log"

# Import knihoven
if [ -f "$INSTALL_ROOT/lib/config.sh" ]; then
    source "$INSTALL_ROOT/lib/config.sh"
    source "$INSTALL_ROOT/lib/functions.sh"
else
    echo "CHYBA: Spusťte skript ze složky gamehub-install."
    exit 1
fi

clear
echo -e "${MAGENTA}"
echo "╔══════════════════════════════════════════════╗"
echo "║     GameHub Advanced Tools & Ecosystem       ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"

# Kontrola předchozích fází
if [ ! -f "/usr/bin/docker" ]; then
    echo -e "${YELLOW}[WARN] Docker nebyl detekován. Některé funkce nemusí fungovat správně.${NC}"
    sleep 3
fi

# 20. LinuxGSM (Správa herních serverů)
section_start "LinuxGSM - Game Server Manager"
source "$INSTALL_ROOT/modules/20_linuxgsm.sh"
install_linuxgsm
section_end "LinuxGSM připraven"

# 21. FileBrowser (Webová správa souborů)
section_start "FileBrowser (Web FileManager)"
source "$INSTALL_ROOT/modules/21_filebrowser.sh"
install_filebrowser
configure_filebrowser_service
section_end "FileBrowser běží na portu 8080"

# 22. Voice Chat (Mumble Server)
section_start "Mumble Server (VoIP)"
source "$INSTALL_ROOT/modules/22_voice.sh"
install_mumble
section_end "Mumble Server nainstalován"

# 23. Vzdálená plocha (XRDP)
section_start "Desktop GUI & RDP"
source "$INSTALL_ROOT/modules/23_desktop.sh"
install_desktop_environment
setup_xrdp
section_end "RDP přístup povolen"

# 24. VPN Mesh (Tailscale)
section_start "Tailscale VPN"
source "$INSTALL_ROOT/modules/24_vpn.sh"
install_tailscale
section_end "Tailscale nainstalován"

# 25. Automatická údržba
section_start "Automatická údržba"
source "$INSTALL_ROOT/modules/25_maintenance.sh"
setup_auto_updates
setup_log_rotation
section_end "Údržba nastavena"

print_success "Pokročilá instalace dokončena!"
echo -e "${YELLOW}Nové služby:${NC}"
echo "  • Soubory:     http://$(hostname -I | awk '{print $1}'):8080"
echo "  • RDP:         $(hostname -I | awk '{print $1}'):3389"
echo "  • VPN:         sudo tailscale up"
