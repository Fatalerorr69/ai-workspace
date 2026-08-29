#!/bin/bash

setup_shared_library() {
    info "Vytváření sdílené složky pro herní savy a instalace..."
    mkdir -p "$INSTALL_DIR/shared/saves"
    mkdir -p "$INSTALL_DIR/shared/isos"
    
    # Symlinky pro snadný přístup
    ln -sf "$INSTALL_DIR/shared/saves" "/home/$GH_USER/GameSaves"
    
    # Nastavení automatické synchronizace složek (pokud máš cloud)
    info "Příprava rclone pro cloud sync (volitelné)..."
}
