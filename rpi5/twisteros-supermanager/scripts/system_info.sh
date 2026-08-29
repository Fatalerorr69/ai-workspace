#!/bin/bash

echo "🖥 Informace o systému:"
echo "OS: $(lsb_release -ds)"
echo "Kernel: $(uname -r)"
echo "CPU: $(lscpu | grep 'Model name')"
echo "RAM: $(free -h | awk '/Mem:/ {print $3\" / \"$2}')"
echo "Disk: $(df -h / | awk 'NR==2{print $3\" / \"$2}')"
