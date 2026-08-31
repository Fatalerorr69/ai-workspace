#!/bin/bash

install_filebrowser() {
    info "Instalace FileBrowser..."
    curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash >/dev/null
    
    # Vytvoření konfigurační složky
    mkdir -p /etc/filebrowser
    
    # Vytvoření databáze (pokud neexistuje)
    if [ ! -f /etc/filebrowser/filebrowser.db ]; then
        filebrowser -d /etc/filebrowser/filebrowser.db config init >/dev/null
        filebrowser -d /etc/filebrowser/filebrowser.db config set --address 0.0.0.0 >/dev/null
        filebrowser -d /etc/filebrowser/filebrowser.db config set --port 8080 >/dev/null
        filebrowser -d /etc/filebrowser/filebrowser.db config set --root "$INSTALL_DIR" >/dev/null
        filebrowser -d /etc/filebrowser/filebrowser.db config set --branding.name "GameHub Files" >/dev/null
        
        # Vytvoření admin uživatele (admin/admin - uživatel si změní)
        filebrowser -d /etc/filebrowser/filebrowser.db users add admin admin --perm.admin >/dev/null 2>&1 || true
        info "Výchozí login: admin / admin"
    fi
}

configure_filebrowser_service() {
    info "Vytváření Systemd služby pro FileBrowser..."
    cat > /etc/systemd/system/filebrowser.service <<EOF
[Unit]
Description=FileBrowser
After=network.target

[Service]
User=root
Group=root
ExecStart=/usr/local/bin/filebrowser -d /etc/filebrowser/filebrowser.db
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable --now filebrowser
    ufw allow 8080/tcp >/dev/null
}
