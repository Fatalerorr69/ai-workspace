#!/bin/bash
# Termux Optimization for STARCORE

echo "⚡ Optimalizace Termux prostředí..."

# 1. Aliasy
if ! grep -q "STARCORE aliases" ~/.zshrc 2>/dev/null; then
    echo "  Přidávám aliasy..."
    cat >> ~/.zshrc << "EOF"

# STARCORE aliases
alias st="cd ~/STARCORE && ./starcore"
alias ststart="cd ~/STARCORE && ./starcore start"
alias ststop="cd ~/STARCORE && ./starcore stop"
alias ststatus="cd ~/STARCORE && ./starcore status"
alias stdoctor="cd ~/STARCORE && ./starcore doctor"
alias stverify="cd ~/STARCORE && ./starcore verify"
alias stai="cd ~/STARCORE && ./starcore ai"
alias sthive="cd ~/STARCORE && ./starcore hive"
