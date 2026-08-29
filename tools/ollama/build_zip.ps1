Add-Type -AssemblyName System.IO.Compression.FileSystem
$baseDir = (Get-Location).Path
$zipName = "Starko_AI_Suite_2.0_Full_$(Get-Date -Format 'yyyyMMdd_HHmmss').zip"
$zipPath = Join-Path $baseDir $zipName

if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

[System.IO.Compression.ZipFile]::CreateFromDirectory($baseDir, $zipPath, 'Optimal', $true)
Write-Host "[OK] ZIP balík vytvořen: $zipPath" -ForegroundColor Green
