Write-Host "=== Starko AI Suite 2.1 ===" -ForegroundColor Cyan

Write-Host "[1] Spustit WPF GUI"
Write-Host "[2] Spustit Web Dashboard"
Write-Host "[3] Spustit oba"
Write-Host "[4] Otevřít složku pluginů"

$choice = Read-Host "Zvol možnost"

switch ($choice) {
    '1' { Start-Process "gui\StarkoAI\bin\Debug\net8.0-windows\StarkoAI.exe" }
    '2' { python.exe dashboard\main.py }
    '3' { 
        Start-Process "gui\StarkoAI\bin\Debug\net8.0-windows\StarkoAI.exe"
        python.exe dashboard\main.py
    }
    '4' { ii plugins }
    default { Write-Host "Neplatná volba" -ForegroundColor Red }
}
