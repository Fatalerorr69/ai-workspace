#!/bin/bash

echo "🔐 Bezpečnostní audit..."
echo "Uživatelé:"
cut -d: -f1 /etc/passwd

echo "SSH stav:"
systemctl status ssh --no-pager

echo "Zranitelné balíčky:"
sudo apt list --upgradable 2>/dev/null | grep security
