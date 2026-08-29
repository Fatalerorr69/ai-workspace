#!/bin/bash
# Plugin: Sensors
echo "📡 Detekce a čtení systémových senzorů..."

sudo apt install -y lm-sensors
sudo sensors-detect --auto

echo "🌡 CPU a GPU:"
vcgencmd measure_temp
sensors
