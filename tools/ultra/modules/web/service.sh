#!/bin/bash
cd "$(dirname "$0")/backend" || exit 1
source ../venv/bin/activate
python3 app.py
