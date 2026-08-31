#!/bin/bash
set -e

PKG_URL="https://github.com/Fatalerorr69/twisteros_supermanager/releases/download/latest/twisteros-supermanager_1.0.0_arm64.deb"
PKG_NAME="twisteros-supermanager_1.0.0_arm64.deb"

echo "===================================================="
echo " TWISTEROS SUPER MANAGER – AUTOMATICKÁ INSTALACE"
echo "===================================================="

echo "[1] Aktualizuji systém…"
sudo apt update -y
sudo apt install -y python3 python3-pip rsync retroarch

echo "[2] Stahuji nejnovější balíček…"
wget -O "$PKG_NAME" "$PKG_URL"

echo "[3] Instaluji balíček…"
sudo dpkg -i "$PKG_NAME" || sudo apt --fix-broken install -y

echo "[4] Kontrola systemd služby…"
sudo systemctl status supermanager.service --no-pager || true

echo "[5] Hotovo!"
echo "SuperManager běží na:"
echo "  http://<IP>:5001"
echo "Dashboard:"
echo "  http://<IP>:5001/dashboard"
