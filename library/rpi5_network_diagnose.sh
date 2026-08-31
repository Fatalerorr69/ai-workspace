#!/bin/bash

echo "🌐 Kontrola připojení:"
ping -c 3 8.8.8.8 || echo "❌ Internet nedostupný"
ping -c 3 rpi5.local || echo "❌ mDNS nefunguje"

echo "📡 Otevřené porty:"
ss -tulnp | grep -E "(:22|:1880|:8123|:8080|:5900)"
