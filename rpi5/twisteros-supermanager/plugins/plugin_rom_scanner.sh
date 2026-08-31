#!/bin/bash
echo "🎮 ROM Scanner..."

ROMDIR=~/Games/ROMs

echo "📄 Seznam ROM:"
find "$ROMDIR" -type f | sed 's/^/- /'
