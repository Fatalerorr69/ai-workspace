#!/bin/bash
# Soubor: modules/50_automation.sh

setup_discord_notifications() {
    info "Nastavení Discord Webhooku..."
    # Uživatel vloží URL do config.sh
    if [ ! -z "$DISCORD_WEBHOOK" ]; then
        cat > "$INSTALL_DIR/scripts/notify.sh" <<EOF
#!/bin/bash
curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"[GameHub] \$1\"}" $DISCORD_WEBHOOK
EOF
        chmod +x "$INSTALL_DIR/scripts/notify.sh"
        "$INSTALL_DIR/scripts/notify.sh" "🚀 Server GameHub byl právě spuštěn!"
    fi
}

setup_auto_cleaner() {
    info "Nastavení automatického čištění..."
    cat > /etc/cron.daily/gamehub-cleaner <<EOF
#!/bin/bash
# Smaže logy starší 7 dnů a promaže cache
find $LOG_DIR -type f -mtime +7 -exec rm -f {} \;
apt-get autoclean -y
EOF
    chmod +x /etc/cron.daily/gamehub-cleaner
}
