# 🚀 SuperNastroj v5.0 - Instalační Průvodce

## 📋 Kompletní Balíček

### ✅ Co Obsahuje:
1. **SuperNastroj_Complete.bat** - Windows verze (plná funkcionalita)
2. **SuperNastroj_linux.sh** - Linux/macOS/BSD verze
3. **SuperNastroj_android.sh** - Android/Termux verze
4. **SuperNastroj_launcher.sh** - Univerzální spouštěč
5. **README.md** - Kompletní dokumentace

---

## 🖥️ WINDOWS - Instalace

### Metoda 1: Rychlá Instalace (Doporučeno)
```cmd
# 1. Stáhněte SuperNastroj_Complete.bat
# 2. Uložte do složky (např. C:\SuperNastroj\)
# 3. Pravý klik → "Spustit jako správce"
```

### Metoda 2: Git Clone
```cmd
# Otevřete Command Prompt
cd C:\
git clone https://github.com/Fatalerorr69/SuperNastroj.git
cd SuperNastroj

# Spusťte jako správce
SuperNastroj_Complete.bat
```

### ⚠️ Důležité pro Windows:
- ✅ **Vždy spouštějte jako správce** (Run as Administrator)
- ✅ **Povolte PowerShell** skripty: `Set-ExecutionPolicy RemoteSigned`
- ✅ **Přidejte výjimku** do antivirového programu
- ✅ **Kontrolujte logy** v `SuperNastroj_Logs/`

### 🔧 Požadavky Windows:
| Komponenta | Minimum | Doporučeno |
|------------|---------|------------|
| OS | Windows 7 | Windows 10/11 |
| RAM | 2 GB | 4 GB |
| Disk | 1 GB volného | 2 GB volného |
| PowerShell | v3.0 | v5.1+ |

---

## 🐧 LINUX - Instalace

### Ubuntu/Debian:
```bash
# 1. Aktualizace systému
sudo apt update && sudo apt upgrade -y

# 2. Instalace závislostí
sudo apt install -y git curl wget nmap net-tools

# 3. Stažení SuperNastroj
cd ~
git clone https://github.com/Fatalerorr69/SuperNastroj.git
cd SuperNastroj

# 4. Nastavení oprávnění
chmod +x *.sh

# 5. Spuštění
sudo ./SuperNastroj_launcher.sh
```

### Fedora/RHEL/CentOS:
```bash
# 1. Aktualizace
sudo dnf update -y

# 2. Závislosti
sudo dnf install -y git curl wget nmap net-tools

# 3. Stažení
git clone https://github.com/Fatalerorr69/SuperNastroj.git
cd SuperNastroj

# 4. Oprávnění a spuštění
chmod +x *.sh
sudo ./SuperNastroj_launcher.sh
```

### Arch Linux:
```bash
# 1. Aktualizace
sudo pacman -Syu

# 2. Závislosti
sudo pacman -S git curl wget nmap net-tools

# 3. Stažení a spuštění
git clone https://github.com/Fatalerorr69/SuperNastroj.git
cd SuperNastroj
chmod +x *.sh
sudo ./SuperNastroj_launcher.sh
```

### 🔧 Požadavky Linux:
- ✅ Bash 4.0+
- ✅ Root/sudo přístup (pro plnou funkcionalitu)
- ✅ Základní utility (curl, wget, git)
- ✅ 1 GB volného místa

---

## 📱 ANDROID/TERMUX - Instalace

