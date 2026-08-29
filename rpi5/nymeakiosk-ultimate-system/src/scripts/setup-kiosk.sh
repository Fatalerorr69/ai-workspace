#!/bin/bash
################################################################################
# Kiosk Setup Script - Nastavení režimu kiosku
# Verze: 3.5.0
################################################################################

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="/var/log/nymea-kiosk/kiosk-setup.log"

# Barvy
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $@" | tee -a "${LOG_FILE}"
}

log_info() { echo -e "${BLUE}ℹ${NC} $@"; }
log_success() { echo -e "${GREEN}✓${NC} $@"; }
log_error() { echo -e "${RED}✗${NC} $@" >&2; }

################################################################################
# PARSOVÁNÍ ARGUMENTŮ
################################################################################

ORIENTATION="landscape"
AUTOSTART="true"
KIOSK_URL="http://localhost:8080"

while [[ $# -gt 0 ]]; do
    case $1 in
        --orientation)
            ORIENTATION="$2"
            shift 2
            ;;
        --autostart)
            AUTOSTART="$2"
            shift 2
            ;;
        --url)
            KIOSK_URL="$2"
            shift 2
            ;;
        *)
            log_error "Neznámý argument: $1"
            exit 1
            ;;
    esac
done

################################################################################
# VALIDACE
################################################################################

validate_orientation() {
    if [[ ! "$ORIENTATION" =~ ^(landscape|portrait)$ ]]; then
        log_error "Neplatná orientace: $ORIENTATION (landscape|portrait)"
        exit 1
    fi
}

################################################################################
# KONFIGURACE
################################################################################

setup_chromium_kiosk() {
    log_info "Konfigurace Chromium pro kiosk režim..."
    
    local kiosk_user="nymea-kiosk"
    local home_dir="/home/${kiosk_user}"
    
    # Vytvoření uživatele pro kiosk (pokud neexistuje)
    if ! id "$kiosk_user" &>/dev/null; then
        useradd -m -s /bin/bash "$kiosk_user"
        log_success "Uživatel '$kiosk_user' vytvořen"
    fi
    
    # Vytvoření desktop konfigurace
    mkdir -p "${home_dir}/.config/autostart"
    
    cat > "${home_dir}/.config/autostart/kiosk.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Nymea Kiosk
Exec=/usr/local/bin/start-kiosk.sh
NoDisplay=true
StartupNotify=false
EOF
    
    # Skript pro start kiosku
    cat > /usr/local/bin/start-kiosk.sh << 'EOFSCRIPT'
#!/bin/bash
# Čekání na X server
sleep 3
# Spuštění Chromium v kiosk režimu
chromium-browser \
    --new-window \
    --start-fullscreen \
    --kiosk \
    --noerrdialogs \
    --disable-translate \
    --disable-background-networking \
    --disable-background-timer-throttling \
    --disable-default-apps \
    "$KIOSK_URL"
EOFSCRIPT
    
    chmod +x /usr/local/bin/start-kiosk.sh
    chown -R "${kiosk_user}:${kiosk_user}" "${home_dir}"
    
    log_success "Chromium kiosk konfigurován"
}

setup_display_rotation() {
    log_info "Nastavení rotace displeje na: $ORIENTATION"
    
    # Zjistění HDMI portu
    local hdmi_port=$(tvservice -l 2>/dev/null | grep HDMI | head -1 | cut -d' ' -f2)
    
    if [ -z "$hdmi_port" ]; then
        log_error "HDMI port nenalezen"
        return 1
    fi
    
    case $ORIENTATION in
        landscape)
            tvservice -o 0
            log_success "Orientace nastavena na landscape"
            ;;
        portrait)
            tvservice -o 1  # 90° otočení
            log_success "Orientace nastavena na portrait"
            ;;
    esac
}

setup_autostart() {
    log_info "Nastavení autospouštění..."
    
    if [ "$AUTOSTART" = "true" ]; then
        systemctl enable lightdm || log_error "Chyba při enable lightdm"
        
        # Vytvoření systemd služby
        cat > /etc/systemd/system/nymea-kiosk.service << EOF
[Unit]
Description=Nymea Kiosk Display
After=network.target

[Service]
Type=simple
User=nymea-kiosk
ExecStart=/usr/bin/startx /etc/X11/Xsession /usr/local/bin/start-kiosk.sh
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
        
        systemctl daemon-reload
        systemctl enable nymea-kiosk
        log_success "Autostart konfigurován"
    fi
}

################################################################################
# HLAVNÍ SPUŠTĚNÍ
################################################################################

main() {
    log_info "=== Nastavení Nymea Kiosk ==="
    log_info "Orientace: $ORIENTATION"
    log_info "Autostart: $AUTOSTART"
    log_info "URL: $KIOSK_URL"
    
    validate_orientation
    setup_chromium_kiosk
    setup_display_rotation
    setup_autostart
    
    log_success "Kiosk setup dokončen"
}

main "$@"
