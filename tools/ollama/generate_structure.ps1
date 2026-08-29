# Vytvoření hlavní struktury projektu
$folders = @(
    "venv",
    "dashboard\templates",
    "dashboard\static",
    "plugins",
    "memory",
    "models",
    "datasets",
    "logs",
    "backups",
    "scripts"
)

foreach ($f in $folders) {
    if (-not (Test-Path $f)) {
        New-Item -ItemType Directory -Path $f | Out-Null
        Write-Host "[OK] Vytvořena složka: $f" -ForegroundColor Green
    } else {
        Write-Host "[INFO] Složka již existuje: $f" -ForegroundColor Yellow
    }
}
