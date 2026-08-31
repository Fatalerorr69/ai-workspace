#!/bin/bash

log_info "Instaluji K3s (Kubernetes cluster)"

curl -sfL https://get.k3s.io | sh -

systemctl enable k3s
systemctl start k3s

mkdir -p /srv/k3s

log_ok "K3s cluster připraven"
