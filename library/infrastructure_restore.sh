#!/bin/bash

read -p "Zadej cestu k ZIP archivu: " ARCHIVE

unzip "$ARCHIVE" -d /

systemctl daemon-reload
systemctl restart docker
systemctl restart ssh
systemctl restart ufw

echo "Obnova dokončena."
