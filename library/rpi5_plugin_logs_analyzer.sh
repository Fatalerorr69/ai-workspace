#!/bin/bash
echo "📝 Analyzuji systémové logy..."
journalctl -p err -b
