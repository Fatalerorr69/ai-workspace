# twisteros_supermanager
📘 README.md – Twister Smart Suite v3.0

Kompletní Smart OS rozšíření pro Twister OS na Raspberry Pi 5

🌀 Twister Smart Suite v3.0

Twister Smart Suite je pokročilý modulární systém pro Twister OS / Raspberry Pi 5, který přidává:

Home Assistant Smart Home Hub

Node-RED automatizace

MQTT server

Web Dashboard (port 8080)

Herní ROM & BIOS manager

Systémové nástroje (VNC, Conky, Docker, kernel self-heal)

Automatické opravy OS

Plugin systém

Monitorování výkonu

OS optimalizaci pro RPi5

Projekt je navržen pro jednoduchou instalaci, obnovu a správu vašeho RPi5.

🚀 Funkce
✔ Smart Home

Home Assistant (lokální běh, bez cloud závislosti)

Node-RED pro vizuální automatizace

MQTT broker (Mosquitto)

🎮 Herní systém

Automatická instalace BIOS a ROM kolekcí

RetroArch nastavení

Dynamické doplňování ROM z mobilu přes web

🖥 Systém a monitoring

VNC server s automatickým spuštěním

Conky systémový monitor

Docker engine + docker compose

Webový Dashboard s přístupem k systémovým funkcím

🛠 Samoopravné mechanismy

Kernel SelfHeal (oprava modulů, firmware, initramfs)

Boot repair (cmdline.txt, config.txt, EEPROM)

Filesystem Repair (ext4 + vfat)

AutoStart daemoni pro kontrolu běhu služeb

🧩 Plugin System

Modulární struktura umožňuje přidávání nových rozšíření:

Plugin pro Smart Sensors

Plugin pro LED/Relay/ESP32 automaci

Plugin pro herní metadata + scraping

Plugin pro systémové logy

Plugin pro zálohování OS

Plugin pro mobilní upload APK / ROM

📦 Instalace

Stáhni si instalátor a spusť:

wget https://your-github-url/install_twister_smart_suite.sh
chmod +x install_twister_smart_suite.sh
./install_twister_smart_suite.sh


Po instalaci se aktivují:

Dashboard: http://rpi5.local:8080

Home Assistant: http://rpi5.local:8123

Node-RED: http://rpi5.local:1880

VNC: rpi5.local:5900

twister-smart-suite/
│
├── install_twister_smart_suite.sh
├── fix_scripts.sh
├── kernel_selfheal.sh
├── repair_boot.sh
├── repair_fs.sh
├── stav_SSH_sluzby.sh
├── check_twister_smart_suite.sh
├── plugins/
│   ├── plugin_sensors.sh
│   ├── plugin_led_relay.sh
│   ├── plugin_esp32_gateway.sh
│   ├── plugin_rom_scanner.sh
│   ├── plugin_backup_restore.sh
│   ├── plugin_logs_analyzer.sh
│   └── plugin_mobile_upload.sh
│
├── dashboard/
│   ├── index.html
│   ├── api/
│   │   ├── status.json
│   │   ├── docker-status.sh
│   │   ├── system-info.sh
│   │   └── rom-list.sh
│   └── static/
│       ├── style.css
│       └── logo.png
│
└── autostart/
    ├── twister_smart_autostart.sh
    └── systemd-services/
        └── twister-smart-suite.service



Nastav API klíč:

```bash
export TWISTER_API_KEY="tvoje_silne_heslo"


Spusť Flask API:

python3 api/app.py


Spusť GTK GUI:

python3 twister_gui/twister_gui.py