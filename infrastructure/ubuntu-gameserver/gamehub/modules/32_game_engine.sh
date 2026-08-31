#!/bin/bash

setup_minecraft_paper() {
    info "Konfigurace optimalizovaného Minecraft (Paper) prostředí..."
    mkdir -p "$INSTALL_DIR/servers/minecraft"
    
    # Stažení "Aikar's Flags" - nejlepší startup parametry pro Javu
    cat > "$INSTALL_DIR/servers/minecraft/start.sh" <<EOF
#!/bin/bash
java -Xms4G -Xmx4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Dterminal.jline=false -jar paper.jar nogui
EOF
    chmod +x "$INSTALL_DIR/servers/minecraft/start.sh"
}

setup_steam_autoupdate() {
    info "Nastavení automatických aktualizací pro Steam hry..."
    cat > "$INSTALL_DIR/scripts/update_steam_games.sh" <<EOF
#!/bin/bash
# Skript pro update CS2/Rust/ARK serverů
steamcmd +force_install_dir "$INSTALL_DIR/servers/cs2" +login anonymous +app_update 730 validate +quit
EOF
    chmod +x "$INSTALL_DIR/scripts/update_steam_games.sh"
}
