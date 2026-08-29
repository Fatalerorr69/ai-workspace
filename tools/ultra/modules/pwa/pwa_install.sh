#!/bin/bash
set -Eeuo pipefail
echo "[PWA] Instalace PWA UI"

mkdir -p ../../pwa
cat > ../../pwa/index.html <<EOF
<h1>ULTRA v17 PWA</h1>
<p>Dashboard připraven</p>
EOF
