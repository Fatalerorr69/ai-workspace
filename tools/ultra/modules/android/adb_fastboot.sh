install_adb_fastboot() {
  log "[ANDROID] Instalace ADB/Fastboot"

  TOOLS_ZIP="$CACHE_DIR/platform-tools.zip"
  TOOLS_DIR="$ULTRA_ROOT/android/platform-tools"

  download "$PLATFORM_TOOLS" "$TOOLS_ZIP"
  unzip -oq "$TOOLS_ZIP" -d "$ULTRA_ROOT/android"

  export PATH="$TOOLS_DIR:$PATH"
}
