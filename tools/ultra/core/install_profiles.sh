install_all() {
  log "Plná instalace"
  install_core_only
  # zde se budou volat moduly

  source "$ULTRA_ROOT/modules/android/android_install.sh"
  source "$ULTRA_ROOT/modules/ai/ai_install.sh"
  source "$ULTRA_ROOT/modules/web/web_install.sh"
  source "$ULTRA_ROOT/modules/pentest/pentest_install.sh"

  android_install
  ai_install
  web_install
  pentest_install

}

install_custom() {
  log "Vlastní instalace (zatím základ)"
  install_core_only
}

install_core_only() {
  log "Instaluji CORE"
}
