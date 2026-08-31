#!/bin/bash

install_skraper_cli() {
    info "Instalace Skraper CLI pro získávání metadat..."
    # Skraper pomáhá stáhnout obrázky k ROMkám z ScreenScraper.fr
    mkdir -p "$INSTALL_DIR/tools/scraper"
    # Instalace závislostí pro obrazové operace
    apt-get install -y -qq imagemagick >/dev/null
}
