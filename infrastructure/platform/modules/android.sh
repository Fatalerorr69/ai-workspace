#!/bin/bash

log_info "Instaluji Android prostředí (Waydroid)"

apt install -y waydroid weston

waydroid init

mkdir -p /srv/android

cat <<EOF >/srv/android/README.txt
Android Lab:
- Waydroid environment
- Používej pro testování APK a mobilních aplikací
EOF

log_ok "Android lab připraven"
