#!/bin/bash

update_system() {
    info "Aktualizace repozitářů..."
    apt-get update -qq >/dev/null
    # DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq >/dev/null
}

install_dependencies() {
    info "Instalace základních balíčků..."
    apt-get install -y -qq \
        curl wget git unzip zip htop ufw fail2ban \
        software-properties-common build-essential \
        jq net-tools >/dev/null
}

create_users_groups() {
    if ! id "$GH_USER" &>/dev/null; then
        info "Vytváření uživatele $GH_USER..."
        useradd -m -s /bin/bash "$GH_USER"
        usermod -aG sudo "$GH_USER"
    fi
    
    mkdir -p "$INSTALL_DIR" "$CONFIG_DIR" "$DATA_DIR" "$BACKUP_DIR"
    chown -R "$GH_USER:$GH_USER" "$INSTALL_DIR" "$CONFIG_DIR" "$DATA_DIR" "$BACKUP_DIR"
}

configure_firewall() {
    info "Nastavování UFW firewallu..."
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow $PORT_API/tcp
    ufw allow $PORT_STREAM/tcp # Sunshine
    ufw allow 47998:48000/udp  # Sunshine Streaming
    
    # Herní porty
    ufw allow 25565/tcp # Minecraft
    ufw allow 27015/tcp # Source
    
    # Povolit, pokud není aktivní (neinteraktivně)
    if ! ufw status | grep -q "Status: active"; then
        ufw --force enable >/dev/null
    fi
}
