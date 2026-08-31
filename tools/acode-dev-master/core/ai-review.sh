#!/usr/bin/env bash
# AI review – bezpečné volání AI enginu, výstup jako návrh do .ai.suggest
set -euo pipefail

FILE="${1:-}"
if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  echo "Chyba: zadej cestu k souboru jako první argument" >&2
  exit 1
fi

MAX_BYTES=200000
SIZE=$(wc -c < "$FILE")
if [ "$SIZE" -gt "$MAX_BYTES" ]; then
  echo "Soubor je příliš velký pro AI review (>$MAX_BYTES bajtů)" >&2
  exit 1
fi

OUT="${FILE}.ai.suggest"
ENGINE="${ACODE_AI_ENGINE:-auto}"

echo "Generuji návrh AI (neaplikuje se automaticky). Engine: $ENGINE"

if command -v ollama >/dev/null 2>&1; then
  ollama run codellama "Analyze and propose a patch for the following file:" < "$FILE" > "$OUT" || true
elif command -v openai >/dev/null 2>&1; then
  openai api completions.create -m text-davinci-003 -i "$FILE" > "$OUT" || true
elif python3 -c "import transformers" >/dev/null 2>&1; then
  python3 - <<PY > "$OUT"
from transformers import pipeline
with open("$FILE","r",encoding="utf-8") as f:
    code=f.read()
print("AI návrh: zkontroluj a navrhni refaktor. (Ukázka)")
PY
else
  echo "Žádný AI engine dostupný. Nastav OLLAMA nebo OPENAI CLI nebo nainstaluj transformers." >&2
  exit 1
fi

echo "AI návrh uložen do $OUT"
echo "Pro aplikaci návrhu zkontroluj obsah a použij git apply pokud je to patch."
