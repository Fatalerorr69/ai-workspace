#!/usr/bin/env bash
set -e

### ===============================
### ZÁKLADNÍ PROMĚNNÉ
### ===============================
BASE="$HOME/acode-dev-tools"
BIN="$HOME/.local/bin"
CACHE="$HOME/.cache/acode-dev"
LOG="$CACHE/install.log"
VERSION="1.0.0"

mkdir -p "$BASE" "$BIN" "$CACHE"
exec > >(tee -a "$LOG") 2>&1

log(){ echo "[ACODE-DEV] $1"; }

### ===============================
### BOOTSTRAP (MINIMÁLNÍ PROSTŘEDÍ)
### ===============================
ensure_cmd() {
  if ! command -v "$1" >/dev/null; then
    log "⚠️ $1 chybí"
    return 1
  fi
  return 0
}

### ===============================
### DETEKCE BALÍČKOVAČE
### ===============================
if command -v pkg >/dev/null; then
  INSTALL="pkg install -y"
elif command -v apt >/dev/null; then
  INSTALL="apt install -y"
else
  INSTALL=""
fi

### ===============================
### INSTALACE ZÁKLADU
### ===============================
for p in git curl dialog nc inotifywait node npm; do
  ensure_cmd "$p" || {
    [ -n "$INSTALL" ] && $INSTALL "$p" || log "⚠️ $p nelze nainstalovat"
  }
done

### ===============================
### STRUKTURA
### ===============================
mkdir -p "$BASE"/{core,ai,gui,web,watcher,update,docs,plugins}

### ===============================
### CORE
### ===============================
cat > "$BASE/core/env.sh" <<'EOF'
export ACODE_DEV_HOME="$HOME/acode-dev-tools"
export ACODE_CACHE="$HOME/.cache/acode-dev"
export PATH="$HOME/.local/bin:$PATH"
EOF

cat > "$BASE/core/logger.sh" <<'EOF'
log(){ echo "[$(date '+%H:%M:%S')] $1" | tee -a "$ACODE_CACHE/runtime.log"; }
EOF

cat > "$BASE/core/plugin_loader.sh" <<'EOF'
for p in ~/acode-dev-tools/plugins/*.sh; do
  [ -x "$p" ] && source "$p"
done
EOF

cat > "$BASE/core/doctor.sh" <<'EOF'
#!/usr/bin/env bash
for b in git curl dialog node npm nc; do
  command -v $b >/dev/null && echo "✓ $b" || echo "✗ $b"
done
EOF
chmod +x "$BASE/core/doctor.sh"

### ===============================
### AI
### ===============================
cat > "$BASE/ai/ai_config.env" <<'EOF'
AI_MODEL_LIGHT=phi
AI_MODEL_FULL=codellama:7b
EOF

cat > "$BASE/ai/install_ai.sh" <<'EOF'
#!/usr/bin/env bash
command -v ollama >/dev/null || curl -fsSL https://ollama.com/install.sh | sh
ollama pull phi
ollama pull codellama:7b
EOF
chmod +x "$BASE/ai/install_ai.sh"

cat > "$BASE/ai/ai_analyze.sh" <<'EOF'
#!/usr/bin/env bash
ollama run phi "Analyze project structure and code quality."
EOF
chmod +x "$BASE/ai/ai_analyze.sh"

cat > "$BASE/ai/ai_autofix.sh" <<'EOF'
#!/usr/bin/env bash
BACKUP=".ai_backup_$(date +%s)"
cp -r . "$BACKUP"
ollama run codellama:7b "Generate unified diff patch." > fix.patch
patch -p1 < fix.patch
EOF
chmod +x "$BASE/ai/ai_autofix.sh"

cat > "$BASE/ai/ai_security_scan.sh" <<'EOF'
#!/usr/bin/env bash
grep -R "eval\|password\|token" . || echo "OK"
EOF
chmod +x "$BASE/ai/ai_security_scan.sh"

### ===============================
### WATCHER
### ===============================
cat > "$BASE/watcher/watch_ai.sh" <<'EOF'
#!/usr/bin/env bash
inotifywait -m -e modify . | while read; do
  bash ~/acode-dev-tools/ai/ai_analyze.sh
done
EOF
chmod +x "$BASE/watcher/watch_ai.sh"

### ===============================
### WEB GUI
### ===============================
cat > "$BASE/web/server.sh" <<'EOF'
#!/usr/bin/env bash
PORT=8686
while true; do
{
echo "HTTP/1.1 200 OK"
echo "Content-Type: text/html"
echo ""
echo "<h2>Acode Dev Toolkit</h2>"
} | nc -l -p $PORT
done
EOF
chmod +x "$BASE/web/server.sh"

### ===============================
### TUI
### ===============================
cat > "$BASE/gui/tui.sh" <<'EOF'
#!/usr/bin/env bash
dialog --menu "Acode Dev Toolkit" 20 60 6 \
1 "AI Analyze" \
2 "AI AutoFix" \
3 "Security Scan" \
4 "Watch" \
5 "Web GUI" \
6 "Doctor" \
0 "Exit" 3>&1 1>&2 2>&3 | {
read c
case $c in
1) bash ~/acode-dev-tools/ai/ai_analyze.sh ;;
2) bash ~/acode-dev-tools/ai/ai_autofix.sh ;;
3) bash ~/acode-dev-tools/ai/ai_security_scan.sh ;;
4) bash ~/acode-dev-tools/watcher/watch_ai.sh ;;
5) bash ~/acode-dev-tools/web/server.sh ;;
6) bash ~/acode-dev-tools/core/doctor.sh ;;
esac
}
EOF
chmod +x "$BASE/gui/tui.sh"

### ===============================
### UPDATER
### ===============================
cat > "$BASE/update/update.sh" <<'EOF'
#!/usr/bin/env bash
cd ~/acode-dev-tools && git pull
EOF
chmod +x "$BASE/update/update.sh"

### ===============================
### META
### ===============================
echo "$VERSION" > "$BASE/VERSION"
echo "alias ai='bash ~/acode-dev-tools/gui/tui.sh'" >> ~/.bashrc

log "✅ Instalace kompletní"
log "➡ Spusť: ai"
log "📄 Log: $LOG"