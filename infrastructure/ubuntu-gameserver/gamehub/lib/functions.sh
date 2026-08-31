#!/bin/bash
# Soubor: lib/functions.sh

# Barvy
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    log "[INFO] $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
    log "[OK] $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    log "[ERROR] $1"
    exit 1
}

section_start() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
    log "=== START: $1 ==="
}

section_end() {
    echo -e "${GREEN}✓ $1${NC}"
    log "=== END: $1 ==="
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "Tento skript musí běžet jako root (sudo)."
    fi
}

check_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
             echo -e "${YELLOW}[WARN] Tento skript je optimalizován pro Ubuntu/Debian.${NC}"
             sleep 3
        fi
    fi
}

check_resources() {
    RAM=$(free -m | awk '/^Mem:/{print $2}')
    if [ "$RAM" -lt 2048 ]; then
        echo -e "${YELLOW}[WARN] Málo RAM ($RAM MB). Doporučeno min. 4GB pro herní servery.${NC}"
        sleep 3
    fi
}

print_banner() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║       GameHub Ultimate Installer v3.1        ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_access_info() {
    IP=$(hostname -I | awk '{print $1}')
    echo ""
    echo "╔══════════════════════════════════════════════╗"
    echo "║             Instalace Dokončena              ║"
    echo "╠══════════════════════════════════════════════╣"
    echo "║ Dashboard:   http://$IP                      ║"
    echo "║ API:         http://$IP:$PORT_API            ║"
    echo "║ Sunshine:    https://$IP:$PORT_STREAM        ║"
    echo "║                                              ║"
    echo "║ DB User:     $DB_USER                        ║"
    echo "║ DB Pass:     (uloženo v $CONFIG_DIR/db.env)  ║"
    echo "╚══════════════════════════════════════════════╝"
    echo ""
}

print_success() {
    echo -e "${GREEN}${BOLD} $1 ${NC}"
    log "SUCCESS: $1"
}
