system_check() {
  echo "[CORE] Kontrola systému"

  OS="$(uname -o | tr '[:upper:]' '[:lower:]')"
  ARCH="$(uname -m)"

  if [[ "$OS" == *android* ]]; then
    PLATFORM="termux"
  elif grep -qi microsoft /proc/version 2>/dev/null; then
    PLATFORM="wsl"
  else
    PLATFORM="linux"
  fi

  export PLATFORM ARCH

  echo "[CORE] Platforma: $PLATFORM"
  echo "[CORE] Architektura: $ARCH"

  for bin in bash curl tar; do
    command -v "$bin" >/dev/null || {
      echo "[CORE] Chybí nástroj: $bin"
      exit 1
    }
  done
}
