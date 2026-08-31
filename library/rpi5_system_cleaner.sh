#!/bin/bash
echo "🧹 Čistím systém..."

sudo apt autoremove -y
sudo apt clean -y
sudo journalctl --vacuum-size=50M
sudo rm -rf ~/.cache/*
sudo rm -rf /var/tmp/*
sudo rm -rf ~/.local/share/Trash/*

sync && sudo sysctl -w vm.drop_caches=3

echo "✅ Systém vyčištěn!"
