# ===========================================
# Starko AI Suite 2.1.1 – GitHub Builder (Opravené)
# ===========================================

# Funkce: Automatická oprava překlepů a UTF-8 znaků
function Auto-Fix {
    Write-Host "[FIX] Kontrola a oprava známých problémů..." -ForegroundColor Cyan
    Get-ChildItem -Path "." -Filter "*.ps1" | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        $content = $content -replace '-ForegroundColo', '-ForegroundColor'
        $content = $content -replace '[\u2013\u2014]', '-'
        Set-Content -Path $_.FullName -Value $content -Encoding UTF8
        Write-Host "[FIX] Upraven soubor: $($_.Name)" -ForegroundColor Green
    }
}

# Spustit opravu před čímkoli
Auto-Fix

# Funkce: Build ZIP balíku
function Build-ZIP {
    Write-Host "[BUILD] Generuji ZIP balík..." -ForegroundColor Green
    $source = "."
    $zipFile = "$source\Starko_AI_Suite_2.1.1.zip"
    if (Test-Path $zipFile) { Remove-Item $zipFile }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($source, $zipFile)
    Write-Host "ZIP balík vytvořen: $zipFile" -ForegroundColor Green
}

# Funkce: Upload na GitHub Release (simulace)
function Upload-GitHubRelease {
    Write-Host "[GITHUB] Upload na GitHub Release..." -ForegroundColor Green
}

# Funkce: Správa pluginů
function Manage-Plugins {
    Write-Host "[PLUGIN MANAGER] Správa pluginů..." -ForegroundColor Cyan
}

# Funkce: Aktualizace dashboardu
function Update-Dashboard {
    Write-Host "[DASHBOARD] Aktualizuji dashboard..." -ForegroundColor Green
}

# Funkce: Správa paměti (ChromaDB)
function Manage-Memory {
    Write-Host "[MEMORY] Správa paměti (ChromaDB)..." -ForegroundColor Green
}

# Hlavní menu
while ($true) {
    Write-Host ""
    Write-Host "=== Starko AI Suite 2.1.1 – GitHub Builder ===" -ForegroundColor Yellow
    Write-Host "1) Build ZIP baliku"
    Write-Host "2) Upload ZIP na GitHub"
    Write-Host "3) Sprava pluginu"
    Write-Host "4) Aktualizace dashboardu"
    Write-Host "5) Sprava pameti"
    Write-Host "6) Ukoncit"
    Write-Host ""

    $choice = Read-Host "Vyber akci (1-6)"

    switch ($choice) {
        "1" { Build-ZIP }
        "2" { Upload-GitHubRelease }
        "3" { Manage-Plugins }
        "4" { Update-Dashboard }
        "5" { Manage-Memory }
        "6" { break }
        default { Write-Host "Neplatna volba" -ForegroundColor Red }
    }
}

Write-Host "=== Konec ===" -ForegroundColor Yellow