#!/bin/bash

setup_web_terminal() {
    info "Instalace TTYD (Web Terminal)..."
    # Instalace ttyd přes docker pro snadnou izolaci
    docker run -d --name web-terminal \
      --restart always \
      -p 7681:7681 \
      tsl0922/ttyd:latest ttyd -p 7681 -c admin:heslo123 bash
      
    info "Webový terminál běží na portu 7681 (uživatel: admin)"
    ufw allow 7681/tcp >/dev/null
}
