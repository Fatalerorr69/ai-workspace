plugin_install() {
  ID="$1"
  PLUGIN=$(jq -r ".plugins[] | select(.id==\"$ID\")" registry/plugin_marketplace.json)
  REPO=$(echo "$PLUGIN" | jq -r .repo)

  [ -z "$REPO" ] && echo "Plugin nenalezen" && return 1

  log "[PLUGIN] Instalace $ID"
  git clone "$REPO" "plugins/enabled/$ID"

  if [ -f "plugins/enabled/$ID/install.sh" ]; then
    bash "plugins/enabled/$ID/install.sh"
  fi
}
