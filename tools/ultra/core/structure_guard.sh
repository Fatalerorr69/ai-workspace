#!/bin/bash
structure_guard() {
  echo "[STRUCTURE] Kontrola složek a souborů ULTRA..."
  for dir in core modules plugins web gui logs registry pwa; do
    [ ! -d "$ULTRA_ROOT/$dir" ] && echo "[STRUCTURE] Vytvořena složka $dir" && mkdir -p "$ULTRA_ROOT/$dir"
  done
}

auto_fix() {
  echo "[AI-FIX] Automatická kontrola a oprava chybějících souborů..."
  for file in core/ai_engine.sh core/module_loader.sh core/plugin_recommender.sh; do
    [ ! -f "$ULTRA_ROOT/$file" ] && echo "[AI-FIX] Vytvořen $file" && touch "$ULTRA_ROOT/$file"
  done
}
