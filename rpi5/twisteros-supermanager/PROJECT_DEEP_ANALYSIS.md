# Hluboká analýza: twisteros-supermanager

## Základní informace
- **Cílová cesta:** $targetPath
- **Detekované technologie:** Shell
- **Počet skriptů:** 483

## Popis z README
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

## Seznam skriptů
- `rpi5\twisteros-supermanager\ai_workspace\ai_cli.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\ai_workspace\ai_engine.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\ai_workspace\ai_plugin_workspace.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\ai_workspace\ai_workspace_server.py` – !/usr/bin/env python3
- `rpi5\twisteros-supermanager\api\app.py` – !/usr/bin/env python3
- `rpi5\twisteros-supermanager\bin\wine-box64.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\api\app.py` – !/usr/bin/env python3
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\add_system_icons.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\apk_to_waydroid.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\config_reset.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\detect_mhs.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\fix_scripts.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\import_roms.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\install_ai_station.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\install_all.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\install_twister_smart_suite.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\kernel_selfheal.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\mhs_detect.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\mount_nas.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\network_diagnose.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\repair_boot.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\repair_fs.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\scrape_artwork.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\security_audit.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\self_healing_deamon.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\setup_mhs.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\setup_services.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\smart_menu.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\start_retroarch.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\start_twister_suite.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\start_wine_game.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\stav_SSH_sluzby.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\sync_bios.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\sync_roms.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\system_cleaner.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\system_info.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\test_mhs.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\theme_installer.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\update_all.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\build\twisteros-supermanager\opt\twisteros_supermanager\scripts\watchdog_services.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\deb_build\usr\local\twisteros_supermanager.sh` – Skript twisteros_supermanager.sh
- `rpi5\twisteros-supermanager\modules\fsck_module.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\modules\mbr_gpt_module.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\modules\network_check.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\modules\plugin_loader.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin_ai_assistant.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin_ai_workspace.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin_backup_restore.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin_backup.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin_disk_health.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin_esp32_gateway.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin_firewall.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin_iot_sensors.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin_kernel_update.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin_led_relay.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin_log_monitoring.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin_logs_analyzer.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin_mobile_upload.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin_rom_scanner.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin_self_health.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin_sensors.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin_system_stats.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin-conky.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin-dashboard.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin-fix_scripts.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin-fsck_module.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin-home_assistant.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin-mbr-gpt_module.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin-network_check.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\plugins\plugin-retro_games.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\add_system_icons.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\apk_to_waydroid.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\config_reset.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\detect_mhs.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\emulator_manager.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\fix_scripts.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\import_roms.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\install_ai_station.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\install_all.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\install_twister_smart_suite.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\kernel_selfheal.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\logger.sh` – Skript logger.sh
- `rpi5\twisteros-supermanager\scripts\menu.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\mhs_detect.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\mount_nas.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\nas_manager.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\network_diagnose.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\plugin_manager.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\repair_boot.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\repair_fs.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\scrape_artwork.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\security_audit.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\self_healing_deamon.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\setup_emulators.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\setup_mhs.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\setup_services.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\smart_menu.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\start_retroarch.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\start_twister_suite.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\start_wine_game.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\stav_SSH_sluzby.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\sync_bios.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\sync_roms.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\system_cleaner.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\system_info.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\test_mhs.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\theme_installer.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\update_all.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\scripts\watchdog_services.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\twister_gui\twister_gui.py` – !/usr/bin/env python3
- `rpi5\twisteros-supermanager\twister-dashboard\js\display_manager.js` – Skript display_manager.js
- `rpi5\twisteros-supermanager\twister-dashboard\js\nas_storage.js` – Skript nas_storage.js
- `rpi5\twisteros-supermanager\twister-dashboard\js\rom_manager.js` – Skript rom_manager.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\.bin\mime.cmd` – Skript mime.cmd
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\.bin\mime.ps1` – !/usr/bin/env pwsh
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\.bin\mkdirp.cmd` – Skript mkdirp.cmd
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\.bin\mkdirp.ps1` – !/usr/bin/env pwsh
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\accepts\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\append-field\lib\parse-path.js` – Skript parse-path.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\append-field\lib\set-value.js` – Skript set-value.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\append-field\test\forms.js` – * eslint-env mocha */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\append-field\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\array-flatten\array-flatten.js` – **
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\body-parser\lib\types\json.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\body-parser\lib\types\raw.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\body-parser\lib\types\text.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\body-parser\lib\types\urlencoded.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\body-parser\lib\read.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\body-parser\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\buffer-from\index.js` – * eslint-disable node/no-deprecated-api */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\busboy\bench\bench-multipart-fields-100mb-big.js` – Skript bench-multipart-fields-100mb-big.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\busboy\bench\bench-multipart-fields-100mb-small.js` – Skript bench-multipart-fields-100mb-small.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\busboy\bench\bench-multipart-files-100mb-big.js` – Skript bench-multipart-files-100mb-big.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\busboy\bench\bench-multipart-files-100mb-small.js` – Skript bench-multipart-files-100mb-small.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\busboy\bench\bench-urlencoded-fields-100pairs-small.js` – Skript bench-urlencoded-fields-100pairs-small.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\busboy\bench\bench-urlencoded-fields-900pairs-small-alt.js` – Skript bench-urlencoded-fields-900pairs-small-alt.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\busboy\lib\types\multipart.js` – Skript multipart.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\busboy\lib\types\urlencoded.js` – Skript urlencoded.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\busboy\lib\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\busboy\lib\utils.js` – Skript utils.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\busboy\test\common.js` – Skript common.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\busboy\test\test-types-multipart-charsets.js` – Skript test-types-multipart-charsets.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\busboy\test\test-types-multipart-stream-pause.js` – Skript test-types-multipart-stream-pause.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\busboy\test\test-types-multipart.js` – Skript test-types-multipart.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\busboy\test\test-types-urlencoded.js` – Skript test-types-urlencoded.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\busboy\test\test.js` – Skript test.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\busboy\.eslintrc.js` – Skript .eslintrc.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\bytes\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\call-bind-apply-helpers\test\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\call-bind-apply-helpers\actualApply.d.ts` – Skript actualApply.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\call-bind-apply-helpers\actualApply.js` – Skript actualApply.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\call-bind-apply-helpers\applyBind.d.ts` – Skript applyBind.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\call-bind-apply-helpers\applyBind.js` – Skript applyBind.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\call-bind-apply-helpers\functionApply.d.ts` – Skript functionApply.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\call-bind-apply-helpers\functionApply.js` – ** @type {import('./functionApply')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\call-bind-apply-helpers\functionCall.d.ts` – Skript functionCall.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\call-bind-apply-helpers\functionCall.js` – ** @type {import('./functionCall')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\call-bind-apply-helpers\index.d.ts` – Skript index.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\call-bind-apply-helpers\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\call-bind-apply-helpers\reflectApply.d.ts` – Skript reflectApply.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\call-bind-apply-helpers\reflectApply.js` – ** @type {import('./reflectApply')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\call-bound\test\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\call-bound\index.d.ts` – Skript index.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\call-bound\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\concat-stream\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\content-disposition\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\content-type\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\cookie\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\cookie-signature\index.js` – **
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\core-util-is\lib\util.js` – Copyright Joyent, Inc. and other Node contributors.
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\debug\src\browser.js` – **
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\debug\src\debug.js` – **
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\debug\src\index.js` – **
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\debug\src\inspector-log.js` – black hole
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\debug\src\node.js` – **
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\debug\karma.conf.js` – Karma configuration
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\debug\node.js` – Skript node.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\depd\lib\browser\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\depd\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\destroy\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\dunder-proto\test\get.js` – Skript get.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\dunder-proto\test\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\dunder-proto\test\set.js` – Skript set.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\dunder-proto\get.d.ts` – Skript get.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\dunder-proto\get.js` – Skript get.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\dunder-proto\set.d.ts` – Skript set.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\dunder-proto\set.js` – Skript set.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\ee-first\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\encodeurl\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-define-property\test\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-define-property\index.d.ts` – Skript index.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-define-property\index.js` – ** @type {import('.')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-errors\test\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-errors\eval.d.ts` – Skript eval.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-errors\eval.js` – ** @type {import('./eval')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-errors\index.d.ts` – Skript index.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-errors\index.js` – ** @type {import('.')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-errors\range.d.ts` – Skript range.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-errors\range.js` – ** @type {import('./range')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-errors\ref.d.ts` – Skript ref.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-errors\ref.js` – ** @type {import('./ref')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-errors\syntax.d.ts` – Skript syntax.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-errors\syntax.js` – ** @type {import('./syntax')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-errors\type.d.ts` – Skript type.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-errors\type.js` – ** @type {import('./type')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-errors\uri.d.ts` – Skript uri.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-errors\uri.js` – ** @type {import('./uri')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-object-atoms\test\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-object-atoms\index.d.ts` – Skript index.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-object-atoms\index.js` – ** @type {import('.')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-object-atoms\isObject.d.ts` – Skript isObject.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-object-atoms\isObject.js` – ** @type {import('./isObject')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-object-atoms\RequireObjectCoercible.d.ts` – Skript RequireObjectCoercible.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-object-atoms\RequireObjectCoercible.js` – ** @type {import('./RequireObjectCoercible')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-object-atoms\ToObject.d.ts` – Skript ToObject.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\es-object-atoms\ToObject.js` – Skript ToObject.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\escape-html\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\etag\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\express\lib\middleware\init.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\express\lib\middleware\query.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\express\lib\router\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\express\lib\router\layer.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\express\lib\router\route.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\express\lib\application.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\express\lib\express.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\express\lib\request.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\express\lib\response.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\express\lib\utils.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\express\lib\view.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\express\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\finalhandler\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\forwarded\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\fresh\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\function-bind\test\index.js` – jscs:disable requireUseStrict
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\function-bind\implementation.js` – * eslint no-invalid-this: 1 */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\function-bind\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\get-intrinsic\test\GetIntrinsic.js` – Skript GetIntrinsic.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\get-intrinsic\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\get-proto\test\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\get-proto\index.d.ts` – Skript index.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\get-proto\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\get-proto\Object.getPrototypeOf.d.ts` – Skript Object.getPrototypeOf.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\get-proto\Object.getPrototypeOf.js` – ** @type {import('./Object.getPrototypeOf')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\get-proto\Reflect.getPrototypeOf.d.ts` – Skript Reflect.getPrototypeOf.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\get-proto\Reflect.getPrototypeOf.js` – ** @type {import('./Reflect.getPrototypeOf')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\gopd\test\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\gopd\gOPD.d.ts` – Skript gOPD.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\gopd\gOPD.js` – ** @type {import('./gOPD')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\gopd\index.d.ts` – Skript index.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\gopd\index.js` – ** @type {import('.')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\has-symbols\test\shams\core-js.js` – Skript core-js.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\has-symbols\test\shams\get-own-property-symbols.js` – Skript get-own-property-symbols.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\has-symbols\test\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\has-symbols\test\tests.js` – ** @type {(t: import('tape').Test) => false | void} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\has-symbols\index.d.ts` – Skript index.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\has-symbols\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\has-symbols\shams.d.ts` – Skript shams.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\has-symbols\shams.js` – ** @type {import('./shams')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\hasown\index.d.ts` – Skript index.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\hasown\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\http-errors\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\iconv-lite\encodings\dbcs-codec.js` – Multibyte codec. In this scheme, a character is represented by 1 or more bytes.
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\iconv-lite\encodings\dbcs-data.js` – Description of supported double byte encodings and aliases.
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\iconv-lite\encodings\index.js` – Update this array if you add/rename/remove files in this directory.
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\iconv-lite\encodings\internal.js` – Export Node.js internal encodings.
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\iconv-lite\encodings\sbcs-codec.js` – Single-byte codec. Needs a 'chars' string parameter that contains 256 or 128 chars that
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\iconv-lite\encodings\sbcs-data-generated.js` – Generated data for sbcs codec. Don't edit manually. Regenerate using generation/gen-sbcs.js script.
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\iconv-lite\encodings\sbcs-data.js` – Manually added data to be used by sbcs codec in addition to generated one.
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\iconv-lite\encodings\utf16.js` – Note: UTF16-LE (or UCS2) codec is Node.js native. See encodings/internal.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\iconv-lite\encodings\utf7.js` – UTF-7 codec, according to https://tools.ietf.org/html/rfc2152
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\iconv-lite\lib\bom-handling.js` – Skript bom-handling.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\iconv-lite\lib\extend-node.js` – Note: not polyfilled with safer-buffer on a purpose, as overrides Buffer
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\iconv-lite\lib\index.d.ts` – *---------------------------------------------------------------------------------------------
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\iconv-lite\lib\index.js` – Some environments don't have global Buffer (e.g. React Native).
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\iconv-lite\lib\streams.js` – Skript streams.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\inherits\inherits_browser.js` – implementation from standard node.js 'util' module
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\inherits\inherits.js` – * istanbul ignore next */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\ipaddr.js\lib\ipaddr.js` – Skript ipaddr.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\ipaddr.js\lib\ipaddr.js.d.ts` – Skript ipaddr.js.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\ipaddr.js\ipaddr.min.js` – Skript ipaddr.min.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\isarray\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\isarray\test.js` – Skript test.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\constants\maxArrayLength.d.ts` – Skript maxArrayLength.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\constants\maxArrayLength.js` – ** @type {import('./maxArrayLength')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\constants\maxSafeInteger.d.ts` – Skript maxSafeInteger.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\constants\maxSafeInteger.js` – ** @type {import('./maxSafeInteger')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\constants\maxValue.d.ts` – Skript maxValue.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\constants\maxValue.js` – ** @type {import('./maxValue')}  */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\test\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\abs.d.ts` – Skript abs.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\abs.js` – ** @type {import('./abs')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\floor.d.ts` – Skript floor.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\floor.js` – ** @type {import('./floor')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\isFinite.d.ts` – Skript isFinite.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\isFinite.js` – ** @type {import('./isFinite')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\isInteger.d.ts` – Skript isInteger.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\isInteger.js` – Skript isInteger.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\isNaN.d.ts` – Skript isNaN.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\isNaN.js` – ** @type {import('./isNaN')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\isNegativeZero.d.ts` – Skript isNegativeZero.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\isNegativeZero.js` – ** @type {import('./isNegativeZero')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\max.d.ts` – Skript max.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\max.js` – ** @type {import('./max')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\min.d.ts` – Skript min.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\min.js` – ** @type {import('./min')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\mod.d.ts` – Skript mod.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\mod.js` – ** @type {import('./mod')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\pow.d.ts` – Skript pow.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\pow.js` – ** @type {import('./pow')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\round.d.ts` – Skript round.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\round.js` – ** @type {import('./round')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\sign.d.ts` – Skript sign.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\math-intrinsics\sign.js` – ** @type {import('./sign')} */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\media-typer\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\merge-descriptors\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\methods\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\mime\src\build.js` – !/usr/bin/env node
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\mime\src\test.js` – **
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\mime\cli.js` – !/usr/bin/env node
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\mime\mime.js` – Map of extension -> mime type
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\mime-db\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\mime-types\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\minimist\example\parse.js` – Skript parse.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\minimist\test\all_bool.js` – Skript all_bool.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\minimist\test\bool.js` – Skript bool.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\minimist\test\dash.js` – Skript dash.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\minimist\test\default_bool.js` – Skript default_bool.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\minimist\test\dotted.js` – Skript dotted.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\minimist\test\kv_short.js` – Skript kv_short.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\minimist\test\long.js` – Skript long.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\minimist\test\num.js` – Skript num.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\minimist\test\parse_modified.js` – Skript parse_modified.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\minimist\test\parse.js` – Skript parse.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\minimist\test\proto.js` – * eslint no-proto: 0 */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\minimist\test\short.js` – Skript short.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\minimist\test\stop_early.js` – Skript stop_early.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\minimist\test\unknown.js` – Skript unknown.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\minimist\test\whitespace.js` – Skript whitespace.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\minimist\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\mkdirp\bin\cmd.js` – !/usr/bin/env node
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\mkdirp\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\ms\index.js` – **
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\multer\lib\counter.js` – Skript counter.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\multer\lib\file-appender.js` – Skript file-appender.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\multer\lib\make-middleware.js` – Skript make-middleware.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\multer\lib\multer-error.js` – Skript multer-error.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\multer\lib\remove-uploaded-files.js` – Skript remove-uploaded-files.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\multer\storage\disk.js` – Skript disk.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\multer\storage\memory.js` – Skript memory.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\multer\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\negotiator\lib\encoding.js` – **
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\negotiator\lib\charset.js` – **
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\negotiator\lib\language.js` – **
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\negotiator\lib\mediaType.js` – **
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\negotiator\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\node-fetch\lib\index.es.js` – Skript index.es.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\node-fetch\lib\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\node-fetch\browser.js` – ref: https://github.com/tc39/proposal-global
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-assign\index.js` – *
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\example\all.js` – Skript all.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\example\circular.js` – Skript circular.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\example\fn.js` – Skript fn.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\example\inspect.js` – * eslint-env browser */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\test\browser\dom.js` – Skript dom.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\test\bigint.js` – Skript bigint.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\test\circular.js` – Skript circular.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\test\deep.js` – Skript deep.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\test\element.js` – Skript element.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\test\err.js` – Skript err.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\test\fakes.js` – Skript fakes.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\test\fn.js` – Skript fn.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\test\global.js` – Skript global.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\test\has.js` – Skript has.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\test\holes.js` – Skript holes.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\test\indent-option.js` – Skript indent-option.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\test\inspect.js` – Skript inspect.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\test\lowbyte.js` – Skript lowbyte.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\test\number.js` – Skript number.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\test\quoteStyle.js` – Skript quoteStyle.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\test\toStringTag.js` – Skript toStringTag.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\test\undef.js` – Skript undef.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\test\values.js` – Skript values.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\test-core-js.js` – Skript test-core-js.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\object-inspect\util.inspect.js` – Skript util.inspect.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\on-finished\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\parseurl\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\path-to-regexp\index.js` – **
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\process-nextick-args\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\proxy-addr\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\qs\dist\qs.js` – Skript qs.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\qs\lib\formats.js` – Skript formats.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\qs\lib\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\qs\lib\parse.js` – Skript parse.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\qs\lib\stringify.js` – Skript stringify.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\qs\lib\utils.js` – Skript utils.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\qs\test\empty-keys-cases.js` – Skript empty-keys-cases.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\qs\test\parse.js` – Skript parse.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\qs\test\stringify.js` – Skript stringify.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\qs\test\utils.js` – Skript utils.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\range-parser\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\raw-body\index.d.ts` – Skript index.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\raw-body\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\readable-stream\lib\internal\streams\BufferList.js` – Skript BufferList.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\readable-stream\lib\internal\streams\destroy.js` – *<replacement>*/
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\readable-stream\lib\internal\streams\stream-browser.js` – Skript stream-browser.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\readable-stream\lib\internal\streams\stream.js` – Skript stream.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\readable-stream\lib\_stream_duplex.js` – Copyright Joyent, Inc. and other Node contributors.
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\readable-stream\lib\_stream_passthrough.js` – Copyright Joyent, Inc. and other Node contributors.
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\readable-stream\lib\_stream_readable.js` – Copyright Joyent, Inc. and other Node contributors.
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\readable-stream\lib\_stream_transform.js` – Copyright Joyent, Inc. and other Node contributors.
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\readable-stream\lib\_stream_writable.js` – Copyright Joyent, Inc. and other Node contributors.
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\readable-stream\node_modules\safe-buffer\index.d.ts` – Skript index.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\readable-stream\node_modules\safe-buffer\index.js` – * eslint-disable node/no-deprecated-api */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\readable-stream\duplex-browser.js` – Skript duplex-browser.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\readable-stream\duplex.js` – Skript duplex.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\readable-stream\passthrough.js` – Skript passthrough.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\readable-stream\readable-browser.js` – Skript readable-browser.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\readable-stream\readable.js` – Skript readable.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\readable-stream\transform.js` – Skript transform.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\readable-stream\writable-browser.js` – Skript writable-browser.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\readable-stream\writable.js` – Skript writable.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\safe-buffer\index.d.ts` – Skript index.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\safe-buffer\index.js` – *! safe-buffer. MIT License. Feross Aboukhadijeh <https://feross.org/opensource> */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\safer-buffer\dangerous.js` – * eslint-disable node/no-deprecated-api */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\safer-buffer\safer.js` – * eslint-disable node/no-deprecated-api */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\safer-buffer\tests.js` – * eslint-disable node/no-deprecated-api */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\send\node_modules\encodeurl\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\send\node_modules\ms\index.js` – **
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\send\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\serve-static\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\setprototypeof\test\index.js` – * eslint-env mocha */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\setprototypeof\index.d.ts` – Skript index.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\setprototypeof\index.js` – * eslint no-proto: 0 */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\side-channel\test\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\side-channel\index.d.ts` – Skript index.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\side-channel\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\side-channel-list\test\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\side-channel-list\index.d.ts` – Skript index.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\side-channel-list\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\side-channel-list\list.d.ts` – Skript list.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\side-channel-map\test\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\side-channel-map\index.d.ts` – Skript index.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\side-channel-map\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\side-channel-weakmap\test\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\side-channel-weakmap\index.d.ts` – Skript index.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\side-channel-weakmap\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\statuses\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\streamsearch\lib\sbmh.js` – *
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\streamsearch\test\test.js` – Skript test.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\streamsearch\.eslintrc.js` – Skript .eslintrc.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\string_decoder\lib\string_decoder.js` – Copyright Joyent, Inc. and other Node contributors.
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\string_decoder\node_modules\safe-buffer\index.d.ts` – Skript index.d.ts
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\string_decoder\node_modules\safe-buffer\index.js` – * eslint-disable node/no-deprecated-api */
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\toidentifier\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\tr46\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\type-is\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\typedarray\example\tarray.js` – Skript tarray.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\typedarray\test\server\undef_globals.js` – Skript undef_globals.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\typedarray\test\tarray.js` – Skript tarray.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\typedarray\index.js` – Beyond this value, index getters/setters (i.e. array[0], array[1]) are so slow to
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\unpipe\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\util-deprecate\browser.js` – **
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\util-deprecate\node.js` – **
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\utils-merge\index.js` – **
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\vary\index.js` – *!
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\webidl-conversions\lib\index.js` – Skript index.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\whatwg-url\lib\public-api.js` – Skript public-api.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\whatwg-url\lib\URL-impl.js` – Skript URL-impl.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\whatwg-url\lib\url-state-machine.js` – Skript url-state-machine.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\whatwg-url\lib\URL.js` – Skript URL.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\whatwg-url\lib\utils.js` – Skript utils.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\xtend\immutable.js` – Skript immutable.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\xtend\mutable.js` – Skript mutable.js
- `rpi5\twisteros-supermanager\twister-dashboard\node_modules\xtend\test.js` – Skript test.js
- `rpi5\twisteros-supermanager\twister-dashboard\ai.js` – Skript ai.js
- `rpi5\twisteros-supermanager\twister-dashboard\app.js` – app.js - Twister Dashboard backend (Express)
- `rpi5\twisteros-supermanager\build_deb.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\check_project.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\install_from_github.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\install.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\supermanager.sh` – !/bin/bash
- `rpi5\twisteros-supermanager\twisteros_supermanager_full_installer.sh` – !/bin/bash


## Hodnocení a doporučení
<!-- Doplňte na základě výše uvedených informací -->
- 
