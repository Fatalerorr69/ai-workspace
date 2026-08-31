#!/bin/bash

CONFIG="/opt/platform/security/security_config.json"
LOG="/opt/platform/security/security.log"

PORTS=$(jq -r '.ports_allowed[]' "$CONFIG")

ufw reset
ufw default deny incoming
ufw default allow outgoing

for port in $PORTS; do
  ufw allow $port/tcp
done

ufw --force enable

echo "Firewall nastaven." | tee -a "$LOG"
