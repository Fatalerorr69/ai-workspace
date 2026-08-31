#!/bin/bash
set -e

MODEL=$(/home/starko/scripts/detect_mhs.sh)

echo "[MHS] Nastavuji displej $MODEL …"

BOOTCFG="/boot/config.txt"

case "$MODEL" in
  "MHS_SPI"|"MHS_ILI9486")
    echo "[MHS] Konfiguruji SPI MHS displej…"

    sudo sed -i '/dtoverlay=mhs/d' $BOOTCFG
    sudo sed -i '/dtoverlay=ili9486/d' $BOOTCFG

    sudo bash -c "cat >> $BOOTCFG" <<EOF

# --- MHS Display ---
dtparam=spi=on
dtoverlay=spi0-0
dtoverlay=ili9486,rotate=270,speed=65000000,fps=60

EOF

    sudo modprobe spi_bcm2835
    sudo modprobe fbtft_device name=ili9486 fbcon=map:10 rotate=270
    ;;

  "MHS_USB")
    echo "[MHS] USB MHS displej – není nutná konfigurace bootu."
    ;;

  *)
    echo "[MHS] Nepodporovaný nebo nedetekovaný displej!"
    exit 1
    ;;
esac

echo "[MHS] Hotovo. Vyžaduje restart."
