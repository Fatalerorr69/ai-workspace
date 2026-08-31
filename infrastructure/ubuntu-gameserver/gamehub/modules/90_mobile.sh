#!/bin/bash

setup_mobile_manifest() {
    info "Konfigurace PWA Manifestu..."
    cat > /var/www/gamehub/manifest.json <<EOF
{
  "name": "GameHub Ultimate",
  "short_name": "GameHub",
  "icons": [
    { "src": "https://cdn-icons-png.flaticon.com/512/808/808518.png", "sizes": "512x512", "type": "image/png" }
  ],
  "start_url": "/index.html",
  "display": "standalone",
  "background_color": "#0a0a0c",
  "theme_color": "#7000ff"
}
EOF
    # Přidání linku do HTML dashboardu
    sed -i '/<head>/a \    <link rel="manifest" href="/manifest.json">' /var/www/gamehub/index.html
}
