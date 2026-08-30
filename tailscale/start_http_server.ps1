# Spustí HTTP server ve složce ai-workspace
$workspacePath = Join-Path $env:TEMP "migrate_v2\monorepo\ai-workspace"
if (-not (Test-Path $workspacePath)) {
    Write-Warning "Složka ai-workspace neexistuje: $workspacePath"
    exit 1
}
Write-Host "Spouštím HTTP server na portu 8000..." -ForegroundColor Cyan
$ip = tailscale ip -4
Write-Host "Přístup z Androidu: http://$ip`:8000" -ForegroundColor Green
Set-Location $workspacePath
python -m http.server 8000 --bind 0.0.0.0
