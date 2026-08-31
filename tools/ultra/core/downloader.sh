download() {
  local url="$1"
  local out="$2"

  mkdir -p "$(dirname "$out")"

  echo "[DL] $url"

  if command -v curl >/dev/null; then
    curl -L --retry 5 --continue-at - "$url" -o "$out"
  else
    wget -c "$url" -O "$out"
  fi
}
