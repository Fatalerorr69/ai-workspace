install_pkg() {
  case "$PLATFORM" in
    linux)
      sudo apt-get install -y "$@"
      ;;
    wsl)
      sudo apt-get install -y "$@"
      ;;
    termux)
      pkg install -y "$@"
      ;;
  esac
}
