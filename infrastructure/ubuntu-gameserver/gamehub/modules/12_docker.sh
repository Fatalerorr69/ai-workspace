#!/bin/bash

install_docker() {
    if ! command -v docker &> /dev/null; then
        info "Instalace Docker Engine a Compose..."
        curl -fsSL https://get.docker.com | sh >/dev/null 2>&1
        usermod -aG docker "$GH_USER"
        systemctl enable docker --now
    fi
}

deploy_portainer() {
    info "Nasazování Portainer (Web GUI pro Docker)..."
    
    # Kontrola, zda už běží
    if ! docker ps | grep -q portainer; then
        docker volume create portainer_data >/dev/null
        
        docker run -d -p 9000:9000 -p 9443:9443 --name=portainer \
        --restart=always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data \
        portainer/portainer-ce:latest >/dev/null
        
        info "Portainer běží na portu 9443 (HTTPS)"
        # Povolit ve firewallu
        ufw allow 9443/tcp >/dev/null
    fi
}
