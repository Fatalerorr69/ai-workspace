install_ai_dependencies() {
  install_pkg python3 python3-venv python3-pip
}

install_offline_llm() {
  log "[AI] Instalace Ollama"

  if ! command -v ollama >/dev/null; then
    curl -fsSL "$OLLAMA/install.sh" | bash
  fi

  ollama pull llama3
}
