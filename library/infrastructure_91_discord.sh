#!/bin/bash

setup_discord_bot_core() {
    info "Příprava Discord webhooku a stavových zpráv..."
    # Skript pro odesílání stavu
    cat > "$INSTALL_DIR/scripts/discord_status.sh" <<'EOF'
#!/bin/bash
WEBHOOK_URL=$(grep "DISCORD_WEBHOOK" /etc/gamehub/config.sh | cut -d'"' -f2)
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
RAM=$(free -m | awk '/Mem:/ { print $3 }')

payload="{\"embeds\": [{\"title\": \"🎮 GameHub Status\", \"description\": \"Server běží\", \"fields\": [{\"name\": \"CPU\", \"value\": \"$CPU%\", \"inline\": true}, {\"name\": \"RAM\", \"value\": \"${RAM}MB\", \"inline\": true}], \"color\": 7340287}]}"

curl -X POST -H "Content-Type: application/json" -d "$payload" "$WEBHOOK_URL"
EOF
    chmod +x "$INSTALL_DIR/scripts/discord_status.sh"
}
