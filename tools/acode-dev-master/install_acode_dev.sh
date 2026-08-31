#!/usr/bin/env bash
set -e

BASE="$HOME/acode-dev-tools"
BIN="$HOME/.local/bin"
CACHE="$HOME/.cache/acode-dev"

mkdir -p "$BASE" "$BIN" "$CACHE"

#################################
# ZÁKLADNÍ NÁSTROJE
#################################
install_pkg() {
  if command -v pkg >/dev/null; then
    pkg install -y "$1"
  elif command -v apt >/dev/null; then
    apt install -y "$1"
  fi
}

for p in git curl dialog unzip inotify-tools nodejs npm; do
  command -v $p >/dev/null || install_pkg $p
done

#################################
# STRUKTURA
#################################
mkdir -p \
"$BASE"/{core,ai,gui,web,watcher,docs,plugins}

#################################
# CORE
#################################
cat > "$BASE/core/env.sh" <<'EOF'
export ACODE_DEV_HOME="$HOME/acode-dev-tools"
export ACODE_CACHE="$HOME/.cache/acode-dev"
export PATH="$HOME/.local/bin:$PATH"
EOF

cat > "$BASE/core/hw_profile.sh" <<'EOF'
MEM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
[ "$MEM" -lt 3000000 ] && export HW_PROFILE=light || export HW_PROFILE=full
EOF

#################################
# AI KONFIGURACE
#################################
cat > "$BASE/ai/ai_config.env" <<'EOF'
AI_MODEL_LIGHT=phi
AI_MODEL_FULL=codellama:7b
EOF

#################################
# AI INSTALACE
#################################
cat > "$BASE/ai/install_ai.sh" <<'EOF'
#!/usr/bin/env bash
if ! command -v ollama >/dev/null; then
  curl -fsSL https://ollama.com/install.sh | sh
fi
ollama pull phi
ollama pull codellama:7b
EOF
chmod +x "$BASE/ai/install_ai.sh"

#################################
# AI ANALÝZA
#################################
cat > "$BASE/ai/ai_analyze.sh" <<'EOF'
#!/usr/bin/env bash
source ~/acode-dev-tools/core/hw_profile.sh
source ~/acode-dev-tools/ai/ai_config.env
MODEL=$([ "$HW_PROFILE" = light ] && echo $AI_MODEL_LIGHT || echo $AI_MODEL_FULL)
ollama run $MODEL "Analyze this project and suggest improvements."
EOF
chmod +x "$BASE/ai/ai_analyze.sh"

#################################
# AI AUTOFIX
#################################
cat > "$BASE/ai/ai_autofix.sh" <<'EOF'
#!/usr/bin/env bash
BACKUP=".ai_backup_$(date +%s)"
cp -r . "$BACKUP"
ollama run codellama:7b "Generate unified diff patch to fix bugs." > fix.patch
patch -p1 < fix.patch
EOF
chmod +x "$BASE/ai/ai_autofix.sh"

#################################
# SECURITY SCAN
#################################
cat > "$BASE/ai/ai_security_scan.sh" <<'EOF'
#!/usr/bin/env bash
grep -R "eval\|password\|token\|secret" . || echo "No obvious risks found"
EOF
chmod +x "$BASE/ai/ai_security_scan.sh"

#################################
# WATCH MODE
#################################
cat > "$BASE/watcher/watch_ai.sh" <<'EOF'
#!/usr/bin/env bash
inotifywait -m -e modify . | while read; do
  bash ~/acode-dev-tools/ai/ai_analyze.sh
done
EOF
chmod +x "$BASE/watcher/watch_ai.sh"

#################################
# TUI GUI
#################################
cat > "$BASE/gui/tui.sh" <<'EOF'
#!/usr/bin/env bash
dialog --menu "Acode Dev Toolkit" 20 70 8 \
1 "AI Analyze" \
2 "AI AutoFix" \
3 "Security Scan" \
4 "Watch Mode" \
5 "Web GUI" \
0 "Exit" 3>&1 1>&2 2>&3 | {
read c
case $c in
1) bash ~/acode-dev-tools/ai/ai_analyze.sh ;;
2) bash ~/acode-dev-tools/ai/ai_autofix.sh ;;
3) bash ~/acode-dev-tools/ai/ai_security_scan.sh ;;
4) bash ~/acode-dev-tools/watcher/watch_ai.sh ;;
5) bash ~/acode-dev-tools/web/server.sh ;;
esac
}
EOF
chmod +x "$BASE/gui/tui.sh"

#################################
# WEB GUI
#################################
cat > "$BASE/web/server.sh" <<'EOF'
#!/usr/bin/env bash
while true; do
  echo -e "HTTP/1.1 200 OK\n\nAcode Dev Toolkit running" | nc -l -p 8686
done
EOF
chmod +x "$BASE/web/server.sh"

#################################
# ALIAS
#################################
echo "alias ai='bash ~/acode-dev-tools/gui/tui.sh'" >> ~/.bashrc

echo "✅ Instalace hotová"
echo "➡ Spusť: ai"