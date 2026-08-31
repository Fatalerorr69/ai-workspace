#!/bin/bash

install_workshop_tools() {
    info "Instalace Steam Workshop Downloader CLI..."
    # Použití SteamCMD pro stahování workshop itemů
    cat > "$INSTALL_DIR/scripts/workshop_dl.sh" <<'EOF'
#!/bin/bash
# Použití: ./workshop_dl.sh [AppID] [ModID]
steamcmd +login anonymous +workshop_download_item $1 $2 +quit
EOF
    chmod +x "$INSTALL_DIR/scripts/workshop_dl.sh"
}