### Krok 1: Instalace Termux
1. Stáhněte **Termux** z [F-Droid](https://f-droid.org/packages/com.termux/) 
   ⚠️ **NEPOUŽÍVEJTE Google Play** verzi - je zastaralá!

### Krok 2: První Nastavení Termux
```bash
# 1. Aktualizace balíčků
pkg update && pkg upgrade -y

# 2. Povolení úložiště (DŮLEŽITÉ!)
termux-setup-storage
# → Povolte v Android dialogu

# 3. Instalace základních nástrojů
pkg install -y git curl wget python nmap

# 4. (Volitelné) Termux API pro pokročilé funkce
pkg install -y termux-api
# Také stáhněte: Termux:API z F-Droid
```

### Krok 3: Instalace SuperNastroj
```bash
# 1. Stažení
cd ~
git clone https://github.com/Fatalerorr69/SuperNastroj.git
cd SuperNastroj

# 2. Nastavení oprávnění
chmod +x SuperNastroj_android.sh

# 3. Spuštění
./SuperNastroj_android.sh
```

### 🔧 Doporučené Balíčky pro Android:
```bash
# Diagnostické nástroje
pkg install -y htop neofetch

# Síťové nástroje
pkg install -y nmap netcat-openbsd traceroute

# Vývojářské nástroje (volitelné)
pkg install -y python nodejs php

# Utility
pkg install -y zip unzip tar
```

### ⚙️ Termux Nastavení:
```bash
# Změna repozitáře (pokud je stahování pomalé)
termux-change-repo

# Nastavení barev
pkg install termux-styling
# Dlouhý stisk → Style → Choose color

# SSH server (pro vzdálený přístup)
pkg install openssh
passwd  # nastavit heslo
sshd    # spustit server
# Připojení: ssh -p 8022 u0_a123@192.168.1.xxx
```

### 📱 Požadavky Android:
| Komponenta | Minimum | Doporučeno |
|------------|---------|------------|
| Android | 7.0 | 10.0+ |
| RAM | 1 GB | 2 GB |
| Storage | 500 MB | 1 GB |
| Termux | Latest F-Droid | Latest F-Droid |

---

## 🚀 První Spuštění

### Windows:
```cmd
# 1. Otevřete jako správce
SuperNastroj_Complete.bat

# 2. Počkejte na inicializaci
# 3. Vyberte funkci z menu
# 4. Pro rychlou opravu: stiskněte 1
```

### Linux:
```bash
# 1. S root právy
sudo ./SuperNastroj_launcher.sh

# 2. Launcher automaticky detekuje platformu
# 3. Spustí příslušnou verzi
```

### Android:
```bash
# 1. V Termux
./SuperNastroj_android.sh

# 2. Projděte kontrolu závislostí
# 3. Povolte oprávnění pokud je třeba
```

---

## 📊 Verifikace Instalace

### Kontrola Windows:
```cmd
# Zkontrolujte složky:
dir SuperNastroj_*

# Měli byste vidět:
SuperNastroj_Logs\
SuperNastroj_Tools\
SuperNastroj_Backups\
SuperNastroj_ISOs\
```

### Kontrola Linux/Android:
```bash
# Zkontrolujte složky:
ls -la ~/ | grep SuperNastroj

# Měli byste vidět:
SuperNastroj_Logs/
SuperNastroj_Tools/
SuperNastroj_Backups/
```

### Test Funkcí:
```bash
# Windows
SuperNastroj_Complete.bat
# Vyberte: 2 → 1 (Diagnostika)

# Linux
sudo ./SuperNastroj_linux.sh
# Vyberte: 2 (Diagnostika)

# Android
./SuperNastroj_android.sh
# Vyberte: 1 (Diagnostika)
```

---

## 🔧 Řešení Běžných Problémů

### ❌ Problem: "Přístup odepřen" (Windows)
**Řešení:**
```
1. Pravý klik na BAT soubor
2. "Spustit jako správce"
3. Povolte UAC dialog
```

### ❌ Problem: "PowerShell není povolen"
**Řešení:**
```powershell
# Otevřete PowerShell jako admin
Set-ExecutionPolicy RemoteSigned -Force

# Nebo pouze pro aktuální session:
Set-ExecutionPolicy Bypass -Scope Process
```

### ❌ Problem: "Antivirus blokuje"
**Řešení:**
```
1. Přidejte SuperNastroj složku do výjimek
2. Dočasně vypněte real-time protection
3. Whitelist všechny .bat/.ps1 soubory
```

### ❌ Problem: "Permission denied" (Linux)
**Řešení:**
```bash
# Nastavit oprávnění:
chmod +x *.sh

# Spustit s sudo:
sudo ./SuperNastroj_linux.sh
```

### ❌ Problem: "Command not found" (Linux/Android)
**Řešení:**
```bash
# Linux:
sudo apt install nmap curl wget git

# Android/Termux:
pkg install nmap curl wget git
```

### ❌ Problem: "Package not found" (Termux)
**Řešení:**
```bash
# Aktualizovat repositáře:
pkg update

# Změnit mirror:
termux-change-repo

# Pak znovu:
pkg install <package>
```

### ❌ Problem: "Storage permission denied" (Android)
**Řešení:**
```bash
# 1. Spusťte:
termux-setup-storage

# 2. Povolte v Android dialogu

# 3. Restartujte Termux

# 4. Zkontrolujte:
ls /sdcard
```

---

## 🎯 Rychlé Akce

### Windows - Rychlá Oprava:
```cmd
1. Spustit SuperNastroj_Complete.bat (jako admin)
2. Stisknout 1
3. Počkat 15-30 minut
4. Restartovat
```

### Linux - Systémová Diagnostika:
```bash
sudo ./SuperNastroj_linux.sh
# Volba 2 → Volba 1
```

### Android - Síťový Test:
```bash
./SuperNastroj_android.sh
# Volba 2 → Volba 4
```

---

## 📦 Struktura Po Instalaci

```
SuperNastroj/
├── SuperNastroj_Complete.bat      # Windows hlavní skript
├── SuperNastroj_linux.sh          # Linux hlavní skript
├── SuperNastroj_android.sh        # Android hlavní skript
├── SuperNastroj_launcher.sh       # Univerzální launcher
├── README.md                      # Dokumentace
│
├── SuperNastroj_Logs/             # Log soubory
│   ├── system.log
│   ├── errors.log
│   └── network.log
│
├── SuperNastroj_Tools/            # Generované nástroje
│   ├── security_scan.ps1
│   ├── network_tools.bat
│   └── ...
│
├── SuperNastroj_Backups/          # Zálohy
│   └── backup_YYYYMMDD.tar.gz
│
└── SuperNastroj_ISOs/             # ISO soubory pro boot
    └── (umístěte zde ISO)
```

---

## 🔄 Aktualizace

### Automatická Aktualizace:
```bash
# V menu nástroje:
# Windows: Volba 12
# Linux: Volba (check for updates)
# Android: Volba 12
```

### Manuální Aktualizace:
```bash
cd SuperNastroj
git pull origin main

# Nebo stáhněte novou verzi z GitHub
```

---

## 💡 Tipy Pro Začátečníky

### Windows:
1. ✅ Vždy zálohujte před používáním volby [1]
2. ✅ Pravidelně kontrolujte logy
3. ✅ Použijte [4] pro vytvoření záchranného USB
4. ✅ Volba [7] pro automatickou zálohu

### Linux:
1. ✅ Spouštějte s `sudo` pro plnou funkcionalitu
2. ✅ Pravidelně aktualizujte: `pkg update`
3. ✅ Kontrolujte systémové logy
4. ✅ Používejte diagnostiku před opravami

### Android:
1. ✅ Povolte úložiště: `termux-setup-storage`
2. ✅ Instalujte Termux:API pro více funkcí
3. ✅ Pravidelně aktualizujte Termux balíčky
4. ✅ Používejte WiFi analýzu pro problémy se sítí

---

## 📞 Podpora

### GitHub:
- 🐛 **Issues**: [Report problémů](https://github.com/Fatalerorr69/SuperNastroj/issues)
- 💬 **Discussions**: [Dotazy a diskuse](https://github.com/Fatalerorr69/SuperNastroj/discussions)
- 📖 **Wiki**: [Podrobná dokumentace](https://github.com/Fatalerorr69/SuperNastroj/wiki)

### Community:
- Přispějte kódem přes Pull Requests
- Nahlaste chyby přes Issues
- Sdílejte své zkušenosti v Discussions

---

## ⭐ Další Kroky

Po úspěšné instalaci:

1. ✅ Spusťte **diagnostiku** (Volba 2)
2. ✅ Prohlédněte **dokumentaci** (README.md)
3. ✅ Vytvořte **záchranné USB** (Volba 4 - Windows)
4. ✅ Nastavte **automatické zálohy** (Volba 7)
5. ✅ Ohodnoťte projekt na **GitHubu** ⭐

---

<div align="center">

**SuperNastroj v5.0** | Made with ❤️ by FatalErorr69

🚀 Production Ready | 🌍 Multiplatformní | 🔒 Open Source

</div>

---

**Poslední aktualizace:** 1. prosince 2024  
**Verze průvodce:** 5.0.0  
**Status:** ✅ Verified & Tested