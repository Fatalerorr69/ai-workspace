#!/bin/bash

install_steam() {
    info "Příprava SteamCMD..."
    add-apt-repository -y multiverse >/dev/null 2>&1
    dpkg --add-architecture i386
    apt-get update -qq >/dev/null
    
    # SteamCMD licence agreement hack
    echo steam steam/question select "I AGREE" | debconf-set-selections
    echo steam steam/license note '' | debconf-set-selections
    
    apt-get install -y -qq lib32gcc-s1 steamcmd >/dev/null
    
    # Link steamcmd
    ln -sf /usr/games/steamcmd /usr/local/bin/steamcmd
}

install_emulators() {
    info "Instalace Flatpak a Emulátorů..."
    apt-get install -y -qq flatpak >/dev/null
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    
    # Instalace RetroArch
    flatpak install -y flathub org.libretro.RetroArch >/dev/null 2>&1 || true
}

install_streaming() {
    info "Instalace Sunshine (Streaming) - Opravená verze..."
    
    # Získání URL nejnovějšího deb balíčku pro Ubuntu
    SUNSHINE_URL=$(curl -s https://api.github.com/repos/LizardByte/Sunshine/releases/latest | grep "browser_download_url.*ubuntu-22.04-amd64.deb" | cut -d '"' -f 4)
    
    if [ -z "$SUNSHINE_URL" ]; then
        # Fallback pokud API selže
        SUNSHINE_URL="https://github.com/LizardByte/Sunshine/releases/download/v0.21.0/sunshine-ubuntu-22.04-amd64.deb"
    fi

    wget -q "$SUNSHINE_URL" -O /tmp/sunshine.deb
    
    if [ -f /tmp/sunshine.deb ] && [ -s /tmp/sunshine.deb ]; then
        # Instalace závislostí a balíčku
        apt-get install -y -qq libcap2-bin libnm0 >/dev/null
        apt-get install -y -qq /tmp/sunshine.deb || apt-get install -f -y
        rm /tmp/sunshine.deb
        
        # Nastavení CAP_SYS_ADMIN pro Sunshine (potřebné pro virtuální vstupy)
        setcap cap_sys_admin+p $(readlink -f $(which sunshine))
    else
        error "Nepodařilo se stáhnout validní Sunshine balíček."
    fi
}
