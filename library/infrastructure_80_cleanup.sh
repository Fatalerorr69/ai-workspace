#!/bin/bash

remove_temp_files() {
    info "Odstraňuji dočasné instalační soubory..."
    rm -rf /tmp/sunshine.deb
    rm -rf /tmp/netdata-kickstart.sh
    # Odstranění starých verzí skriptů, pokud existují
    find "$INSTALL_ROOT" -name "*.old" -type f -delete
    find "$INSTALL_ROOT" -name "*.bak" -type f -delete
}

clean_package_cache() {
    info "Čištění APT cache a nepotřebných závislostí..."
    apt-get autoremove -y >/dev/null
    apt-get autoclean -y >/dev/null
    # Odstranění Docker cache (volitelně - ponecháváme image, mažeme jen build cache)
    docker builder prune -f >/dev/null
}
