#!/bin/bash

# cesta k repozitáři
REPO_DIR="/home/starko/rpi5-github-catalog"
cd "$REPO_DIR" || exit 1

# aktivace virtualenv
source "$REPO_DIR/venv/bin/activate"

# spust crawler
python crawler.py

# git konfigurace (pokud ještě není)
git config user.name "Fatalerorr69"
git config user.email "jakubkrajca@volny.cz"

# commit změn
git add .
git commit -m "Auto update catalog" 2>/dev/null || echo "Nothing to commit"

# push přes token
if [ -z "$GITHUB_TOKEN" ]; then
    echo "GITHUB_TOKEN není nastaven!"
    exit 1
fi

# upravené URL remote s tokenem
REMOTE_URL="https://$GITHUB_TOKEN@github.com/Fatalerorr69/rpi5-github-catalog.git"

git push "$REMOTE_URL" main

