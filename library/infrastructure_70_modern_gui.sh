#!/bin/bash

update_dashboard_to_v3() {
    info "Nasazování GameHub OS Dashboardu..."
    
    # Záloha starého indexu
    mv /var/www/gamehub/index.html /var/www/gamehub/index.old.html 2>/dev/null

    # Vytvoření nového vizuálně atraktivního rozhraní
    cat > /var/www/gamehub/index.html <<'EOF'
<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <title>GameHub OS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <style>
        :root { --accent: #7000ff; --bg: #0a0a0c; }
        body { background-color: var(--bg); color: white; font-family: 'Segoe UI', sans-serif; }
        .game-card { 
            background: #151518; border: 1px solid #222; border-radius: 15px; 
            transition: transform 0.3s, border-color 0.3s; cursor: pointer; overflow: hidden;
        }
        .game-card:hover { transform: scale(1.05); border-color: var(--accent); box-shadow: 0 0 20px rgba(112,0,255,0.4); }
        .sidebar { background: rgba(0,0,0,0.5); backdrop-filter: blur(10px); height: 100vh; border-right: 1px solid #222; }
        .nav-link { color: #888; margin: 10px 0; border-radius: 10px; }
        .nav-link.active { background: var(--accent); color: white; }
        .status-dot { height: 10px; width: 10px; border-radius: 50%; display: inline-block; background: #00ff00; }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <nav class="col-md-2 d-none d-md-block sidebar p-4">
                <h2 class="mb-5 text-center">GameHub</h2>
                <ul class="nav flex-column">
                    <li class="nav-item"><a class="nav-link active" href="#"><i class="bi bi-controller me-2"></i> Moje Hry</a></li>
                    <li class="nav-item"><a class="nav-link" href="#" onclick="openStore()"><i class="bi bi-shop me-2"></i> Obchod / Stahování</a></li>
                    <li class="nav-item"><a class="nav-link" href="/proxy-manager"><i class="bi bi-globe me-2"></i> Web Proxy</a></li>
                    <li class="nav-item"><a class="nav-link" href="https://{{ip}}:9443"><i class="bi bi-box-seam me-2"></i> Docker</a></li>
                </ul>
            </nav>

            <main class="col-md-10 ms-sm-auto p-5">
                <div class="d-flex justify-content-between align-items-center mb-5">
                    <h1>Knihovna her</h1>
                    <div id="sys-stats">
                        <span class="badge bg-dark border border-secondary p-2">CPU: <span id="cpu-load">0%</span></span>
                        <span class="badge bg-dark border border-secondary p-2 ms-2">GPU: <span id="gpu-temp">45°C</span></span>
                    </div>
                </div>

                <div class="row" id="game-grid">
                    </div>
            </main>
        </div>
    </div>
</body>
</html>
EOF
}
