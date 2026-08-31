install_magisk() {
  log "[ANDROID] Stahuji Magisk"

  MAGISK_JSON=$(curl -s "$MAGISK")
  MAGISK_URL=$(echo "$MAGISK_JSON" | grep browser_download_url | grep apk | head -n1 | cut -d '"' -f4)

  MAGISK_APK="$CACHE_DIR/magisk.apk"
  download "$MAGISK_URL" "$MAGISK_APK"

  adb install -r "$MAGISK_APK"
}
