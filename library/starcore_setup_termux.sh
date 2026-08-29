#!/bin/bash
# STARCORE Termux Environment Setup

echo -e "\033[1;36m🔧 Instalace nástrojů pro Termux...\033[0m"

# Základní nástroje
pkg update -y
pkg install -y \
    tree \
    fd \
    ripgrep \
    eza \
    bat \
    jq \
    htop \
    ncdu \
    neovim \
    python \
    git \
    tmux \
    openssh \
    termux-api

# Python nástroje
pip install --upgrade pip
pip install \
    rich \
    typer \
    httpx \
    jinja2 \
    fastapi \
    uvicorn \
    apscheduler \
    sqlite-utils

echo -e "\033[1;32m✅ Termux prostředí připraveno\033[0m"

# Přidání aliasů
echo 'alias ls="eza -la"' >> ~/.zshrc
echo 'alias tree="tree -L 2"' >> ~/.zshrc
echo 'alias grep="rg"' >> ~/.zshrc
echo 'alias cat="bat"' >> ~/.zshrc

echo -e "\033[1;32m✅ Aliasy nastaveny\033[0m"
