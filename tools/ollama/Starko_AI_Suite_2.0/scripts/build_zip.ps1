$baseDir = (Get-Location).Path
$zipName = "Starko_AI_Suite_2.0.zip"
$zipPath = Join-Path $baseDir $zipName

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($baseDir, $zipPath, 'Optimal', $true)
Write-Host "[OK] ZIP balík vytvořen: $zipPath"
