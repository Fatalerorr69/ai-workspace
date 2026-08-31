#!/bin/bash
# Plugin: LED/Relay Control
PIN=17

echo "⚡ Nastavuji GPIO $PIN..."
gpio -g mode $PIN out

case "$1" in
  on)  gpio -g write $PIN 1; echo "LED ON";;
  off) gpio -g write $PIN 0; echo "LED OFF";;
  status) gpio -g read $PIN;;
esac
