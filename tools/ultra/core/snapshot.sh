#!/bin/bash
SNAP_DIR="snapshots"
mkdir -p "$SNAP_DIR"

snapshot() {
  TS=$(date +%Y%m%d_%H%M%S)
  tar czf "$SNAP_DIR/ultra_$TS.tar.gz" .
  echo "[SNAPSHOT] uložen jako $SNAP_DIR/ultra_$TS.tar.gz"
}

rollback() {
  latest=$(ls -1t "$SNAP_DIR"/*.tar.gz | head -n1)
  [ -z "$latest" ] && echo "Žádný snapshot nenalezen" && return
  tar xzf "$latest" -C /
  echo "[ROLLBACK] obnoven $latest"
}
