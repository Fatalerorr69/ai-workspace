#!/bin/bash

install_glances() {
    info "Instalace Glances (Pokročilý monitoring přes web)..."
    pip3 install glances[all] >/dev/null
    
    cat > /etc/systemd/system/glances.service <<EOF
[Unit]
Description=Glances Web Server
After=network.target

[Service]
ExecStart=/usr/local/bin/glances -w
Restart=always

[Install]
WantedBy=multi-user.target
EOF
    systemctl enable --now glances
    ufw allow 61208/tcp
}
