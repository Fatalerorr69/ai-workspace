#!/bin/bash
# install_starko_recovery.sh - Instalační skript

echo "Instalace Starko Recovery Linux AIO Generatoru..."

# 1. Stáhnout skripty
mkdir -p ~/starko_install
cd ~/starko_install

echo "Stahuji komponenty..."
wget -O generate_recovery.sh https://raw.githubusercontent.com/starko/recovery/main/generate_recovery.sh
wget -O config_generator.sh https://raw.githubusercontent.com/starko/recovery/main/config_generator.sh
wget -O plugin_system.sh https://raw.githubusercontent.com/starko/recovery/main/plugin_system.sh
wget -O build_automation.sh https://raw.githubusercontent.com/starko/recovery/main/build_automation.sh

# 2. Nastavit oprávnění
chmod +x *.sh

# 3. Nainstalovat závislosti
echo "Instaluji závislosti..."
sudo apt update
sudo apt install -y xorriso wget curl p7zip-full genisoimage mkisofs \
    squashfs-tools grub-common grub-pc-bin grub-efi-amd64-bin \
    mtools dosfstools syslinux-common isolinux

# 4. Vytvořit aliasy
echo "Vytvářím aliasy..."
echo "alias starko-build='~/starko_install/generate_recovery.sh'" >> ~/.bashrc
echo "alias starko-config='~/starko_install/config_generator.sh'" >> ~/.bashrc
echo "alias starko-plugins='~/starko_install/plugin_system.sh'" >> ~/.bashrc

# 5. Dokončit
echo "Instalace dokončena!"
echo ""
echo "Příkazy:"
echo "  starko-build          # Spustit generátor"
echo "  starko-build --quick  # Rychlý build"
echo "  starko-build --full   # Kompletní build"
echo "  starko-config         # Konfigurace"
echo "  starko-plugins        # Správa pluginů"
echo ""
echo "První build:"
echo "  cd ~/starko_install"
echo "  ./generate_recovery.sh --quick"
