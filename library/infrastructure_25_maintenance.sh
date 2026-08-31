#!/bin/bash

setup_auto_updates() {
    info "Konfigurace automatických bezpečnostních aktualizací..."
    apt-get install -y -qq unattended-upgrades apt-listchanges >/dev/null
    
    # Povolení
    echo 'Unattended-Upgrade::Allowed-Origins {
        "${distro_id}:${distro_codename}-security";
        "${distro_id}ESMApps:${distro_codename}-apps-security";
    };' > /etc/apt/apt.conf.d/50unattended-upgrades-gamehub
    
    echo 'APT::Periodic::Update-Package-Lists "1";' > /etc/apt/apt.conf.d/20auto-upgrades
    echo 'APT::Periodic::Unattended-Upgrade "1";' >> /etc/apt/apt.conf.d/20auto-upgrades
}

setup_log_rotation() {
    info "Nastavení rotace logů pro GameHub..."
    cat > /etc/logrotate.d/gamehub <<EOF
/var/log/gamehub/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 $GH_USER $GH_USER
    sharedscripts
}
EOF
}
