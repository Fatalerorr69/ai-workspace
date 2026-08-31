#!/bin/bash
set -e

echo "[MHS] Testuji framebuffer…"
FB="/dev/fb1"

if [[ ! -e $FB ]]; then
    echo "[MHS] Framebuffer neexistuje – test selhal."
    exit 1
fi

echo "[MHS] Vykresluji testovací obrazec…"
sudo dd if=/dev/zero of=$FB bs=600 count=1000
echo "[MHS] OK – MHS displej reaguje."
