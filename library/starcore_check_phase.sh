#!/bin/bash
# STARCORE Phase Checker
# Usage: ./check_phase.sh [A|B|C|D|E|F|G|H|all]

PHASE="${1:-all}"
cd ~/STARCORE

case $PHASE in
  A|a)
    echo "🔍 FÁZE A – Bootstrap"
    echo "  ✓ Termux: $(pkg list-installed 2>/dev/null | grep -c 'python\|git\|tmux' || echo 'OK')"
    echo "  ✓ Struktura: $(ls -la core 2>/dev/null | wc -l)"
    ;;
  B|b)
    echo "🔍 FÁZE B – Core CLI"
    ./starcore version 2>/dev/null && echo "  ✓ version OK" || echo "  ✗ version FAIL"
    ./starcore info 2>/dev/null && echo "  ✓ info OK" || echo "  ✗ info FAIL"
    ./starcore doctor 2>/dev/null && echo "  ✓ doctor OK" || echo "  ✗ doctor FAIL"
    ;;
  C|c)
    echo "🔍 FÁZE C – Service Manager"
    ./starcore status 2>/dev/null && echo "  ✓ status OK" || echo "  ✗ status FAIL"
    ;;
  D|d)
    echo "🔍 FÁZE D – HIVE Engine"
    ./starcore hive-status 2>/dev/null && echo "  ✓ hive-status OK" || echo "  ✗ hive-status FAIL"
    ;;
  E|e)
    echo "🔍 FÁZE E – Dashboard"
    curl -s http://localhost:8000/health > /dev/null && echo "  ✓ Dashboard běží" || echo "  ✗ Dashboard nedostupný"
    ;;
  F|f)
    echo "🔍 FÁZE F – AI Runtime"
    ./starcore ai-status 2>/dev/null && echo "  ✓ ai-status OK" || echo "  ✗ ai-status FAIL"
    ;;
  G|g|H|h)
    echo "🔍 FÁZE $PHASE – zatím neimplementována"
    ;;
  all|*)
    echo "🔍 KOMPLETNÍ KONTROLA VŠECH FÁZÍ"
    bash "$0" A
    bash "$0" B
    bash "$0" C
    bash "$0" D
    bash "$0" E
    bash "$0" F
    ;;
esac
