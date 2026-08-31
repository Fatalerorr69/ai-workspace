#!/bin/bash
################################################################################
# Backup & Restore Script - Správa záloh
# Verze: 3.5.0
################################################################################

set -euo pipefail

readonly BACKUP_DIR="/home/nymea/backups"
readonly LOG_FILE="/var/log/nymea-kiosk/backup.log"
readonly RETENTION_DAYS=30

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $@" | tee -a "${LOG_FILE}"
}

log_info() { echo "ℹ $@"; }
log_success() { echo "✓ $@"; }
log_error() { echo "✗ $@" >&2; }

################################################################################
# ZÁLOHOVÁNÍ
################################################################################

backup_system() {
    log_info "Spouštění zálohování systému..."
    
    local backup_date=$(date +%Y%m%d_%H%M%S)
    local backup_file="${BACKUP_DIR}/nymea-backup-${backup_date}.tar.gz"
    
    mkdir -p "${BACKUP_DIR}"
    
    # Zálohování kritických adresářů
    local backup_dirs=(
        "/etc/nymea"
        "/app/config"
        "/home/education-system/projects"
        "/home/nymea/.config"
    )
    
    tar --exclude-from=<(echo '/sys\n/proc\n/dev\n/tmp') \
        -czf "${backup_file}" \
        "${backup_dirs[@]}" 2>/dev/null || \
        { log_error "Chyba při vytváření zálohy"; return 1; }
    
    log_success "Záloha vytvořena: $backup_file"
    log "Velikost: $(du -h "$backup_file" | cut -f1)"
}

cleanup_old_backups() {
    log_info "Čištění starých záloh (starší než $RETENTION_DAYS dní)..."
    
    find "${BACKUP_DIR}" -name "nymea-backup-*.tar.gz" -mtime +${RETENTION_DAYS} \
        -exec rm {} \; || log_error "Chyba při čištění"
    
    log_success "Staré zálohy odstraněny"
}

restore_backup() {
    local backup_file="$1"
    
    if [ ! -f "$backup_file" ]; then
        log_error "Soubor zálohy '$backup_file' neexistuje"
        return 1
    fi
    
    log_info "Obnovuji zálohu: $backup_file"
    
    tar -xzf "$backup_file" -C / || \
        { log_error "Chyba při obnovení"; return 1; }
    
    log_success "Záloha obnovena"
}

################################################################################
# HLAVNÍ SPUŠTĚNÍ
################################################################################

case "${1:-backup}" in
    backup)
        backup_system
        cleanup_old_backups
        ;;
    restore)
        restore_backup "${2:-}"
        ;;
    *)
        log_error "Neznámá akce: $1 (backup|restore)"
        exit 1
        ;;
esac
