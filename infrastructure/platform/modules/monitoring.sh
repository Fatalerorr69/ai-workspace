#!/bin/bash

log_info "Instaluji monitoring stack (Prometheus + Node Exporter + Grafana)"

apt install -y prometheus node-exporter grafana

systemctl enable prometheus
systemctl enable node-exporter
systemctl enable grafana-server

systemctl start prometheus
systemctl start node-exporter
systemctl start grafana-server

mkdir -p /srv/monitoring

log_ok "Monitoring nainstalován (Grafana na portu 3000)"
