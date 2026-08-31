#!/bin/bash

BASE_DIR="/opt/platform"
UPDATER_DIR="$BASE_DIR/updater"
BACKUP_DIR="$BASE_DIR/backups"
LOGFILE="$UPDATER_DIR/update.log"
VERSION_FILE="$UPDATER_DIR/version.json"
TMP_DIR="/tmp/platform_update"

mkdir -p "$BACKUP_DIR" "$TMP_DIR"

log() {
    echo "[$(date '+%F %T')] $1" | tee -a "$LOGFILE"
}

get_current_version() {
    jq -r '.current_version' "$VERSION_FILE"
}

backup_system() {
    log "Vytvářím zálohu systému..."
    tar -czf "$BACKUP_DIR/platform_backup_$(date +%F_%H%M).tar.gz" "$BASE_DIR" --exclude="$BACKUP_DIR"
}

download_update() {
    UPDATE_URL=$(jq -r '.update_url' "$VERSION_FILE")
    CHECKSUM_URL=$(jq -r '.checksum_url' "$VERSION_FILE")

    log "Stahuji aktualizaci..."
    wget -O "$TMP_DIR/update.tar.gz" "$UPDATE_URL" || return 1
    wget -O "$TMP_DIR/update.sha256" "$CHECKSUM_URL" || return 1
}

verify_update() {
    log "Ověřuji kontrolní součet..."
    cd "$TMP_DIR" || exit 1
    sha256sum -c update.sha256 || return 1
}

apply_update() {
    log "Instaluji aktualizaci..."
    tar -xzf "$TMP_DIR/update.tar.gz" -C "$BASE_DIR"
}

rollback() {
    log "Chyba! Spouštím rollback..."
    LAST_BACKUP=$(ls -t "$BACKUP_DIR"/*.tar.gz | head -n1)
    tar -xzf "$LAST_BACKUP" -C /
}

update_version() {
    NEW_VER=$(jq -r '.new_version' "$TMP_DIR/metadata.json")
    jq ".current_version=\"$NEW_VER\" | .last_update=\"$(date +%F)\"" "$VERSION_FILE" > "$VERSION_FILE.tmp"
    mv "$VERSION_FILE.tmp" "$VERSION_FILE"
}

log "=== Spuštění OTA aktualizace ==="
backup_system || { rollback; exit 1; }
download_update || { rollback; exit 1; }
verify_update || { rollback; exit 1; }
apply_update || { rollback; exit 1; }

log "Aktualizace dokončena úspěšně."
