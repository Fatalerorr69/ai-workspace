#!/usr/bin/env bash
acode_plugin_meta() {
  cat <<EOF
{
  "name": "ci_plugin",
  "version": "0.1.0",
  "author": "Starko",
  "description": "Lokální CI runner pro smoke testy"
}
EOF
}
acode_plugin_init() {
  WORKDIR="$1"
  mkdir -p "$WORKDIR/plugins/ci/logs"
  echo "ci_plugin: inicializováno"
}
acode_plugin_run() {
  PROJECT="${1:-$HOME/projects}"
  LOG="$WORKDIR/plugins/ci/logs/ci_$(date +%F_%H-%M).log"
  echo "ci_plugin: spouštím smoke testy pro $PROJECT" | tee "$LOG"
  if [ -f "$PROJECT/package.json" ]; then
    (cd "$PROJECT" && npm install --no-audit --no-fund) >> "$LOG" 2>&1 || echo "npm install selhalo" >> "$LOG"
    (cd "$PROJECT" && npm test) >> "$LOG" 2>&1 || echo "npm test selhalo" >> "$LOG"
  fi
  echo "CI log uložen: $LOG"
}
