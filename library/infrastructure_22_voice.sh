#!/bin/bash

install_mumble() {
    info "Instalace Mumble Serveru (Murmur)..."
    apt-get install -y -qq mumble-server >/dev/null
    
    # Konfigurace
    sed -i 's/^bandwidth=.*/bandwidth=130000/' /etc/mumble-server.ini
    sed -i 's/^users=.*/users=100/' /etc/mumble-server.ini
    sed -i 's/^registerName=.*/registerName=GameHub Voice/' /etc/mumble-server.ini
    
    # Nastavení hesla superusera
    SUP_PASS=$(openssl rand -base64 12)
    mursup SuperUser "$SUP_PASS" >/dev/null 2>&1
    
    info "Mumble SuperUser heslo nastaveno na: $SUP_PASS"
    echo "MUMBLE_SUPERUSER_PASS=$SUP_PASS" >> "$CONFIG_DIR/credentials.txt"
    
    systemctl restart mumble-server
    ufw allow 64738/tcp
    ufw allow 64738/udp
}
