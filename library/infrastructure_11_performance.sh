#!/bin/bash

setup_swap() {
    # Pokud je RAM menší než 8GB a nemáme swap, vytvoříme ho
    RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    if [ "$RAM_KB" -lt 8000000 ] && [ ! -f /swapfile ]; then
        info "Detekována nižší RAM. Vytvářím 4GB SWAP soubor..."
        fallocate -l 4G /swapfile
        chmod 600 /swapfile
        mkswap /swapfile >/dev/null
        swapon /swapfile
        echo '/swapfile none swap sw 0 0' >> /etc/fstab
    else
        info "Swap není potřeba nebo již existuje."
    fi
}

tune_kernel() {
    info "Ladění jádra pro herní a streamovací latenci (BBR)..."
    
    cat > /etc/sysctl.d/99-gamehub.conf <<EOF
# Zvýšení limitů pro soubory (pro databáze a herní servery)
fs.file-max = 100000

# TCP BBR Congestion Control (pro lepší latenci Sunshine/Her)
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# Ochrana proti SYN flood
net.ipv4.tcp_syncookies = 1

# Zvýšení velikosti bufferů pro síť
net.core.rmem_max = 2500000
net.core.wmem_max = 2500000
EOF

    sysctl --system >/dev/null
}
