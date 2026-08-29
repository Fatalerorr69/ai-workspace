plugin_market_list() {
  curl -s "$MARKETPLACE_URL/index.json" | jq -r '.plugins[]'
}

plugin_market_install() {
  PLUGIN="$1"
  DATA=$(curl -s "$MARKETPLACE_URL/plugins/$PLUGIN")

  REPO=$(echo "$DATA" | jq -r '.repo')
  NAME=$(echo "$DATA" | jq -r '.name')

  plugin_install "$REPO"
}
