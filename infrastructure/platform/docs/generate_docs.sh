#!/bin/bash

OUTPUT="/srv/backups/docs/html"
mkdir -p "$OUTPUT"

for file in /opt/platform/docs/*.md; do
  pandoc "$file" -o "$OUTPUT/$(basename $file .md).html"
done

echo "HTML dokumentace vygenerována."
