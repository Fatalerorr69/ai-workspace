#!/bin/bash

install_linuxgsm() {
    info "Instalace závislostí pro LinuxGSM..."
    apt-get install -y -qq mailutils postfix curl wget file bzip2 gzip unzip bsdmainutils python3 util-linux ca-certificates binutils bc jq tmux netcat-openbsd lib32gcc-s1 lib32stdc++6 >/dev/null

    # Vytvoření uživatele pro hry, pokud neexistuje (používáme odděleného od systémového gamehub uživatele pro bezpečnost)
    if ! id "lgsm" &>/dev/null; then
        info "Vytváření uživatele 'lgsm'..."
        useradd -m -s /bin/bash lgsm
        echo "lgsm ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/lgsm
    fi

    # Stažení instalátoru
    info "Stahování LinuxGSM..."
    sudo -u lgsm wget -O /home/lgsm/linuxgsm.sh https://linuxgsm.sh
    sudo -u lgsm chmod +x /home/lgsm/linuxgsm.sh
    
    info "LinuxGSM je připraven v /home/lgsm/"
    info "Příklady použití (přihlaste se jako 'su - lgsm'):"
    info "  ./linuxgsm.sh mcserver (pro Minecraft)"
    info "  ./linuxgsm.sh csgoserver (pro CS:GO)"
}
