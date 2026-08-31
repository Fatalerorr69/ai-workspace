#!/bin/bash

install_desktop_environment() {
    info "Instalace lehkého prostředí XFCE4 (může trvat několik minut)..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y -qq xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils >/dev/null
}

setup_xrdp() {
    info "Instalace a konfigurace XRDP..."
    apt-get install -y -qq xrdp >/dev/null
    
    # Přidání xrdp do ssl-cert skupiny
    adduser xrdp ssl-cert
    
    # Nastavení výchozí session
    echo "xfce4-session" > /etc/skel/.xsession
    cp /etc/skel/.xsession "/home/$GH_USER/"
    chown "$GH_USER:$GH_USER" "/home/$GH_USER/.xsession"
    
    systemctl restart xrdp
    ufw allow 3389/tcp >/dev/null
}
