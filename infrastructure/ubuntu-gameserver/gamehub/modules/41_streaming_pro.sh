#!/bin/bash

setup_virtual_display() {
    info "Instalace virtuálního display driveru (Xserver-xorg-video-dummy)..."
    apt-get install -y -qq xserver-xorg-video-dummy >/dev/null
    
    # Konfigurace pro 1080p / 60Hz (lze změnit na 4K)
    cat > /etc/X11/xorg.conf <<EOF
Section "Device"
    Identifier  "Configured Video Device"
    Driver      "dummy"
    VideoRam    256000
EndSection

Section "Monitor"
    Identifier  "Configured Monitor"
    HorizSync   31.5-48.5
    VertRefresh 50.0-70.0
EndSection

Section "Screen"
    Identifier  "Default Screen"
    Monitor     "Configured Monitor"
    Device      "Configured Video Device"
    DefaultDepth 24
    SubSection "Display"
        Depth 24
        Modes "1920x1080"
    EndSubSection
EndSection
EOF
}

optimize_gpu_drivers() {
    info "Optimalizace NVENC/VAAPI pro nízkou latenci..."
    # Přidání uživatele sunshine do skupin pro přístup k HW akceleraci
    usermod -aG video,render sunshine 2>/dev/null || true
}
