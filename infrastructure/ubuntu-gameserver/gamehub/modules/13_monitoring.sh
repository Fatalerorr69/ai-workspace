#!/bin/bash

install_netdata() {
    if [ ! -d "/etc/netdata" ]; then
        info "Instalace Netdata (Real-time monitoring)..."
        # Použití oficiálního kickstart skriptu v neinteraktivním režimu
        wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh
        sh /tmp/netdata-kickstart.sh --non-interactive --stable-channel --disable-telemetry >/dev/null 2>&1
        
        # Povolení portu
        ufw allow 19999/tcp >/dev/null
    else
        info "Netdata již nainstalováno."
    fi
}

install_cockpit() {
    info "Instalace Cockpit (Server Admin Panel)..."
    apt-get install -y -qq cockpit cockpit-docker >/dev/null
    systemctl enable --now cockpit.socket
    ufw allow 9090/tcp >/dev/null
}
