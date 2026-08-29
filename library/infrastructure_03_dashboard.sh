#!/bin/bash

setup_nginx() {
    info "Instalace a konfigurace Nginx..."
    apt-get install -y -qq nginx >/dev/null
    
    cat > /etc/nginx/sites-available/gamehub <<EOF
server {
    listen 80;
    server_name _;
    root /var/www/gamehub;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location /api {
        proxy_pass http://localhost:$PORT_API;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
    }
}
EOF
    
    ln -sf /etc/nginx/sites-available/gamehub /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    systemctl reload nginx
}

deploy_frontend() {
    info "Nasazování webového rozhraní..."
    mkdir -p /var/www/gamehub
    
    # Zde použijeme obsah souboru web_dashboard.html, který jsi nahrál
    # Pro zjednodušení zde vytvořím placeholder, který by se měl nahradit skutečným HTML
    
    cat > /var/www/gamehub/index.html <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>GameHub Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>body{background:#1a1a2e;color:white;padding:2rem}</style>
</head>
<body>
    <div class="container">
        <h1>🎮 GameHub Dashboard</h1>
        <div class="card bg-dark border-secondary mt-4">
            <div class="card-body">
                <h5>Status Systému</h5>
                <p>API: <span id="apiStatus" class="badge bg-warning">Checking...</span></p>
                <div class="progress mb-3">
                    <div id="cpuBar" class="progress-bar bg-success" style="width: 0%">CPU</div>
                </div>
            </div>
        </div>
    </div>
    <script>
        fetch('/api/health')
            .then(r => r.json())
            .then(d => document.getElementById('apiStatus').className = 'badge bg-success')
            .catch(e => document.getElementById('apiStatus').className = 'badge bg-danger');
            
        setInterval(() => {
            fetch('/api/stats').then(r => r.json()).then(data => {
                document.getElementById('cpuBar').style.width = data.cpu + '%';
                document.getElementById('cpuBar').innerText = 'CPU: ' + Math.round(data.cpu) + '%';
            });
        }, 2000);
    </script>
</body>
</html>
HTML
    
    chown -R www-data:www-data /var/www/gamehub
}
