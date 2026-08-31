repair_structure() {
  log "[REPAIR] Oprava struktury ULTRA"

  for d in modules plugins cache logs runtime registry; do
    mkdir -p "$ULTRA_ROOT/$d"
  done

  for m in "$ULTRA_ROOT/modules/"*; do
    [ -d "$m" ] || continue
    [ -f "$m/install.sh" ] || echo "#!/bin/bash" > "$m/install.sh"
    [ -f "$m/module.json" ] || echo "{}" > "$m/module.json"
    chmod +x "$m/install.sh"
  done
}
