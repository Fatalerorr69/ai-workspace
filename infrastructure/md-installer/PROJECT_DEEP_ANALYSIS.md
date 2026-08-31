# Hluboká analýza: md-installer

## Základní informace
- **Cílová cesta:** $targetPath
- **Detekované technologie:** PowerShell, Shell
- **Počet skriptů:** 28

## Popis z README
# 🚀 MD Installer - Version Manager

![Version](https://img.shields.io/badge/version-2.0.0-blue)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows%20%7C%20Termux-green)
![License](https://img.shields.io/badge/license-MIT-orange)

## 📖 Obsah
- [Úvod](#úvod)
- [Funkce](#funkce)
- [Rychlý start](#rychlí-start)
- [Instalace](#instalace)
- [Použití](#použití)
- [Struktura projektu](#struktura-projektu)
- [Konfigurace](#konfigurace)
- [Webové rozhraní](#webové-rozhraní)
- [Podpora](#podpora)

## 🎯 Úvod

MD Installer je **komplexní správce verzí** pro vaše projekty. Umožňuje snadné zálohování, správu verzí a synchronizaci mezi zařízeními.

## ✨ Funkce

### ✅ Základní funkce
- **Zálohování** - Komprimované archivy (TAR.GZ, ZIP)
- **Správa verzí** - Přepínání mezi verzemi
- **Git synchronizace** - Automatická sync s GitHub
- **Changelog** - Generování přehledu změn

### 🎨 Uživatelská rozhraní
- **Moderní TUI** - Whiptail, Dialog, FZF
- **Web GUI** - Moderní webové rozhraní
- **CLI** - Příkazová řádka

### 🌐 Multiplatformní podpora
- **Linux** (Ubuntu, Debian, Fedora, Arch)
- **macOS** 
- **Windows** (Git Bash, WSL)
- **Android** (Termux)

## 🚀 Rychlý start

### Základní použití:
```bash
# Naklonujte repozitář
git clone https://github.com/Fatalerorr69/MD_installer.git
cd MD_installer

# Instalace
chmod +x scripts/install.sh
./scripts/install.sh

# Spuštění
./md_installer.sh


MD_installer/
├── md_installer.sh              # HLAVNÍ SPOUŠTĚCÍ SKRIPT
├── README.md                    # Tato dokumentace
├── version_manager/             # Jádro aplikace
│   ├── backup.sh               # Zálohovací skript
│   ├── switch.sh               # Přepínač verzí
│   ├── git_sync.sh             # Git synchronizace
│   ├── changelog.sh            # Generátor changelogu
│   ├── config/                 # Konfigurace
│   │   ├── main.json
│   │   ├── dependencies.json
│   │   └── platforms.json
│   ├── backups/                # Uložené zálohy
│   ├── logs/                   # Logy aplikace
│   └── plugins/                # Uživatelské pluginy
├── web_gui/                    # Webové rozhraní
│   ├── server.js
│   ├── package.json
│   └── public/
│       ├── index.html
│       └── css/
├── scripts/                    # Pomocné skripty
│   ├── install.sh
│   └── update.sh
└── docs/                       # Dokumentace
    ├── user_guide.md
    └── api_reference.md


## Seznam skriptů
- `infrastructure\md-installer\scripts\fix_structure.sh` – !/usr/bin/env bash
- `infrastructure\md-installer\scripts\install.sh` – !/usr/bin/env bash
- `infrastructure\md-installer\version_manager\plugins\official\system_monitor\system_monitor.sh` – !/usr/bin/env bash
- `infrastructure\md-installer\version_manager\plugins\example.sh` – !/usr/bin/env bash
- `infrastructure\md-installer\version_manager\plugins\plugin_api.sh` – !/usr/bin/env bash
- `infrastructure\md-installer\version_manager\plugins\plugin_manager.sh` – !/usr/bin/env bash
- `infrastructure\md-installer\version_manager\scripts\setup.sh` – !/usr/bin/env bash
- `infrastructure\md-installer\version_manager\web_gui\public\app.js` – Skript app.js
- `infrastructure\md-installer\version_manager\web_gui\install_web_gui.sh` – !/usr/bin/env bash
- `infrastructure\md-installer\version_manager\web_gui\integrate_web_gui.sh` – !/usr/bin/env bash
- `infrastructure\md-installer\version_manager\web_gui\server.js` – Skript server.js
- `infrastructure\md-installer\version_manager\backup.sh` – !/usr/bin/env bash
- `infrastructure\md-installer\version_manager\cleanup.sh` – Skript cleanup.sh
- `infrastructure\md-installer\version_manager\diagnostics.sh` – Skript diagnostics.sh
- `infrastructure\md-installer\version_manager\fzf_theme.sh` – !/usr/bin/env bash
- `infrastructure\md-installer\version_manager\git_sync.sh` – !/usr/bin/env bash
- `infrastructure\md-installer\version_manager\changelog.sh` – !/usr/bin/env bash
- `infrastructure\md-installer\version_manager\install_fzf.sh` – !/usr/bin/env bash
- `infrastructure\md-installer\version_manager\manager.sh` – !/usr/bin/env bash
- `infrastructure\md-installer\version_manager\restore.sh` – Skript restore.sh
- `infrastructure\md-installer\version_manager\switch.sh` – !/usr/bin/env bash
- `infrastructure\md-installer\version_manager\system_backup.sh` – Skript system_backup.sh
- `infrastructure\md-installer\version_manager\upgrade.sh` – Skript upgrade.sh
- `infrastructure\md-installer\fix_structure.sh` – !/usr/bin/env bash
- `infrastructure\md-installer\md_installer.sh` – !/usr/bin/env bash
- `infrastructure\md-installer\md_super_installer_linux5.sh` – !/usr/bin/env bash
- `infrastructure\md-installer\md_super_installer_termux5.sh` – !/data/data/com.termux/files/usr/bin/bash
- `infrastructure\md-installer\md_super_installer_win5.ps1` – ===============================================================


## Hodnocení a doporučení
<!-- Doplňte na základě výše uvedených informací -->
- 
