#!/bin/bash

setup_bios_structure() {
    info "Příprava složek pro BIOSy..."
    BIOS_BASE="$INSTALL_DIR/emulation/bios"
    mkdir -p "$BIOS_BASE"/{ps1,ps2,switch,dreamcast,dolphin}
    
    # Symlink pro RetroArch (pokud je instalován přes Flatpak)
    mkdir -p ~/.var/app/org.libretro.RetroArch/config/retroarch/system
}

download_common_firmware() {
    info "Stahování základního firmwaru (OpenSource/Runtime)..."
    # Příklad pro GBA (VBA-M) - jen placeholder, reálné BIOSy jsou často chráněny autorským právem
    # Uživatel by měl své soubory nahrát do $INSTALL_DIR/emulation/bios přes FileBrowser
    touch "$INSTALL_DIR/emulation/bios/README_PUT_BIOS_HERE.txt"
}
