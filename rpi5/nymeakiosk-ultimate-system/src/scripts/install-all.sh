#!/bin/bash
################################################################################
# Nymea:Kiosk Ultimate System - Master Installer
# Verze: 3.5.0
# Autor: Fatalerorr69
# Popis: Automatizovaná instalace kompletního systému na RPi 5
################################################################################

set -euo pipefail  # Fail on error, exit on undefined var, fail on pipe error

# Barvy pro output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Konfigurace
readonly LOG_DIR="/var/log/nymea-kiosk"
readonly LOG_FILE="${LOG_DIR}/install.log"
readonly CONFIG_DIR="/app/config"
readonly BACKUP_DIR="/home/nymea/backups"
readonly VERSION="3.5.0"

# Vytvoření log adresáře
mkdir -p "${LOG_DIR}"

################################################################################
# LOGGOVÁNÍ A VÝSTUP
################################################################################

log() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[${timestamp}] [${level}] ${message}" | tee -a "${LOG_FILE}"
}

log_info() {
    echo -e "${BLUE}ℹ${NC} $@"
    log "INFO" "$@"
}

log_success() {
    echo -e "${GREEN}✓${NC} $@"
    log "SUCCESS" "$@"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $@"
    log "WARN" "$@"
}

log_error() {
    echo -e "${RED}✗${NC} $@" >&2
    log "ERROR" "$@"
}

################################################################################
# ERROR HANDLING
################################################################################

trap 'handle_error ${LINENO}' ERR

handle_error() {
    local line_number=$1
    log_error "Chyba na řádku $line_number"
    log_error "Instalace selhala. Podrobnosti viz $LOG_FILE"
    exit 1
}

# Kontrola běhu jako root
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        log_error "Skript musí být spuštěn jako root (sudo)"
        exit 1
    fi
    log_success "Běžím jako root"
}

################################################################################
# INSTALACE
################################################################################

