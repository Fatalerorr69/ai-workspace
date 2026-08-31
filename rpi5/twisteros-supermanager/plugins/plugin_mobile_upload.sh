#!/bin/bash
echo "📲 Aktivace upload serveru pro ROM/APK..."

sudo apt install -y python3-flask

FLASK_APP=upload.py flask run --host=0.0.0.0 --port=7070
