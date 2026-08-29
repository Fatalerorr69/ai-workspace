# setup_workspace.ps1
param(
    [switch]$InstallDependencies
)

Write-Host "Nastavuji pracovní prostředí..." -ForegroundColor Cyan

# Zde přidejte instalaci závislostí
if ($InstallDependencies) {
    Write-Host "Instaluji závislosti..." -ForegroundColor Yellow
    # npm install, pip install -r requirements.txt, atd.
}

Write-Host "Hotovo." -ForegroundColor Green
