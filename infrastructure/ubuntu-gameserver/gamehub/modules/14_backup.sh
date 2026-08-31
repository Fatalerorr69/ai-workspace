#!/bin/bash

setup_backup_tools() {
    info "Instalace zálohovacích nástrojů (Rclone, Restic)..."
    apt-get install -y -qq rclone restic zip >/dev/null
    mkdir -p "$BACKUP_DIR/daily" "$BACKUP_DIR/weekly"
}

create_backup_cron() {
    info "Vytváření zálohovacího skriptu..."
    
    cat > "$INSTALL_DIR/scripts/daily_backup.sh" <<EOF
#!/bin/bash
# Automatická denní záloha GameHub
BACKUP_PATH="$BACKUP_DIR/daily"
DATE=\$(date +%Y%m%d)

# 1. Záloha DB
mysqldump -u$DB_USER -p$DB_PASS $DB_NAME | gzip > "\$BACKUP_PATH/db_\$DATE.sql.gz"

# 2. Záloha Konfigurace
tar -czf "\$BACKUP_PATH/config_\$DATE.tar.gz" $CONFIG_DIR

# 3. Záloha Herních dat (saves) - vynecháváme velké soubory
tar -czf "\$BACKUP_PATH/saves_\$DATE.tar.gz" $INSTALL_DIR/servers --exclude='*.jar' --exclude='*.log'

# Promazání starších než 7 dní
find "\$BACKUP_PATH" -type f -mtime +7 -delete

echo "Záloha dokončena: \$DATE" >> $LOG_FILE
EOF

    chmod +x "$INSTALL_DIR/scripts/daily_backup.sh"
    
    # Přidání do cronu (každý den ve 3:00 ráno), pokud tam není
    if ! crontab -l 2>/dev/null | grep -q "daily_backup.sh"; then
        (crontab -l 2>/dev/null; echo "0 3 * * * $INSTALL_DIR/scripts/daily_backup.sh") | crontab -
        info "Cron úloha přidána (03:00 AM)."
    fi
}
