#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# STARKO Termux Full V12.3 ULTRA GUI
# ============================================================

SCRIPT_DIR="$(dirname $0)"
MODULE_DIR="$SCRIPT_DIR/modules"
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$MODULE_DIR" "$LOG_DIR"

# ----------------------------------------------------------------
# Načtení modulů (pokud neexistují, stáhnou se z GitHubu)
# ----------------------------------------------------------------
if [ ! "$(ls -A $MODULE_DIR)" ]; then
    echo "[*] Stahuji moduly V12.3 ULTRA..."
    git clone https://github.com/Fatalerorr69/Starko-Ultimate-Recovery-USB.git "$MODULE_DIR"
fi

for module in $MODULE_DIR/*.sh; do
    [ -f "$module" ] && . "$module"
done

echo "[*] STARKO Termux Full V12.3 ULTRA GUI připraven!"

# ----------------------------------------------------------------
# Kontrola a instalace chroot Ubuntu
# ----------------------------------------------------------------
if ! proot-distro list | grep -q ubuntu; then
    echo "[*] Instalace Ubuntu chroot..."
    proot-distro install ubuntu
else
    echo "[*] Ubuntu chroot již nainstalován"
fi

# ----------------------------------------------------------------
# Funkce pro paralelní spuštění služeb s logováním
# ----------------------------------------------------------------
run_bg() {
    "$@" &> "$LOG_DIR/$(basename $1)_$(date +%H%M%S).log" &
}

# ----------------------------------------------------------------
# Hlavní GUI Menu
# ----------------------------------------------------------------
while true; do
    clear
    echo "======================================="
    echo " STARKO Termux Full V12.3 ULTRA GUI "
    echo "======================================="
    echo "1) Spustit Web GUI"
    echo "2) Spustit REST API"
    echo "3) Spustit VNC server"
    echo "4) Recovery Builder (Quick/Full)"
    echo "5) AI diagnostika / Help"
    echo "6) USB Manager (list/mount)"
    echo "7) Android Toolkit (ADB/Fastboot/Backup)"
    echo "8) Plugin Management"
    echo "9) Automation Tasks"
    echo "10) Utils (Log/Confirm)"
    echo "11) BIOS/UEFI Toolkit"
    echo "12) Chroot (Ubuntu/Kali)"
    echo "0) Konec"
    echo "======================================="
    read -p "Vyber možnost [0-12]: " choice

    case $choice in
        1) run_bg webgui_start ;;
        2) run_bg api_start ;;
        3) run_bg vnc_start ;;
        4)
            read -p "Quick nebo Full build? [q/f]: " mode
            if [[ "$mode" == "q" ]]; then recovery_build
            else recovery_full_build
            fi
            ;;
        5) ai_diagnose ;;
        6)
            echo "USB zařízení:"
            usb_list
            read -p "Chceš mountovat USB? [y/n]: " mount_choice
            if [[ "$mount_choice" =~ [Yy] ]]; then
                read -p "Zadej cestu k USB: " usb_path
                usb_mount "$usb_path"
            fi
            ;;
        7)
            echo "Android Toolkit"
            echo "1) ADB devices"
            echo "2) Flash"
            echo "3) Backup"
            read -p "Volba: " a_choice
            case $a_choice in
                1) android_info ;;
                2) read -p "Zadej příkaz fastboot: " fb_cmd; android_flash $fb_cmd ;;
                3) android_backup ;;
            esac
            ;;
        8)
            echo "Plugin Management"
            plugin_list
            read -p "Enable nebo Disable plugin? [e/d]: " pd
            if [[ "$pd" == "e" ]]; then
                read -p "Plugin name: " pn
                plugin_enable $pn
            else
                read -p "Plugin name: " pn
                plugin_disable $pn
            fi
            ;;
        9)
            echo "Automation Tasks"
            auto_backup
            auto_update
            auto_schedule
            ;;
        10)
            log "Test log entry"
            confirm "Potvrď akci"
            ;;
        11)
            bios_info
            read -p "Backup BIOS? [y/n]: " bchoice
            [[ "$bchoice" =~ [Yy] ]] && bios_backup
            ;;
        12)
            echo "Chroot Manager"
            echo "1) Install Ubuntu"
            echo "2) Login Ubuntu"
            echo "3) Update Ubuntu"
            echo "4) Remove Ubuntu"
            read -p "Volba: " c_choice
            case $c_choice in
                1) chroot_install ;;
                2) chroot_enter ;;
                3) chroot_update ;;
                4) proot-distro remove ubuntu ;;
            esac
            ;;
        0) echo "[*] Ukončuji..." ; exit 0 ;;
        *) echo "[WARN] Neplatná volba" ;;
    esac
    read -p "Stiskni Enter pro návrat do menu..."
done
