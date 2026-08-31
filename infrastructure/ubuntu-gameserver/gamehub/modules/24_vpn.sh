#!/bin/bash

install_tailscale() {
    if ! command -v tailscale &> /dev/null; then
        info "Instalace Tailscale..."
        curl -fsSL https://tailscale.com/install.sh | sh >/dev/null
    else
        info "Tailscale již nainstalován."
    fi
    
    info "Pro aktivaci spusťte po instalaci příkaz: 'sudo tailscale up'"
}
