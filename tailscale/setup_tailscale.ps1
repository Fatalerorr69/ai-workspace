# Hlavní skript pro nastavení Tailscale přístupu
Write-Host "=== Tailscale Workspace Setup ===" -ForegroundColor Magenta
& "$PSScriptRoot\check_tailscale.ps1"
Write-Host "`nPro spuštění HTTP serveru použijte: .\start_http_server.ps1" -ForegroundColor Yellow
