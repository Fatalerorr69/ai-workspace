android_install() {
  log "[ANDROID] Instalace Android ULTRA modulu"

  source "$ULTRA_ROOT/modules/android/adb_fastboot.sh"
  source "$ULTRA_ROOT/modules/android/device_detect.sh"
  source "$ULTRA_ROOT/modules/android/magisk_manager.sh"
  source "$ULTRA_ROOT/modules/android/rom_detector.sh"
  source "$ULTRA_ROOT/modules/android/security_audit.sh"

  install_adb_fastboot
  detect_android_device
}
