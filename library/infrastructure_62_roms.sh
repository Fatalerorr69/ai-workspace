#!/bin/bash

setup_rom_library() {
    info "Vytváření struktury pro ROMs..."
    ROM_DIR="$INSTALL_DIR/emulation/roms"
    mkdir -p "$ROM_DIR"/{nes,snes,n64,ps1,ps2,switch,wii,gamecube,pc}
    
    # Nastavení práv, aby na to mohl sahat i webový FileBrowser
    chown -R "$GH_USER:$GH_USER" "$INSTALL_DIR/emulation"
    chmod -R 775 "$INSTALL_DIR/emulation"
}

install_rom_downloader() {
    info "Instalace nástroje pro správu ROM (skript pro stahování z archive.org)..."
    # Jen pomocný nástroj pro CLI
    cat > "$INSTALL_DIR/scripts/rom-fetcher.sh" <<'EOF'
#!/bin/bash
echo "Použití: ./rom-fetcher.sh [URL]"
wget -c "$1" -P /opt/gamehub/emulation/roms/
EOF
    chmod +x "$INSTALL_DIR/scripts/rom-fetcher.sh"
}
