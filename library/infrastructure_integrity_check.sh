#!/bin/bash

LOG="/opt/platform/security/integrity.log"

echo "Kontrola integrity systému..." | tee -a "$LOG"
lynis audit system >> "$LOG"
