detect_android_device() {
  log "[ANDROID] Detekce zařízení"

  adb start-server
  adb wait-for-device

  MODEL=$(adb shell getprop ro.product.model | tr -d '\r')
  BRAND=$(adb shell getprop ro.product.brand | tr -d '\r')
  SDK=$(adb shell getprop ro.build.version.sdk | tr -d '\r')

  echo "[ANDROID] $BRAND $MODEL (SDK $SDK)"
}
