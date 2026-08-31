#!/bin/bash

install_nodejs() {
    if ! command -v node &> /dev/null; then
        info "Instalace Node.js 20..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash - >/dev/null
        apt-get install -y -qq nodejs >/dev/null
    fi
    npm install -g pm2 >/dev/null
}

setup_core_api() {
    info "Vytváření API serveru..."
    mkdir -p "$INSTALL_DIR/api"
    
    # Package.json
    cat > "$INSTALL_DIR/api/package.json" <<EOF
{
  "name": "gamehub-api",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "mysql2": "^3.6.0",
    "socket.io": "^4.7.2",
    "systeminformation": "^5.21.0"
  }
}
EOF

    # Simple Server.js
    cat > "$INSTALL_DIR/api/server.js" <<'EOF'
const express = require('express');
const cors = require('cors');
const si = require('systeminformation');
const app = express();
const http = require('http').createServer(app);
const io = require('socket.io')(http, { cors: { origin: "*" } });

app.use(cors());
app.use(express.json());

app.get('/api/health', (req, res) => res.json({ status: 'ok', uptime: process.uptime() }));

app.get('/api/stats', async (req, res) => {
    const cpu = await si.currentLoad();
    const mem = await si.mem();
    res.json({
        cpu: cpu.currentLoad,
        mem: (mem.used / mem.total) * 100,
        memUsed: mem.used,
        memTotal: mem.total
    });
});

io.on('connection', (socket) => {
    console.log('Client connected');
});

const PORT = process.env.PORT || 3001;
http.listen(PORT, () => console.log(`GameHub API running on ${PORT}`));
EOF

    # Instalace závislostí
    cd "$INSTALL_DIR/api"
    # Použijeme sudo -u pro instalaci jako gamehub uživatel
    sudo -u "$GH_USER" npm install >/dev/null 2>&1
}

setup_systemd() {
    info "Konfigurace Systemd služby..."
    cat > /etc/systemd/system/gamehub-api.service <<EOF
[Unit]
Description=GameHub API Server
After=network.target mariadb.service redis.service

[Service]
User=$GH_USER
WorkingDirectory=$INSTALL_DIR/api
ExecStart=/usr/bin/node server.js
Restart=always
EnvironmentFile=$CONFIG_DIR/db.env
Environment=PORT=$PORT_API

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable gamehub-api
    systemctl start gamehub-api
}
