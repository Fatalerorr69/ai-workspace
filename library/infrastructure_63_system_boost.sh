#!/bin/bash

install_gamemode() {
    info "Instalace Feral Interactive GameMode..."
    apt-get install -y -qq gamemode >/dev/null
    # Povolení pro aktuálního uživatele
    usermod -aG gamemode "$GH_USER"
}

setup_gamescope_fsr() {
    info "Instalace Gamescope (Micro-compositor pro FSR scaling)..."
    # Gamescope umožní upscalovat hry (např. z 720p na 1080p s FSR) přímo na serveru
    apt-get install -y -qq gamescope >/dev/null
}