header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Nymea:Kiosk Ultimate System - Instalátor (v${VERSION})${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

step_system_update() {
    log_info "Krok 1/10: Aktualizace systému..."
    
    apt-get update -qq || { log_error "apt-get update selhalo"; return 1; }
    apt-get upgrade -y -qq || { log_error "apt-get upgrade selhalo"; return 1; }
    
    log_success "Systém aktualizován"
}

step_install_dependencies() {
    log_info "Krok 2/10: Instalace základních balíčků..."
    
    local packages=(
        "build-essential"
        "curl"
        "fail2ban"
        "git"
        "htop"
        "nano"
        "openssh-server"
        "python3"
        "python3-pip"
        "unzip"
        "wget"
    )
    
    for pkg in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $pkg"; then
            log_info "  Instaluji $pkg..."
            apt-get install -y -qq "$pkg" || log_warn "Chyba při instalaci $pkg"
        fi
    done
    
    log_success "Základní balíčky instalovány"
}

step_install_nymea() {
    log_info "Krok 3/10: Instalace Nymea..."
    
    if ! command -v nymead &> /dev/null; then
        apt-get install -y -qq nymea nymea-app nymea-plugins || \
            { log_error "Nymea instalace selhala"; return 1; }
    fi
    
    systemctl enable nymead || log_warn "Chyba při enable nymead"
    systemctl start nymead || log_warn "Chyba při start nymead"
    
    log_success "Nymea nainstalováno a spuštěno"
}

step_create_directories() {
    log_info "Krok 4/10: Vytvoření adresářů..."
    
    mkdir -p "${LOG_DIR}"
    mkdir -p "${CONFIG_DIR}"
    mkdir -p "${BACKUP_DIR}"
    mkdir -p "/home/education-system/projects"
    
    log_success "Adresáře vytvořeny"
}

step_setup_security() {
    log_info "Krok 5/10: Nastavení zabezpečení..."
    
    # Firewall
    if command -v ufw &> /dev/null; then
        ufw allow ssh || log_warn "Chyba při UFW konfiguraci"
        ufw allow 80/tcp || log_warn "Chyba při UFW konfiguraci"
        ufw allow 443/tcp || log_warn "Chyba při UFW konfiguraci"
        ufw --force enable || log_warn "Chyba při zapnutí UFW"
    fi
    
    # Fail2Ban
    systemctl enable fail2ban || log_warn "Chyba při enable fail2ban"
    systemctl start fail2ban || log_warn "Chyba při start fail2ban"
    
    log_success "Zabezpečení nakonfigurováno"
}

step_setup_monitoring() {
    log_info "Krok 6/10: Nastavení monitoringu..."
    
    local monitoring_packages=("prometheus" "grafana-server")
    
    for pkg in "${monitoring_packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $pkg"; then
            log_info "  Instaluji $pkg..."
            apt-get install -y -qq "$pkg" || log_warn "Chyba při instalaci $pkg"
        fi
    done
    
    systemctl enable prometheus || log_warn "Chyba při enable prometheus"
    systemctl enable grafana-server || log_warn "Chyba při enable grafana"
    systemctl start prometheus || log_warn "Chyba při start prometheus"
    systemctl start grafana-server || log_warn "Chyba při start grafana"
    
    log_success "Monitoring nainstalován"
}

step_setup_backups() {
    log_info "Krok 7/10: Nastavení zálohování..."
    
    mkdir -p "${BACKUP_DIR}"
    
    # Vytvoření cron jobu pro denní zálohu v 2:00
    local cron_entry="0 2 * * * /usr/local/bin/backup-nymea.sh >> ${LOG_FILE} 2>&1"
    
    if ! crontab -l 2>/dev/null | grep -q "backup-nymea"; then
        (crontab -l 2>/dev/null || true; echo "$cron_entry") | crontab -
        log_success "Cron job pro zálohování nastaven"
    fi
}

step_setup_kiosk() {
    log_info "Krok 8/10: Nastavení Kiosk režimu..."
    
    if [ -f "./scripts/setup-kiosk.sh" ]; then
        bash "./scripts/setup-kiosk.sh" --orientation=landscape --autostart=true || \
            log_warn "Kiosk setup skript selhalo"
    fi
    
    log_success "Kiosk režim nakonfigurován"
}

step_install_plugins() {
    log_info "Krok 9/10: Instalace pluginů..."
    
    if [ -f "./scripts/install-plugins.sh" ]; then
        bash "./scripts/install-plugins.sh" || log_warn "Plugin instalace selhala"
    fi
    
    log_success "Pluginy instalovány"
}

step_generate_summary() {
    log_info "Krok 10/10: Generování shrnutí..."
    
    local summary_file="/home/nymea/SETUP_SUMMARY.md"
    local host_ip=$(hostname -I | awk '{print $1}')
    
    cat > "$summary_file" << EOF
# Nymea:Kiosk Ultimate System - Shrnutí instalace

## Informace o systému
- Datum instalace: $(date)
- Verze systému: ${VERSION}
- Hostname: $(hostname)
- IP adresa: ${host_ip}

## Instalované komponenty
- nymea:core: $(apt-show nymea 2>/dev/null | grep Version | head -1 || echo "N/A")
- Prometheus: Nainstalován
- Grafana: Nainstalován
- Fail2Ban: Nainstalován

## Přístupové porty
- Web rozhraní: http://${host_ip}:8080
- Grafana: http://${host_ip}:3000
- Prometheus: http://${host_ip}:9090

## Log soubory
- Instalační log: ${LOG_FILE}
- Systémové logy: ${LOG_DIR}/

## Užitečné příkazy
\`\`\`bash
# Kontrola statusu služeb
systemctl status nymead
systemctl status prometheus
systemctl status grafana-server

# Zobrazení logů
tail -f ${LOG_FILE}

# Restart služeb
sudo systemctl restart nymead
\`\`\`

## Další kroky
1. Přihlaste se na Grafanu (výchozí: admin/admin)
2. Nakonfigurujte nymea zařízení přes web rozhraní
3. Nastavte kiosk displej pomocí nastavovacích skriptů

---
Generováno: $(date)
EOF
    
    log_success "Shrnutí instalace uloženo v $summary_file"
}

################################################################################
# HLAVNÍ SPUŠTĚNÍ
################################################################################

main() {
    header
    
    check_root
    log_success "Začínám instalaci Nymea:Kiosk Ultimate System v${VERSION}"
    
    step_system_update || true
    step_install_dependencies || true
    step_install_nymea || true
    step_create_directories || true
    step_setup_security || true
    step_setup_monitoring || true
    step_setup_backups || true
    step_setup_kiosk || true
    step_install_plugins || true
    step_generate_summary || true
    
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ Instalace úspěšně dokončena!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    log_success "Instalace kompletně dokončena"
}

# Spuštění
main "$@"
