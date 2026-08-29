generate_module_from_repo() {
  REPO="$1"
  NAME=$(basename "$REPO")
  TYPE=$(analyze_repo "$REPO")

  MOD="$ULTRA_ROOT/modules/$TYPE-$NAME"
  mkdir -p "$MOD/hooks"

  log "[MODULE] Generuji modul $TYPE-$NAME"

  cat > "$MOD/module.json" <<EOF
{
  "name": "$TYPE-$NAME",
  "source": "$NAME",
  "category": "$TYPE",
  "auto_generated": true
}
EOF

  cat > "$MOD/install.sh" <<'EOF'
#!/bin/bash
log "[MODULE] Instalace modulu $MODULE"
cp -r "$MODULE_DIR/source/"* "$ULTRA_ROOT/runtime/"
EOF

  chmod +x "$MOD/install.sh"

  cp -r "$REPO" "$MOD/source"

  echo "$TYPE-$NAME" >> "$ULTRA_ROOT/registry/extracted_modules.json"
}
