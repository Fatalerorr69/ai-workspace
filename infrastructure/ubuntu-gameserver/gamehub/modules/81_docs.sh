#!/bin/bash

generate_web_docs() {
    info "Vytvářím webovou dokumentaci..."
    mkdir -p /var/www/gamehub/docs
    
    cat > /var/www/gamehub/docs/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>GameHub - Dokumentace</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>body { background: #f8f9fa; padding: 50px; } .card { margin-bottom: 20px; }</style>
</head>
<body>
    <div class="container">
        <h1>📚 Dokumentace GameHub Ultimate</h1>
        <p class="lead">Kompletní přehled tvého serveru.</p>
        
        <div class="card">
            <div class="card-header">🚀 Rychlé přístupy</div>
            <div class="card-body">
                <ul>
                    <li><strong>Sunshine:</strong> https://$(hostname -I | awk '{print $1}'):47990</li>
                    <li><strong>Pterodactyl:</strong> http://$(hostname -I | awk '{print $1}'):80 (pokud je doména)</li>
                    <li><strong>Nginx Proxy Manager:</strong> http://$(hostname -I | awk '{print $1}'):81</li>
                </ul>
            </div>
        </div>

        <div class="card">
            <div class="card-header">🛠️ Správa přes Terminál</div>
            <div class="card-body">
                <pre>sudo ./gamehub.sh</pre>
                <p>Hlavní rozcestník pro veškerou údržbu a instalaci her.</p>
            </div>
        </div>
    </div>
</body>
</html>
EOF
}

create_admin_manual() {
    info "Vytvářím Admin Manual (Markdown)..."
    cat > "$INSTALL_DIR/ADMIN_MANUAL.md" <<EOF
# Admin Manual - GameHub
## Údržba
- Pravidelně spouštějte \`sudo ./gamehub.sh\` a volte možnost 5 (Update).
- Zálohy jsou uloženy v \`$BACKUP_DIR\`.

## Přidávání her
- ROMs vkládejte do \`$INSTALL_DIR/emulation/roms/[konzole]\`.
- Po přidání restartujte Sunshine službu.
EOF
}
