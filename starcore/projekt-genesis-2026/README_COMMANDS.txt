1. První připojení (SSH)
Pokud jste v Raspberry Pi Imageru nastavili jméno a heslo, nemusíte připojovat monitor ani klávesnici.

Otevřete terminál na svém PC (PowerShell ve Windows nebo Terminál v macOS/Linux).

Připojte se k RPi (nahraďte uzivatel vaším jménem, např. admin, a hostname názvem RPi):

Bash

ssh uzivatel@hostname.local
# Příklad: ssh admin@genesis-aeterna.local
Potvrďte otisk klíče napsáním yes a zadejte heslo.

2. Aktualizace systému a Firmwaru (Kritické pro RPi 5)
Raspberry Pi 5 je nový hardware a často vycházejí aktualizace pro jeho bootloader a správu napájení.

Aktualizace balíčků:

Bash

sudo apt update && sudo apt full-upgrade -y
Aktualizace EEPROM (Bootloaderu): To je specifické pro RPi 5. Zajišťuje lepší kompatibilitu s NVMe disky a USB bootováním.

Bash

sudo rpi-eeprom-update -a
Pokud se něco aktualizovalo, je nutný restart:

Bash

sudo reboot
3. Základní konfigurace (Raspi-Config)
I když jste něco nastavili v Imageru, zde doladíme detaily.

Spusťte konfigurační nástroj:

Bash

sudo raspi-config
Doporučená nastavení:

Advanced Options -> Expand Filesystem: (Ujistěte se, že využíváte celou kapacitu karty/disku).

Performance Options -> Fan: Nastavte chování ventilátoru (pokud máte Active Cooler, systém ho řídí sám, ale zde to můžete ověřit).

Localisation Options: Nastavte časové pásmo (Timezone) na Europe/Prague (důležité pro logy).

4. Aktivace "Turbo módu" pro SSD (PCIe Gen 3)
Pokud používáte NVMe SSD disk (což pro Genesis silně doporučuji), RPi 5 defaultně běží na pomalejší rychlosti (Gen 2). Musíme vynutit Gen 3.

Otevřete konfigurační soubor:

Bash

sudo nano /boot/firmware/config.txt
# (U starších verzí OS to může být /boot/config.txt)
Na úplný konec souboru přidejte tyto řádky:

Plaintext

# Aktivace PCIe Gen 3 pro NVMe
dtparam=pciex1_gen=3
Uložte (Ctrl+O, Enter) a zavřete (Ctrl+X).

5. Zabezpečení (Firewall & Ochrana)
Než začnete instalovat složité věci, zamkněte dveře.

Nainstalujte UFW (Uncomplicated Firewall):

Bash

sudo apt install ufw -y
Nastavte pravidla (Nejdřív povolte SSH, jinak se zamknete ven!):

Bash

sudo ufw allow 22/tcp          # Povolit SSH
sudo ufw allow 8050/tcp        # Povolit budoucí Dashboard
sudo ufw allow 3000/tcp        # Povolit budoucí AI WebUI
sudo ufw enable                # Zapnout firewall
6. Instalace "Motoru" (Docker & Git & Python)
Nyní připravíme půdu pro Genesis skripty.

Instalace Dockeru (pro kontejnery):

Bash

curl -sSL https://get.docker.com | sh
sudo usermod -aG docker $USER  # Přidání uživatele do skupiny docker
(Pro projevení změn se musíte odhlásit a přihlásit, nebo restartovat).

Instalace Pythonu a nástrojů:

Bash

sudo apt install -y python3-pip git htop neofetch
🏁 Co dál? (Přechod na Genesis)
V tomto bodě máte čistý, aktualizovaný a zabezpečený Linux server.

Nyní je ten správný moment pro spuštění instalačního skriptu Genesis, který jsme vytvořili v předchozích krocích:

Vytvořit složku: mkdir -p ~/genesis/tools

Vytvořit skript: nano ~/genesis/tools/install_genesis.sh

Vložit obsah ze souboru 04_TOOLS.txt.

Spustit ho.

Přístup k Dashboardu: http://genesis-aeterna.local:8050

Přístup k Ollama (AI): http://genesis-aeterna.local:3000

SSH Připojení: ssh admin@genesis-aeterna.local

Restart Dashboardu: pkill -f genesis_hud.py && nohup python3 ~/genesis/tools/genesis_hud.py &
