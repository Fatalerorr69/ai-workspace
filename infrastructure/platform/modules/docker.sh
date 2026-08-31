#!/bin/bash

log_info "Instaluji Docker"

curl -fsSL https://get.docker.com | sh
apt install -y docker-compose-plugin

usermod -aG docker "$USER_CFG"

systemctl enable docker
systemctl start docker

mkdir -p /srv/containers

log_ok "Docker nainstalován"
