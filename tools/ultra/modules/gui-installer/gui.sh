#!/bin/bash
# Moderní text + minimal HTML GUI installer

echo "🔹 ULTRA PLATFORM INSTALLER 🔹"
echo "Vyber profil instalace:"
echo "1) Full"
echo "2) Core"
echo "3) Pentest/Android"

read -rp "Zadej volbu [1-3]: " choice

case $choice in
  1) install_profile_full ;;
  2) install_profile_core ;;
  3) install_profile_pentest_android ;;
  *) echo "Neplatná volba"; exit 1 ;;
esac

echo "✅ Instalace dokončena"
