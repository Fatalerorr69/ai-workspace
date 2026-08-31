#!/bin/bash

install_certbot() {
    info "Instalace Certbot (Let's Encrypt)..."
    apt-get install -y -qq certbot python3-certbot-nginx >/dev/null
}

configure_fail2ban() {
    info "Konfigurace Fail2Ban..."
    apt-get install -y -qq fail2ban >/dev/null
    
    # Vytvoření lokální konfigurace
    cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5

[sshd]
enabled = true

[nginx-http-auth]
enabled = true
EOF

    systemctl restart fail2ban
}

harden_ssh() {
    info "Zpevnění SSH konfigurace..."
    # Záloha originálu
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%F)
    
    # Zákaz přihlášení roota heslem (klíče povolena)
    sed -i 's/^PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    # Zákaz prázdných hesel
    sed -i 's/^PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
    
    systemctl restart ssh
}
