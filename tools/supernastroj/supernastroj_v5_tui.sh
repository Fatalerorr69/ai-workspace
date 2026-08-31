#!/bin/bash
# ==================================================
# SUPER NÁSTROJ v5.0 - TUI Edition
# Barevné menu + pokročilé funkce
# ==================================================

# ----------------------------
# BARVY
# ----------------------------
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"

# ----------------------------
# FUNKCE ZÁKLAD
# ----------------------------
check_command() {
    command -v "$1" >/dev/null 2>&1
}

install_package() {
    if ! check_command "$1"; then
        echo -e "${YELLOW}[*] Instalace balíčku $1...${RESET}"
        pkg install -y "$1"
    fi
}

pause_screen() {
    read -n1 -r -p "${CYAN}Stiskněte libovolnou klávesu pro pokračování...${RESET}"
}

# ----------------------------
# ANDROID DIAGNOSTIKA
# ----------------------------
android_diagnostics() {
    clear
    echo -e "${GREEN}=== Android diagnostika ===${RESET}"
    if check_command adb; then
        adb devices
        echo -e "${BLUE}Model zařízení:${RESET} $(adb shell getprop ro.product.model)"
        echo -e "${BLUE}Android verze:${RESET} $(adb shell getprop ro.build.version.release)"
        echo -e "${BLUE}SDK Level:${RESET} $(adb shell getprop ro.build.version.sdk)"
        echo -e "${BLUE}Baterie:${RESET}"
        adb shell dumpsys battery
    else
        echo -e "${RED}ADB není nainstalováno!${RESET}"
        install_package adb
    fi
    pause_screen
}

# ----------------------------
# FILE MANAGER
# ----------------------------
file_manager_menu() {
    local dir="."
    while true; do
        clear
        echo -e "${GREEN}=== File Manager: $dir ===${RESET}"
        ls -al "$dir"
        echo -e "${CYAN}cd [adresář] / up / find / quit${RESET}"
        read -p "> " cmd
        case $cmd in
            quit) break ;;
            up) dir=$(dirname "$dir") ;;
            find)
                read -p "Zadejte název souboru nebo vzor: " pattern
                find "$dir" -type f -name "$pattern"
                pause_screen
                ;;
            *)
                if [[ -d "$dir/$cmd" ]]; then
                    dir="$dir/$cmd"
                else
                    echo -e "${RED}Neplatný adresář${RESET}"
                    sleep 1
                fi
                ;;
        esac
    done
}

# ----------------------------
# SÍŤOVÉ NÁSTROJE
# ----------------------------
network_tools_menu() {
    while true; do
        clear
        echo -e "${GREEN}=== Network Tools ===${RESET}"
        echo "1) Síťové diagnostiky (ping, ifconfig)"
        echo "2) Port scanning (nmap)"
        echo "3) Speedtest (speedtest-cli)"
        echo "4) Zpět"
        read -p "> " choice
        case $choice in
            1)
                ping -c 4 google.com
                if check_command ifconfig; then ifconfig; fi
                pause_screen
                ;;
            2)
                install_package nmap
                read -p "Cílová IP: " target
                nmap -sS "$target"
                pause_screen
                ;;
            3)
                install_package speedtest-cli
                speedtest
                pause_screen
                ;;
            4) break ;;
            *) echo -e "${RED}Neplatná volba${RESET}" ; sleep 1 ;;
        esac
    done
}

# ----------------------------
# WIFI ANALÝZA
# ----------------------------
wifi_analysis() {
    echo -e "${GREEN}=== WiFi Analýza ===${RESET}"
    install_package termux-api
    termux-wifi-scaninfo
    pause_screen
}

# ----------------------------
# TERMUX BALÍČKY
# ----------------------------
termux_pkg_manager() {
    echo -e "${GREEN}=== Termux balíčky ===${RESET}"
    pkg list-installed
    pause_screen
}

# ----------------------------
# HLAVNÍ MENU TUI
# ----------------------------
show_main_menu() {
    clear
    echo -e "${CYAN}==============================================${RESET}"
    echo -e "${YELLOW}          SUPER NÁSTROJ v5.0 - TUI          ${RESET}"
    echo -e "${CYAN}==============================================${RESET}"
    echo "1) Android diagnostika"
    echo "2) Síťové nástroje"
    echo "3) WiFi analýza"
    echo "4) File manager"
    echo "5) Termux balíčky"
    echo "6) Konec"
    read -p "> " choice
}

main_loop() {
    while true; do
        show_main_menu
        case $choice in
            1) android_diagnostics ;;
            2) network_tools_menu ;;
            3) wifi_analysis ;;
            4) file_manager_menu ;;
            5) termux_pkg_manager ;;
            6) echo -e "${GREEN}Ukončuji...${RESET}"; exit 0 ;;
            *) echo -e "${RED}Neplatná volba${RESET}"; sleep 1 ;;
        esac
    done
}

# ----------------------------
# SPUŠTĚNÍ
# ----------------------------
echo -e "${CYAN}[*] Inicializuji Super Nástroj v5.0 TUI...${RESET}"
main_loop
