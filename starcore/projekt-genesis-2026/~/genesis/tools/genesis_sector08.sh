#!/bin/bash
# GENESIS AETERNA - SEKTOR 08: ANDROID LAB
G='\033[0;32m'; B='\033[0;34m'; NC='\033[0m'

echo -e "${B}--- AKTIVACE SEKTORU 08: ANDROID LAB ---${NC}"

# Instalace dodatečných knihoven pro práci se souborovými systémy
sudo apt install -y jmtpfs adb fastboot

# Vytvoření automatizovaného Dump skriptu
cat > ~/genesis/tools/android_dump.sh <<EOF
#!/bin/bash
echo "--- ANDROID DUMP INICIALIZACE \$(date) ---"
mkdir -p ~/genesis/vault/android_dumps/\$(date +%F)
echo "Skenuji připojená zařízení..."
adb devices > ~/genesis/vault/android_dumps/\$(date +%F)/devices.txt
echo "Extrakce základních informací o buildu..."
adb shell getprop > ~/genesis/vault/android_dumps/\$(date +%F)/build_info.txt
echo "Analýza aplikací..."
adb shell pm list packages -f > ~/genesis/vault/android_dumps/\$(date +%F)/installed_apps.txt
EOF
chmod +x ~/genesis/tools/android_dump.sh

echo -e "${G}Sektor 08 ONLINE: Pro analýzu připoj Android a spusť '~/genesis/tools/android_dump.sh'.${NC}"
