android_security_audit() {
  log "[ANDROID] Bezpečnostní audit"

  adb shell getprop ro.boot.flash.locked
  adb shell getprop ro.boot.verifiedbootstate
  adb shell id
}
