<#
.SYNOPSIS
    GemManager Pro Orchestrator - Kompletní správa GEM robotů s orchestrační funkcí.
.DESCRIPTION
    Obsahuje všechny funkce předchozích verzí + Orchestrátor pro správu a oživení armády robotů.
    Automaticky si nastaví Execution Policy pro aktuální proces.
.NOTES
    Vyžaduje PowerShell 7+. První spuštění vytvoří konfigurační soubory.
#>

# ----- NASTAVENÍ EXECUTION POLICY PRO AKTUÁLNÍ PROCES -----
if ($PSVersionTable.PSVersion.Major -ge 7) {
    $currentPolicy = Get-ExecutionPolicy -Scope Process -ErrorAction SilentlyContinue
    if ($currentPolicy -ne 'Bypass') {
        Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force -ErrorAction SilentlyContinue
    }
}

# ----- KONTROLA VERZE POWERSHELLU -----
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "Chyba: Vyžaduje PowerShell 7+. Vaše verze: $($PSVersionTable.PSVersion)" -ForegroundColor Red
    exit 1
}

# ----- GLOBÁLNÍ PROMĚNNÉ -----
$script:configFile = Join-Path $PSScriptRoot "GemManager_config.json"
$script:rootPath = $PSScriptRoot
$script:logFile = Join-Path $PSScriptRoot "gem_manager.log"
$script:excludedFolders = @("_knowledge_base", "_backup", "_redundant", "_global_config", "_exports", "_audits", "VSTUPNÍ GEM (ORCHESTRÁTOR)")
$script:globalConfig = $null
$script:relevanceThreshold = 0.3
$script:stopWords = @()
$script:lowRelevanceExtensions = @()

# ----- LOGOVÁNÍ -----
function Write-Log {
    param([string]$Message, [string]$Color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage -ForegroundColor $Color
    Add-Content -Path $script:logFile -Value $logMessage -Encoding UTF8 -ErrorAction SilentlyContinue
}

# ----- KONTROLA ADMINISTRÁTORA -----
function Test-Administrator {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ----- KONFIGURACE -----
function Initialize-GlobalConfig {
    param([string]$RootPath)
    $globalConfigPath = Join-Path $RootPath "_global_config.json"
    if (-not (Test-Path $globalConfigPath)) {
        Write-Log "Vytvářím výchozí globální konfiguraci..." -Color "Yellow"
        $defaultConfig = @{
            relevanceThreshold = 0.3
            stopWords = @("a","an","and","the","of","to","in","for","on","with","by","is","at","are","that","this","these","those","be","as","from","or","but","not","so","such","was","were","has","have","had","do","does","did","will","would","could","should","may","might","must","pro")
            lowRelevanceExtensions = @(".jpg",".jpeg",".png",".gif",".bmp",".tiff",".ico",".mp4",".avi",".mov",".mkv",".mp3",".wav",".flac",".exe",".msi",".dll",".so",".dmg",".iso",".zip",".rar",".7z",".tar",".gz",".bz2",".xz",".cab",".deb",".rpm")
            keywordBoost = @{ fileName = 0.4; content = 0.3; extension = 0.2 }
            gitEnabled = $false
            gitRemoteUrl = ""
            parallelJobs = 3
            backupRetentionDays = 30
        }
        $defaultConfig | ConvertTo-Json -Depth 3 | Set-Content $globalConfigPath -Encoding UTF8
    }
    return $globalConfigPath
}

function Load-Config {
    if (Test-Path $script:configFile) {
        $config = Get-Content $script:configFile -Raw | ConvertFrom-Json
        $script:rootPath = $config.rootPath
        Write-Log "Načtena konfigurace: rootPath = $script:rootPath" -Color "Gray"
    } else {
        $script:rootPath = $PSScriptRoot
        Save-Config
    }
    $globalCfg = Initialize-GlobalConfig -RootPath $script:rootPath
    $script:globalConfig = Get-Content $globalCfg -Raw | ConvertFrom-Json
    $script:relevanceThreshold = $script:globalConfig.relevanceThreshold
    $script:stopWords = $script:globalConfig.stopWords
    $script:lowRelevanceExtensions = $script:globalConfig.lowRelevanceExtensions
}

function Save-Config {
    $config = @{ rootPath = $script:rootPath }
    $config | ConvertTo-Json | Set-Content $script:configFile -Encoding UTF8
    Write-Log "Konfigurace uložena." -Color "Gray"
}

function Set-RootPath {
    Write-Host "`nAktuální kořenová cesta: $script:rootPath" -ForegroundColor Cyan
    $newPath = Read-Host "Zadejte novou cestu (nebo Enter pro ponechání)"
    if ($newPath) {
        $newPath = $newPath.Trim().Trim('"')
        if (Test-Path $newPath) {
            $script:rootPath = $newPath
            Save-Config
            Load-Config
            Write-Log "Kořenová cesta změněna na $script:rootPath" -Color "Green"
        } else { Write-Log "Cesta neexistuje!" -Color "Red" }
    }
}

function Get-GemFolders {
    if (-not (Test-Path $script:rootPath)) { return @() }
    Get-ChildItem -Path $script:rootPath -Directory | Where-Object {
        $_.Name -notin $script:excludedFolders -and $_.Name -notlike "_*"
    }
}

function Select-GemFolder {
    $folders = Get-GemFolders
    if ($folders.Count -eq 0) { Write-Log "Žádné GEM složky." -Color "Red"; return $null }
    Write-Host "`nDostupné GEM složky:" -ForegroundColor Cyan
    for ($i=0; $i -lt $folders.Count; $i++) { Write-Host "[$($i+1)] $($folders[$i].Name)" }
    $choice = Read-Host "Vyberte číslo (0 pro zrušení)"
    if ($choice -match "^\d+$" -and [int]$choice -ge 1 -and [int]$choice -le $folders.Count) {
        return $folders[[int]$choice-1].FullName
    }
    return $null
}

function Show-Overview {
    $folders = Get-GemFolders
    Write-Host "`n=== PŘEHLED GEM SLOŽEK ===" -ForegroundColor Magenta
    foreach ($folder in $folders) {
        $files = Get-ChildItem -Path $folder.FullName -Recurse -File -ErrorAction SilentlyContinue
        $count = $files.Count
        $size = "{0:N2} MB" -f (($files | Measure-Object -Property Length -Sum).Sum / 1MB)
        Write-Host "$($folder.Name) : $count souborů, $size" -ForegroundColor Cyan
    }
}

# ----- ZÁVISLOSTI (qpdf, git) -----
function Ensure-Dependency {
    param(
        [string]$CommandName,
        [string]$DisplayName,
        [string]$WingetId,
        [string]$ChocoId,
        [string]$DownloadUrl,
        [scriptblock]$TestCommand = { & $CommandName --version 2>$null }
    )
    $existing = Get-Command $CommandName -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Log "$DisplayName je nainstalován: $($existing.Source)" -Color "Green"
        return $true
    }
    Write-Log "$DisplayName není nainstalován. Pokus o instalaci..." -Color "Yellow"
    
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install $WingetId --silent --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0 -and (& $TestCommand)) {
            Write-Log "$DisplayName nainstalován pomocí winget." -Color "Green"
            return $true
        }
    }
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install $ChocoId -y
        if ($LASTEXITCODE -eq 0 -and (& $TestCommand)) {
            Write-Log "$DisplayName nainstalován pomocí chocolatey." -Color "Green"
            return $true
        }
    }
    if ($DownloadUrl) {
        Write-Log "Zkouším přímý download..." -Color "Cyan"
        $tempDir = Join-Path $env:TEMP "GemManagerInstall"
        if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir -Force | Out-Null }
        $downloadedFile = Join-Path $tempDir "$CommandName.zip"
        try {
            Invoke-WebRequest -Uri $DownloadUrl -OutFile $downloadedFile -UseBasicParsing
            Expand-Archive -Path $downloadedFile -DestinationPath $tempDir -Force
            $exe = Get-ChildItem -Path $tempDir -Recurse -Filter "$CommandName.exe" | Select-Object -First 1
            if ($exe) {
                $targetDir = "$env:ProgramFiles\$DisplayName"
                if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
                Copy-Item $exe.FullName -Destination "$targetDir\$CommandName.exe" -Force
                $env:Path = "$targetDir;$env:Path"
                if (& $TestCommand) {
                    Write-Log "$DisplayName nainstalován ručně." -Color "Green"
                    return $true
                }
            }
        } catch {
            Write-Log "Stahování selhalo: $_" -Color "Red"
        } finally {
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    Write-Log "Nepodařilo se nainstalovat $DisplayName. Nainstalujte ručně." -Color "Red"
    return $false
}

function Test-Qpdf {
    Ensure-Dependency -CommandName "qpdf" -DisplayName "qpdf" -WingetId "qpdf" -ChocoId "qpdf" -DownloadUrl "https://github.com/qpdf/qpdf/releases/download/v11.9.0/qpdf-11.9.0-bin-mingw64.zip" -TestCommand { & qpdf --version }
}

function Test-Git {
    Ensure-Dependency -CommandName "git" -DisplayName "Git" -WingetId "Git.Git" -ChocoId "git" -DownloadUrl "" -TestCommand { & git --version }
}

# ----- ZÁLOHOVÁNÍ A GIT -----
function Backup-GemFolder {
    param([string]$FolderPath)
    $backupDir = Join-Path $script:rootPath "_backups"
    if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir -Force | Out-Null }
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupName = "$(Split-Path $FolderPath -Leaf)_$timestamp.zip"
    $backupPath = Join-Path $backupDir $backupName
    Write-Log "Zálohuji $FolderPath -> $backupPath" -Color "Cyan"
    Compress-Archive -Path $FolderPath -DestinationPath $backupPath -Force
    Write-Log "Záloha vytvořena." -Color "Green"
    $retention = $script:globalConfig.backupRetentionDays
    Get-ChildItem $backupDir -Filter "*.zip" | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$retention) } | Remove-Item -Force
}

function Initialize-GitRepo {
    param([string]$KBPath)
    if (-not $script:globalConfig.gitEnabled) { return }
    if (-not (Test-Git)) { return }
    if (-not (Test-Path (Join-Path $KBPath ".git"))) {
        Push-Location $KBPath
        git init | Out-Null
        git add . | Out-Null
        git commit -m "Initial knowledge base" | Out-Null
        if ($script:globalConfig.gitRemoteUrl) { git remote add origin $script:globalConfig.gitRemoteUrl }
        Pop-Location
        Write-Log "Git repozitář inicializován v $KBPath" -Color "Green"
    }
}

function Commit-GitChanges {
    param([string]$KBPath)
    if (-not $script:globalConfig.gitEnabled) { return }
    if (Test-Path (Join-Path $KBPath ".git")) {
        Push-Location $KBPath
        git add . | Out-Null
        git commit -m "Auto-update $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-Null
        if ($script:globalConfig.gitRemoteUrl) { git push | Out-Null }
        Pop-Location
    }
}

# ----- GENEROVÁNÍ README -----
function Generate-Readme {
    param([string]$FolderPath)
    $readmePath = Join-Path $FolderPath "README.md"
    $robotName = Split-Path $FolderPath -Leaf
    $kbPath = Join-Path $FolderPath "_knowledge_base"
    $stats = @{}
    if (Test-Path $kbPath) {
        $stats['txtSize'] = "{0:N2} MB" -f ((Get-ChildItem -Path $kbPath -Recurse -Filter "*.txt" -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB)
        $stats['pdfCount'] = (Get-ChildItem -Path $kbPath -Recurse -Filter "*.pdf" -ErrorAction SilentlyContinue).Count
        $stats['lastUpdate'] = (Get-ChildItem -Path $kbPath -Recurse -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime.ToString("yyyy-MM-dd HH:mm")
    } else {
        $stats['txtSize'] = "0 MB"
        $stats['pdfCount'] = 0
        $stats['lastUpdate'] = "nikdy"
    }
    $content = @"
# GEM Robot: $robotName

## Popis
Tento robot je součástí systému GEM Knowledge Manager.

## Statistiky znalostní báze
- Velikost textových souborů: $($stats['txtSize'])
- Počet PDF dokumentů: $($stats['pdfCount'])
- Poslední aktualizace: $($stats['lastUpdate'])

## Automaticky generováno
GemManager Pro Orchestrator dne $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@
    Set-Content -Path $readmePath -Value $content -Encoding UTF8
    Write-Log "README.md vygenerován pro $robotName" -Color "Green"
}

# ----- VYLEPŠENÝ PROGRESS BAR -----
function Show-EnhancedProgress {
    param([string]$Activity, [string]$Status, [int]$PercentComplete, [string]$CurrentOperation = "")
    $barLength = 50
    $filled = [math]::Floor($barLength * $PercentComplete / 100)
    $empty = $barLength - $filled
    $bar = "[" + ("#" * $filled) + (" " * $empty) + "]"
    Write-Host "`r$Activity : $bar $PercentComplete% - $Status" -NoNewline
    if ($CurrentOperation) { Write-Host " ($CurrentOperation)" -NoNewline }
    if ($PercentComplete -eq 100) { Write-Host "" }
}

# ----- HLAVNÍ ZPRACOVÁNÍ (SMART UPDATE) -----
function Process-GemFolder {
    param([string]$SourceFolder, [string]$DestinationKB = $null)
    if (-not $DestinationKB) { $DestinationKB = Join-Path $SourceFolder "_knowledge_base" }
    Backup-GemFolder -FolderPath $SourceFolder
    
    $subFolders = @("Globalni_Konfigurace","TXT","PDF","YAML","Skripty","Logs")
    foreach ($sub in $subFolders) {
        $p = Join-Path $DestinationKB $sub
        if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
    }
    
    $extensions = @{
        ".txt"="TXT"; ".md"="TXT"; ".log"="TXT"; ".json"="TXT"; ".csv"="TXT";
        ".yaml"="YAML"; ".yml"="YAML"; ".pdf"="PDF";
        ".ps1"="Skripty"; ".sh"="Skripty"; ".bat"="Skripty"
    }
    $stats = @{ Added=0; Skipped=0; Copied=0; Errors=0 }
    Write-Log "Zpracovávám: $SourceFolder" -Color "Cyan"
    
    $allFiles = Get-ChildItem -Path $SourceFolder -Recurse -File | Where-Object {
        $_.FullName -notlike "$DestinationKB*" -and $_.FullName -notlike "$SourceFolder\_knowledge_base*"
    }
    $total = $allFiles.Count
    $index = 0
    
    $hashTxt=@{}; $hashYaml=@{}; $hashScript=@{}
    $txtOut = Join-Path $DestinationKB "TXT\kompletni_soubor_TXT.txt"
    $yamlOut = Join-Path $DestinationKB "YAML\kompletni_soubor_YAML.txt"
    $scriptOut = Join-Path $DestinationKB "Skripty\kompletni_soubor_Skripty.txt"
    
    if (Test-Path $txtOut) {
        $existing = Select-String -Path $txtOut -Pattern "^--- START SOUBORU: (.*?) ---" | ForEach-Object { $_.Matches.Groups[1].Value }
        foreach ($e in $existing) { $hashTxt[$e]=$true }
    }
    if (Test-Path $yamlOut) {
        $existing = Select-String -Path $yamlOut -Pattern "^--- START SOUBORU: (.*?) ---" | ForEach-Object { $_.Matches.Groups[1].Value }
        foreach ($e in $existing) { $hashYaml[$e]=$true }
    }
    if (Test-Path $scriptOut) {
        $existing = Select-String -Path $scriptOut -Pattern "^--- START SOUBORU: (.*?) ---" | ForEach-Object { $_.Matches.Groups[1].Value }
        foreach ($e in $existing) { $hashScript[$e]=$true }
    }
    
    foreach ($file in $allFiles) {
        $index++
        $percent = [math]::Round(($index/$total)*100)
        Show-EnhancedProgress -Activity "Zpracování $(Split-Path $SourceFolder -Leaf)" -Status "$percent%" -PercentComplete $percent -CurrentOperation $file.Name
        try {
            $ext = $file.Extension.ToLower()
            if ($extensions.ContainsKey($ext)) {
                $targetType = $extensions[$ext]
                $fileName = $file.Name
                if ($targetType -eq "PDF") {
                    $dest = Join-Path $DestinationKB "PDF\$fileName"
                    if (-not (Test-Path $dest)) {
                        Copy-Item $file.FullName -Destination $dest -Force -ErrorAction Stop
                        $stats.Copied++
                    } else { $stats.Skipped++ }
                } else {
                    $hashRef = switch ($targetType) {
                        "TXT" { $hashTxt; $outFile = $txtOut; break }
                        "YAML" { $hashYaml; $outFile = $yamlOut; break }
                        "Skripty" { $hashScript; $outFile = $scriptOut; break }
                    }
                    if ($hashRef.ContainsKey($fileName)) {
                        $stats.Skipped++
                    } else {
                        "`n--- START SOUBORU: $fileName ---`n" | Out-File $outFile -Append -Encoding UTF8
                        Get-Content $file.FullName | Out-File $outFile -Append -Encoding UTF8
                        "`n--- KONEC SOUBORU ---`n" | Out-File $outFile -Append -Encoding UTF8
                        $hashRef[$fileName]=$true
                        $stats.Added++
                    }
                }
            }
        } catch {
            $stats.Errors++
            Write-Log "Chyba u $($file.Name): $_" -Color "Red"
        }
    }
    Show-EnhancedProgress -Activity "Zpracování $(Split-Path $SourceFolder -Leaf)" -Status "Dokončeno" -PercentComplete 100
    Write-Log "REPORT: Přidáno $($stats.Added), PDF $($stats.Copied), Přeskočeno $($stats.Skipped), Chyby $($stats.Errors)" -Color "Magenta"
    
    Initialize-GitRepo -KBPath $DestinationKB
    Commit-GitChanges -KBPath $DestinationKB
    Generate-Readme -FolderPath $SourceFolder
}

function Process-AllGemFolders {
    $folders = Get-GemFolders
    if ($folders.Count -eq 0) { Write-Log "Žádné složky." -Color "Red"; return }
    foreach ($f in $folders) {
        Process-GemFolder -SourceFolder $f.FullName
    }
    Write-Log "Všechny složky zpracovány." -Color "Green"
}

function Merge-PdfInFolder {
    param([string]$FolderPath)
    if (-not (Test-Qpdf)) { Write-Log "qpdf chybí" -Color "Red"; return }
    $pdfs = Get-ChildItem -Path $FolderPath -Filter "*.pdf" -File
    if ($pdfs.Count -eq 0) { Write-Log "Žádná PDF." -Color "Yellow"; return }
    $output = Join-Path $FolderPath "kompletni_sloucene_PDF.pdf"
    Push-Location $FolderPath
    & qpdf --empty --pages *.pdf -- $output 2>$null
    Pop-Location
    Write-Log "PDF sloučeno do $output" -Color "Green"
}

function SmartAnalyze-And-Clean {
    param([string]$FolderPath)
    Write-Host "`n=== SMART ANALÝZA: $(Split-Path $FolderPath -Leaf) ===" -ForegroundColor Magenta
    $descFiles = Get-ChildItem -Path $FolderPath -Filter "*.txt" -File | Where-Object { $_.DirectoryName -eq $FolderPath }
    $robotName = Split-Path $FolderPath -Leaf
    $combined = $robotName
    foreach ($f in $descFiles) { $combined += " " + (Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue) }
    $words = $combined -split '\W+' | Where-Object { $_.Length -gt 3 -and $_.ToLower() -notin $script:stopWords } | ForEach-Object { $_.ToLower() }
    $keywords = $words | Group-Object | Sort-Object Count -Descending | Select-Object -First 30 | ForEach-Object { $_.Name }
    Write-Log "Klíčová slova: $($keywords -join ', ')" -Color "Gray"
    
    $allFiles = Get-ChildItem -Path $FolderPath -Recurse -File | Where-Object {
        $_.FullName -notlike "*_knowledge_base*" -and $_.FullName -notlike "*_redundant*"
    }
    $irrelevant = @()
    foreach ($file in $allFiles) {
        $score = 0.0
        $ext = $file.Extension.ToLower()
        if ($ext -in $script:lowRelevanceExtensions) { $score -= 0.5 }
        elseif ($ext -eq ".pdf") { $score += $script:globalConfig.keywordBoost.extension }
        elseif ($ext -in @(".txt",".md",".ps1",".sh",".yaml",".yml")) { $score += $script:globalConfig.keywordBoost.extension }
        $name = $file.Name.ToLower()
        foreach ($kw in $keywords) { if ($name -match $kw) { $score += $script:globalConfig.keywordBoost.fileName; break } }
        if ($ext -in @(".txt",".md",".ps1",".sh",".yaml",".yml",".json",".csv",".log")) {
            try {
                $sample = Get-Content $file.FullName -TotalCount 50 -Raw -ErrorAction Stop
                $sample = $sample.ToLower()
                foreach ($kw in $keywords) { if ($sample -match $kw) { $score += $script:globalConfig.keywordBoost.content; break } }
            } catch {}
        }
        if ($score -lt $script:relevanceThreshold) { $irrelevant += $file }
    }
    Write-Host "Nepatřících souborů: $($irrelevant.Count)" -ForegroundColor Yellow
    if ($irrelevant.Count -gt 0) {
        $irrelevant | ForEach-Object { Write-Host "   $($_.FullName)" -ForegroundColor Gray }
        $action = Read-Host "`n[1] Přesunout do _redundant  [2] Smazat  [3] Ignorovat"
        if ($action -eq "1") {
            $redir = Join-Path $FolderPath "_redundant"
            foreach ($f in $irrelevant) {
                $rel = $f.FullName.Substring($FolderPath.Length+1)
                $dest = Join-Path $redir $rel
                $d = Split-Path $dest -Parent
                if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
                Move-Item $f.FullName -Destination $dest -Force
            }
            Write-Log "Přesunuto $($irrelevant.Count) souborů." -Color "Green"
        } elseif ($action -eq "2") { $irrelevant | Remove-Item -Force; Write-Log "Smazáno." -Color "Red" }
    } else { Write-Host "Žádné nepatřící soubory." -ForegroundColor Green }
}

function Add-NewGemRobot {
    Write-Host "`n=== PŘIDÁNÍ NOVÉHO ROBOTA ===" -ForegroundColor Magenta
    $source = Read-Host "Cesta ke složce (může být mimo kořen)"
    $source = $source.Trim().Trim('"')
    if (-not (Test-Path $source)) { Write-Log "Cesta neexistuje!" -Color "Red"; return }
    $defaultName = Split-Path $source -Leaf
    $newName = Read-Host "Název robota (Enter pro '$defaultName')"
    if (-not $newName) { $newName = $defaultName }
    $target = Join-Path $script:rootPath $newName
    if (Test-Path $target) { Write-Log "Robot již existuje." -Color "Red"; return }
    $move = Read-Host "[1] Přesunout [2] Zkopírovat (1/2)"
    if ($move -eq "1") { Move-Item -Path $source -Destination $target -Force }
    else { Copy-Item -Path $source -Destination $target -Recurse -Force }
    Write-Log "Robot přidán do $target" -Color "Green"
    SmartAnalyze-And-Clean -FolderPath $target
    $createKB = Read-Host "Vytvořit knowledge base? (ano/ne)"
    if ($createKB -eq "ano") { Process-GemFolder -SourceFolder $target }
}

function Export-Package {
    param([string]$FolderPath)
    Write-Host "`n=== EXPORT BALÍČKU PRO $(Split-Path $FolderPath -Leaf) ===" -ForegroundColor Magenta
    $exportDir = Join-Path $script:rootPath "_exports"
    if (-not (Test-Path $exportDir)) { New-Item -ItemType Directory -Path $exportDir -Force | Out-Null }
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $robotName = Split-Path $FolderPath -Leaf
    $packageName = "${robotName}_package_$timestamp"
    $packageDir = Join-Path $exportDir $packageName
    New-Item -ItemType Directory -Path $packageDir -Force | Out-Null
    $kbSrc = Join-Path $FolderPath "_knowledge_base"
    if (Test-Path $kbSrc) { Copy-Item -Path $kbSrc -Destination (Join-Path $packageDir "knowledge_base") -Recurse -Force }
    $readmeSrc = Join-Path $FolderPath "README.md"
    if (Test-Path $readmeSrc) { Copy-Item $readmeSrc -Destination $packageDir -Force }
    $manifest = @{
        robotName = $robotName
        exportDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        sourcePath = $FolderPath
        fileCount = (Get-ChildItem -Path $FolderPath -Recurse -File).Count
        kbSizeMB = [math]::Round((Get-ChildItem -Path $kbSrc -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
        description = "Export pro LLM nebo vlastního AI asistenta."
    }
    $manifest | ConvertTo-Json -Depth 3 | Set-Content (Join-Path $packageDir "manifest.json") -Encoding UTF8
    $zipPath = Join-Path $exportDir "${packageName}.zip"
    Compress-Archive -Path "$packageDir\*" -DestinationPath $zipPath -Force
    Remove-Item $packageDir -Recurse -Force
    Write-Log "Balíček vytvořen: $zipPath" -Color "Green"
}

function Export-Report {
    $exportDir = Join-Path $script:rootPath "_exports"
    if (-not (Test-Path $exportDir)) { New-Item -ItemType Directory -Path $exportDir -Force | Out-Null }
    $folders = Get-GemFolders
    $data = @()
    foreach ($folder in $folders) {
        $files = Get-ChildItem -Path $folder.FullName -Recurse -File -ErrorAction SilentlyContinue
        $data += [PSCustomObject]@{
            Robot = $folder.Name
            PocetSouboru = $files.Count
            VelikostMB = [math]::Round(($files | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
            PosledniZmena = ($files | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime.ToString("yyyy-MM-dd")
        }
    }
    $csvPath = Join-Path $exportDir "gem_report.csv"
    $data | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
    $html = @"
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>GEM Report</title>
<style>body{font-family:Arial;}table{border-collapse:collapse;}th,td{border:1px solid #ddd;padding:8px;}th{background-color:#4CAF50;color:white;}</style>
</head><body><h1>Přehled GEM robotů</h1> table<thead><tr><th>Robot</th><th>Počet souborů</th><th>Velikost (MB)</th><th>Poslední změna</th></tr></thead><tbody>
$(
    foreach ($row in $data) {
        "<tr><td>$($row.Robot)</td><td>$($row.PocetSouboru)</td><td>$($row.VelikostMB)</td><td>$($row.PosledniZmena)</td></tr>"
    }
)
</tbody></table><p>Vygenerováno: $(Get-Date)</p></body></html>
"@
    $htmlPath = Join-Path $exportDir "gem_report.html"
    Set-Content -Path $htmlPath -Value $html -Encoding UTF8
    Write-Log "Reporty uloženy do $exportDir" -Color "Green"
    Start-Process $htmlPath
}

function Schedule-Task {
    if (-not (Test-Administrator)) {
        Write-Log "Pro vytvoření plánované úlohy potřebujete administrátorská práva." -Color "Red"
        return
    }
    $taskName = "GemManager_Pro_Update"
    $scriptPath = $MyInvocation.MyCommand.Path
    $action = New-ScheduledTaskAction -Execute "pwsh.exe" -Argument "-File `"$scriptPath`" -AutoUpdate"
    $trigger = New-ScheduledTaskTrigger -Daily -At 2:00AM
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force
    Write-Log "Plánovaná úloha '$taskName' vytvořena (denně v 2:00)." -Color "Green"
}

function AutoUpdate {
    Write-Log "Automatická aktualizace spuštěna..." -Color "Cyan"
    $folders = Get-GemFolders
    foreach ($f in $folders) {
        Process-GemFolder -SourceFolder $f.FullName
    }
    Write-Log "Automatická aktualizace dokončena." -Color "Green"
}

# ----- AUDIT A KLASIFIKACE (OPRAVENÉ) -----
function Deep-AuditFolder {
    param([string]$FolderPath, [string]$OutputFile = $null)
    if (-not $OutputFile) {
        $auditDir = Join-Path $script:rootPath "_audits"
        if (-not (Test-Path $auditDir)) { New-Item -ItemType Directory -Path $auditDir -Force | Out-Null }
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $folderName = (Split-Path $FolderPath -Leaf) -replace '[^\w\-]', '_'
        $OutputFile = Join-Path $auditDir "Audit_${folderName}_$timestamp.md"
    }
    Write-Log "Spouštím hloubkový audit složky: $FolderPath" -Color "Cyan"
    Write-Host "Tato operace může trvat několik minut (zejména při hledání duplicit a analýze textu)..." -ForegroundColor Yellow
    
    $allFiles = Get-ChildItem -Path $FolderPath -Recurse -File -ErrorAction SilentlyContinue
    $allFolders = Get-ChildItem -Path $FolderPath -Recurse -Directory -ErrorAction SilentlyContinue
    $totalSize = ($allFiles | Measure-Object -Property Length -Sum).Sum
    $fileCount = $allFiles.Count
    $folderCount = $allFolders.Count + 1
    
    $extStats = $allFiles | Group-Object Extension | Select-Object @{N='Přípona';E={if($_.Name){$_.Name}else{"(bez přípony)"}}}, Count, @{N='Velikost(MB)';E={[math]::Round(($_.Group | Measure-Object Length -Sum).Sum / 1MB, 2)}}
    $largestFiles = $allFiles | Sort-Object Length -Descending | Select-Object -First 20 | Select-Object Name, @{N='Velikost(MB)';E={[math]::Round($_.Length/1MB,2)}}, FullName, LastWriteTime
    $oldestFiles = $allFiles | Sort-Object LastWriteTime | Select-Object -First 20 | Select-Object Name, @{N='Velikost(MB)';E={[math]::Round($_.Length/1MB,2)}}, FullName, LastWriteTime
    $emptyFolders = $allFolders | Where-Object { (Get-ChildItem $_.FullName -Force -ErrorAction SilentlyContinue).Count -eq 0 }
    
    $junkPatterns = @("*.tmp","*.temp","*.bak","*.old","*.log","*.cache","*.pyc","Thumbs.db","desktop.ini",".DS_Store")
    $junkFiles = @()
    foreach ($pattern in $junkPatterns) {
        $junkFiles += Get-ChildItem -Path $FolderPath -Recurse -Filter $pattern -File -ErrorAction SilentlyContinue
    }
    $junkFiles = $junkFiles | Select-Object -Unique
    
    $executableExt = @('.exe','.msi','.ps1','.bat','.cmd','.vbs','.js','.jar','.sh','.py','.pl')
    $executableFiles = $allFiles | Where-Object { $executableExt -contains $_.Extension.ToLower() }
    
    Write-Host "Hledám duplicitní soubory (výpočet hashů)... může trvat i několik minut." -ForegroundColor Yellow
    $hashTable = @{}
    $duplicates = @()
    $fileIndex = 0
    foreach ($file in $allFiles) {
        $fileIndex++
        if ($fileIndex % 100 -eq 0) { Write-Host "Zpracováno $fileIndex z $fileCount souborů..." -ForegroundColor Gray }
        try {
            $hash = (Get-FileHash $file.FullName -Algorithm MD5 -ErrorAction Stop).Hash
            if ($hashTable.ContainsKey($hash)) {
                $duplicates += [PSCustomObject]@{ Hash = $hash; File1 = $hashTable[$hash]; File2 = $file.FullName }
            } else {
                $hashTable[$hash] = $file.FullName
            }
        } catch { }
    }
    
    $textExtensions = @('.txt','.md','.ps1','.json','.csv','.log','.yaml','.yml','.xml')
    $textFiles = $allFiles | Where-Object { $textExtensions -contains $_.Extension.ToLower() -and $_.Length -lt 5MB }
    $textStats = @()
    foreach ($tf in $textFiles) {
        try {
            $content = Get-Content $tf.FullName -Raw -ErrorAction Stop
            $lines = ($content -split "`n").Count
            $words = ($content -split '\s+' | Where-Object {$_}).Count
            $chars = $content.Length
            $textStats += [PSCustomObject]@{ Soubor = $tf.Name; Cesta = $tf.FullName; Radky = $lines; Slova = $words; Znaky = $chars }
        } catch { }
    }
    $totalLines = ($textStats | Measure-Object -Property Radky -Sum).Sum
    $totalWords = ($textStats | Measure-Object -Property Slova -Sum).Sum
    $totalChars = ($textStats | Measure-Object -Property Znaky -Sum).Sum
    
    $mdContent = @"
# Hloubkový audit složky: $(Split-Path $FolderPath -Leaf)

**Datum auditu:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Cesta:** `$FolderPath`  

---

## 1. Základní informace

| Metrika | Hodnota |
|---------|---------|
| Název složky | $(Split-Path $FolderPath -Leaf) |
| Celková velikost | $([math]::Round($totalSize/1MB,2)) MB ($([math]::Round($totalSize/1GB,2)) GB) |
| Počet souborů | $fileCount |
| Počet složek | $folderCount |
| Průměrná velikost souboru | $([math]::Round($totalSize/$fileCount,2)) B |
| Datum vytvoření | $((Get-Item $FolderPath).CreationTime) |
| Datum poslední změny | $((Get-Item $FolderPath).LastWriteTime) |

---

## 2. Typy souborů (přípony)

| Přípona | Počet | Velikost (MB) |
|---------|-------|----------------|
$($extStats | ForEach-Object { "| $($_.Přípona) | $($_.Count) | $($_.'Velikost(MB)') |" })

---

## 3. Největší soubory (top 20)

| Název | Velikost (MB) | Poslední změna | Cesta |
|-------|---------------|----------------|-------|
$($largestFiles | ForEach-Object { "| $($_.Name) | $($_.'Velikost(MB)') | $($_.LastWriteTime) | `$($_.FullName)` |" })

---

## 4. Nejstarší soubory (podle data změny, top 20)

| Název | Velikost (MB) | Poslední změna | Cesta |
|-------|---------------|----------------|-------|
$($oldestFiles | ForEach-Object { "| $($_.Name) | $($_.'Velikost(MB)') | $($_.LastWriteTime) | `$($_.FullName)` |" })

---

## 5. Prázdné složky

"@
    if ($emptyFolders.Count -gt 0) {
        foreach ($ef in $emptyFolders) { $mdContent += "- `$($ef.FullName)`n" }
    } else {
        $mdContent += "Žádné prázdné složky.`n"
    }
    
    $mdContent += @"

## 6. Nepotřebné soubory (podle vzorů: $($junkPatterns -join ', '))

| Název | Cesta |
|-------|-------|
$($junkFiles | ForEach-Object { "| $($_.Name) | `$($_.FullName)` |" })

---

## 7. Bezpečnostní rizika (spustitelné soubory)

| Název | Přípona | Velikost (MB) | Cesta |
|-------|---------|---------------|-------|
$($executableFiles | ForEach-Object { "| $($_.Name) | $($_.Extension) | $([math]::Round($_.Length/1MB,2)) | `$($_.FullName)` |" })

---

## 8. Duplicitní soubory (stejný obsah)

"@
    if ($duplicates.Count -gt 0) {
        $dupGroups = $duplicates | Group-Object Hash
        foreach ($group in $dupGroups) {
            $mdContent += "### Hash: $($group.Name)`n"
            foreach ($item in $group.Group) {
                $mdContent += "- `$($item.File1)`n- `$($item.File2)`n"
            }
        }
    } else {
        $mdContent += "Žádné duplicitní soubory nenalezeny.`n"
    }
    
    $mdContent += @"

## 9. Statistika textových souborů

| Metrika | Hodnota |
|---------|---------|
| Počet analyzovaných textových souborů | $($textStats.Count) |
| Celkový počet řádků | $totalLines |
| Celkový počet slov | $totalWords |
| Celkový počet znaků | $totalChars |
| Průměrná délka souboru (znaky) | $([math]::Round($totalChars/$textStats.Count,0)) |

---

## 10. Shrnutí a doporučení

- **Celkový stav:** $(if ($fileCount -eq 0) { "Složka je prázdná." } else { "Složka obsahuje $fileCount souborů o celkové velikosti $([math]::Round($totalSize/1MB,2)) MB." })
- **Duplicity:** $(if ($duplicates.Count -gt 0) { "Bylo nalezeno $($duplicates.Count) duplicitních párů. Doporučujeme odstranit duplicity pro úsporu místa." } else { "Žádné duplicity – dobré." })
- **Nepotřebné soubory:** $(if ($junkFiles.Count -gt 0) { "Bylo nalezeno $($junkFiles.Count) nepotřebných souborů. Doporučujeme je přesunout do koše nebo smazat." } else { "Žádné nepotřebné soubory – čisté." })
- **Bezpečnost:** $(if ($executableFiles.Count -gt 0) { "Upozornění: Ve složce je $($executableFiles.Count) spustitelných souborů. Zkontrolujte, zda jsou důvěryhodné." } else { "Žádné spustitelné soubory – bezpečné." })
- **Prázdné složky:** $(if ($emptyFolders.Count -gt 0) { "Bylo nalezeno $($emptyFolders.Count) prázdných složek. Doporučujeme je smazat pro lepší přehlednost." } else { "Žádné prázdné složky." })

---

*Tento audit byl vygenerován automaticky nástrojem GemManager Pro Orchestrator.*
"@
    $mdContent | Out-File -FilePath $OutputFile -Encoding UTF8
    Write-Log "Audit dokončen. Výstup uložen do: $OutputFile" -Color "Green"
    Write-Host "`nPro otevření souboru spusťte: notepad `"$OutputFile`" nebo code `"$OutputFile`"" -ForegroundColor Cyan
    $open = Read-Host "Chcete soubor nyní otevřít? (ano/ne)"
    if ($open -eq "ano") { Start-Process $OutputFile }
    return $OutputFile
}

function Deep-AnalyzeAndClassify {
    param([string]$FolderPath, [string]$OutputFile = $null)
    if (-not $OutputFile) {
        $auditDir = Join-Path $script:rootPath "_audits"
        if (-not (Test-Path $auditDir)) { New-Item -ItemType Directory -Path $auditDir -Force | Out-Null }
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $folderName = (Split-Path $FolderPath -Leaf) -replace '[^\w\-]', '_'
        $OutputFile = Join-Path $auditDir "Analyza_${folderName}_$timestamp.md"
    }
    
    Write-Log "Spouštím hloubkovou analýzu a klasifikaci složky: $FolderPath" -Color "Cyan"
    Write-Host "Tato operace analyzuje strukturu, obsah a navrhne doporučení. Může trvat několik minut." -ForegroundColor Yellow
    
    # ----- SBĚR DAT -----
    $allFiles = Get-ChildItem -Path $FolderPath -Recurse -File -ErrorAction SilentlyContinue
    $allFolders = Get-ChildItem -Path $FolderPath -Recurse -Directory -ErrorAction SilentlyContinue
    $totalSize = ($allFiles | Measure-Object -Property Length -Sum).Sum
    $fileCount = $allFiles.Count
    $folderCount = $allFolders.Count + 1
    
    $rootFiles = Get-ChildItem -Path $FolderPath -File -ErrorAction SilentlyContinue
    $rootDirs = Get-ChildItem -Path $FolderPath -Directory -ErrorAction SilentlyContinue
    $hasReadme = ($rootFiles.Name -match '(?i)^readme\.(md|txt|rst)$').Count -gt 0
    $hasLicense = ($rootFiles.Name -match '(?i)^license|^licence').Count -gt 0
    $hasGit = (Test-Path (Join-Path $FolderPath ".git")) -or ($rootDirs.Name -eq '.git')
    $hasDockerfile = ($rootFiles.Name -match '(?i)^dockerfile$').Count -gt 0
    $hasRequirements = ($rootFiles.Name -match '(?i)^requirements\.txt$').Count -gt 0
    $hasPackageJson = ($rootFiles.Name -eq 'package.json').Count -gt 0
    $hasComposerJson = ($rootFiles.Name -eq 'composer.json').Count -gt 0
    $hasCsProj = ($rootFiles.Name -match '\.csproj$').Count -gt 0
    $hasPomXml = ($rootFiles.Name -eq 'pom.xml').Count -gt 0
    $hasSetupPy = ($rootFiles.Name -eq 'setup.py').Count -gt 0
    $hasMakefile = ($rootFiles.Name -eq 'Makefile').Count -gt 0
    $hasDockerCompose = ($rootFiles.Name -match '(?i)^docker-compose\.ya?ml$').Count -gt 0
    $hasGitignore = ($rootFiles.Name -eq '.gitignore').Count -gt 0
    
    $extensions = $allFiles | Group-Object Extension | Select-Object Name, Count
    $langs = @()
    if ($extensions | Where-Object { $_.Name -eq '.py' }) { $langs += 'Python' }
    if ($extensions | Where-Object { $_.Name -eq '.js' -or $_.Name -eq '.ts' }) { $langs += 'JavaScript/TypeScript' }
    if ($extensions | Where-Object { $_.Name -eq '.cs' }) { $langs += 'C#' }
    if ($extensions | Where-Object { $_.Name -eq '.java' }) { $langs += 'Java' }
    if ($extensions | Where-Object { $_.Name -eq '.go' }) { $langs += 'Go' }
    if ($extensions | Where-Object { $_.Name -eq '.rs' }) { $langs += 'Rust' }
    if ($extensions | Where-Object { $_.Name -eq '.php' }) { $langs += 'PHP' }
    if ($extensions | Where-Object { $_.Name -eq '.rb' }) { $langs += 'Ruby' }
    if ($extensions | Where-Object { $_.Name -eq '.ps1' -or $_.Name -eq '.bat' -or $_.Name -eq '.sh' }) { $langs += 'Skriptovací (PS/Bash/Batch)' }
    
    $latestChange = ($allFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime
    $oldestChange = ($allFiles | Sort-Object LastWriteTime | Select-Object -First 1).LastWriteTime
    $daysSinceLastChange = if ($latestChange) { (Get-Date) - $latestChange | Select-Object -ExpandProperty Days } else { $null }
    $projectAgeDays = if ($oldestChange) { (Get-Date) - $oldestChange | Select-Object -ExpandProperty Days } else { $null }
    
    $gitCommits = $null
    if ($hasGit) {
        Push-Location $FolderPath
        $gitCommits = (git rev-list --count HEAD 2>$null) -as [int]
        Pop-Location
    }
    
    # SMART ANALÝZA (nepatřící soubory)
    Write-Host "Provádím smart analýzu pro detekci nepatřících souborů..." -ForegroundColor Yellow
    $descFiles = Get-ChildItem -Path $FolderPath -Filter "*.txt" -File | Where-Object { $_.DirectoryName -eq $FolderPath }
    $robotName = Split-Path $FolderPath -Leaf
    $combined = $robotName
    foreach ($f in $descFiles) { $combined += " " + (Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue) }
    $words = $combined -split '\W+' | Where-Object { $_.Length -gt 3 -and $_.ToLower() -notin $script:stopWords } | ForEach-Object { $_.ToLower() }
    $keywords = $words | Group-Object | Sort-Object Count -Descending | Select-Object -First 30 | ForEach-Object { $_.Name }
    
    $irrelevantFiles = @()
    foreach ($file in $allFiles) {
        $score = 0.0
        $ext = $file.Extension.ToLower()
        if ($ext -in $script:lowRelevanceExtensions) { $score -= 0.5 }
        elseif ($ext -eq ".pdf") { $score += $script:globalConfig.keywordBoost.extension }
        elseif ($ext -in @(".txt",".md",".ps1",".sh",".yaml",".yml")) { $score += $script:globalConfig.keywordBoost.extension }
        $name = $file.Name.ToLower()
        foreach ($kw in $keywords) { if ($name -match $kw) { $score += $script:globalConfig.keywordBoost.fileName; break } }
        if ($ext -in @(".txt",".md",".ps1",".sh",".yaml",".yml",".json",".csv",".log")) {
            try {
                $sample = Get-Content $file.FullName -TotalCount 50 -Raw -ErrorAction Stop
                $sample = $sample.ToLower()
                foreach ($kw in $keywords) { if ($sample -match $kw) { $score += $script:globalConfig.keywordBoost.content; break } }
            } catch {}
        }
        if ($score -lt $script:relevanceThreshold) { $irrelevantFiles += $file }
    }
    
    # KLASIFIKACE
    $projectType = "Neurčeno"
    $confidence = "Nízká"
    $framework = ""
    if ($hasPackageJson -and ($langs -contains 'JavaScript/TypeScript')) {
        $projectType = "Node.js / JavaScript projekt"
        $confidence = "Vysoká"
        $framework = if (Test-Path (Join-Path $FolderPath "node_modules")) { "závislosti nainstalovány" } else { "závislosti nejsou nainstalovány (spusťte 'npm install')" }
    } elseif ($hasRequirements -or $hasSetupPy) {
        $projectType = "Python projekt"
        $confidence = "Vysoká"
        $framework = if ($hasRequirements) { "requirements.txt nalezen" } else { "setup.py nalezen" }
    } elseif ($hasCsProj) {
        $projectType = ".NET / C# projekt"
        $confidence = "Vysoká"
    } elseif ($hasPomXml) {
        $projectType = "Java Maven projekt"
        $confidence = "Vysoká"
    } elseif ($hasComposerJson) {
        $projectType = "PHP Composer projekt"
        $confidence = "Vysoká"
    } elseif ($hasMakefile) {
        $projectType = "C/C++ projekt (Makefile)"
        $confidence = "Střední"
    } elseif ($hasDockerfile -or $hasDockerCompose) {
        $projectType = "Docker kontejnerová aplikace"
        $confidence = "Střední"
    } elseif ($langs.Count -gt 0) {
        $projectType = "Projekt v jazycích: $($langs -join ', ')"
        $confidence = "Střední"
    } elseif ($allFiles.Count -gt 0 -and $allFiles.Count -lt 50 -and ($extensions | Where-Object { $_.Name -eq '.txt' -or $_.Name -eq '.md' })) {
        $projectType = "Dokumentační repozitář / Knowledge base"
        $confidence = "Vysoká"
    } elseif ($allFiles.Count -eq 0) {
        $projectType = "Prázdná složka"
        $confidence = "Vysoká"
    }
    
    # DOPORUČENÍ
    $recommendations = @()
    $missingFiles = @()
    $status = "OK"
    if (-not $hasReadme) {
        $missingFiles += "README.md (nebo .txt) – doporučeno pro dokumentaci projektu"
        $recommendations += "Vytvořte README.md s popisem projektu, instalačními kroky a příklady použití."
    }
    if (-not $hasLicense) {
        $missingFiles += "LICENSE – pokud chcete projekt sdílet, přidejte licenci (MIT, GPL, atd.)"
        $recommendations += "Zvažte přidání souboru LICENSE, aby bylo jasné, za jakých podmínek lze projekt používat."
    }
    if (-not $hasGitignore -and ($langs -contains 'Python' -or $langs -contains 'JavaScript/TypeScript' -or $langs -contains '.NET')) {
        $missingFiles += ".gitignore – zabraňuje nahrávání dočasných souborů a závislostí do repozitáře"
        $recommendations += "Přidejte .gitignore vhodný pro váš jazyk (např. z GitHubu)."
    }
    if (-not $hasGit) {
        $recommendations += "Inicializujte Git repozitář (git init) a začněte verzovat."
    } else {
        if ($gitCommits -eq 0 -or $gitCommits -lt 5) {
            $recommendations += "Git repozitář existuje, ale má velmi málo commitů. Doporučujeme pravidelně commitovat změny."
        }
        if ($daysSinceLastChange -gt 180) {
            $status = "Zastaralý"
            $recommendations += "Projekt nebyl aktualizován více než 6 měsíců. Zvažte archivaci nebo oživení."
        } elseif ($daysSinceLastChange -gt 30) {
            $recommendations += "Poslední změna před $([math]::Round($daysSinceLastChange)) dny. Možná je projekt neaktivní."
        }
    }
    if ($projectType -eq "Node.js / JavaScript projekt" -and -not (Test-Path (Join-Path $FolderPath "node_modules"))) {
        $recommendations += "Spusťte 'npm install' pro instalaci závislostí uvedených v package.json."
    }
    if ($projectType -eq "Python projekt" -and -not (Test-Path (Join-Path $FolderPath "venv")) -and -not (Test-Path (Join-Path $FolderPath ".venv"))) {
        $recommendations += "Doporučujeme vytvořit virtuální prostředí (python -m venv venv) a aktivovat ho."
    }
    if ($irrelevantFiles.Count -gt 0) {
        $recommendations += "Bylo nalezeno $($irrelevantFiles.Count) souborů, které pravděpodobně do tohoto projektu nepatří (např. .tmp, .log, duplicity). Spusťte 'Smart analýzu' pro jejich odstranění."
    }
    if ($totalSize -gt 500MB) {
        $recommendations += "Projekt je velmi velký (více než 500 MB). Zvažte odstranění nepotřebných souborů, použití .gitignore nebo uložení velkých binárek do LFS."
    }
    
    # ----- GENEROVÁNÍ MARKDOWN (bezpečné) -----
    $mdContent = @"
# Analýza a klasifikace složky: $(Split-Path $FolderPath -Leaf)

**Datum analýzy:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Cesta:** `$FolderPath`  

---

## 📊 Základní informace

| Metrika | Hodnota |
|---------|---------|
| Celková velikost | $([math]::Round($totalSize/1MB,2)) MB |
| Počet souborů | $fileCount |
| Počet složek | $folderCount |
| Poslední změna | $(if ($latestChange) { $latestChange } else { "žádné soubory" }) |
| Stáří projektu (od nejstaršího souboru) | $(if ($projectAgeDays) { "$([math]::Round($projectAgeDays)) dní" } else { "N/A" }) |

---

## 🧠 Klasifikace projektu

| Vlastnost | Hodnota |
|-----------|---------|
| **Typ projektu** | $projectType |
| **Jistota klasifikace** | $confidence |
| **Programovací jazyky** | $(if ($langs.Count -gt 0) { $langs -join ', ' } else { "žádné rozpoznané" }) |
| **Framework / ekosystém** | $(if ($framework) { $framework } else { "není specifický" }) |

---

## 📁 Klíčové soubory (přítomnost)

| Soubor | Stav |
|--------|------|
| README | $(if ($hasReadme) { "✅ Ano" } else { "❌ Chybí" }) |
| LICENSE | $(if ($hasLicense) { "✅ Ano" } else { "❌ Chybí" }) |
| .git | $(if ($hasGit) { "✅ Ano" } else { "❌ Ne" }) |
| .gitignore | $(if ($hasGitignore) { "✅ Ano" } else { "❌ Chybí" }) |
| Dockerfile / docker-compose | $(if ($hasDockerfile -or $hasDockerCompose) { "✅ Ano" } else { "❌ Ne" }) |
| requirements.txt / setup.py | $(if ($hasRequirements -or $hasSetupPy) { "✅ Ano" } else { "❌ Ne" }) |
| package.json | $(if ($hasPackageJson) { "✅ Ano" } else { "❌ Ne" }) |
| Makefile | $(if ($hasMakefile) { "✅ Ano" } else { "❌ Ne" }) |

---

## 🚦 Stav projektu a aktivita

| Ukazatel | Hodnota |
|----------|---------|
| **Celkový stav** | $status |
| **Dny od poslední změny** | $(if ($daysSinceLastChange) { "$([math]::Round($daysSinceLastChange)) dní" } else { "N/A" }) |
| **Počet git commitů** | $(if ($gitCommits) { $gitCommits } else { "není git repozitář" }) |

---

## ⚠️ Chybějící soubory / nedostatky

"@
    if ($missingFiles.Count -gt 0) {
        foreach ($mf in $missingFiles) { $mdContent += "- $mf`n" }
    } else {
        $mdContent += "Žádné zásadní chybějící soubory.`n"
    }
    
    $mdContent += @"

## 💡 Doporučené akce

"@
    if ($recommendations.Count -gt 0) {
        foreach ($rec in $recommendations) { $mdContent += "- $rec`n" }
    } else {
        $mdContent += "Projekt je v dobrém stavu, není třeba nic měnit.`n"
    }
    
    $mdContent += @"

## 🗑️ Nepatřící soubory (smart analýza)

Bylo nalezeno **$($irrelevantFiles.Count)** souborů, které pravděpodobně do projektu nepatří.

"@
    if ($irrelevantFiles.Count -gt 0) {
        $mdContent += "Prvních 20:`n"
        $irrelevantFiles | Select-Object -First 20 | ForEach-Object { $mdContent += "- `$($_.FullName)`n" }
        if ($irrelevantFiles.Count -gt 20) {
            $extraCount = $irrelevantFiles.Count - 20
            $mdContent += "... a další $extraCount souborů.`n"
        }
    } else {
        $mdContent += "Žádné nepatřící soubory.`n"
    }
    
    $mdContent += @"

## 🔗 Související akce

- Spusťte `Smart analýzu` pro automatické odstranění nepatřících souborů.
- Vytvořte knowledge base pomocí `Smart Update`.
- Exportujte balíček pro LLM/asistenta (menu 9).

---

*Tato analýza byla vygenerována nástrojem GemManager Pro Orchestrator.*
"@
    
    $mdContent | Out-File -FilePath $OutputFile -Encoding UTF8
    Write-Log "Analýza dokončena. Výstup uložen do: $OutputFile" -Color "Green"
    Write-Host "`nPro otevření souboru spusťte: notepad `"$OutputFile`" nebo code `"$OutputFile`"" -ForegroundColor Cyan
    $open = Read-Host "Chcete soubor nyní otevřít? (ano/ne)"
    if ($open -eq "ano") { Start-Process $OutputFile }
    return $OutputFile
}

# ----- NOVÁ FUNKCE: ORCHESTRÁTOR (s rozšířeným Python skriptem pro 72+ robotů) -----
function Invoke-Orchestrator {
    Write-Host "`n=======================================================" -ForegroundColor Magenta
    Write-Host " 🎵 GEM ORCHESTRÁTOR – SPRÁVA A OŽIVENÍ ARMÁDY ROBOTŮ" -ForegroundColor Magenta
    Write-Host "=======================================================" -ForegroundColor Magenta
    
    # 1. Zjištění složky VSTUPNÍ GEM (ORCHESTRÁTOR)
    $orchestratorPath = Join-Path $script:rootPath "VSTUPNÍ GEM (ORCHESTRÁTOR)"
    if (-not (Test-Path $orchestratorPath)) {
        Write-Log "Složka 'VSTUPNÍ GEM (ORCHESTRÁTOR)' neexistuje. Vytvářím..." -Color "Yellow"
        New-Item -ItemType Directory -Path $orchestratorPath -Force | Out-Null
    }
    
    # 2. Genesis složka a Python skript (ROZŠÍŘENÝ O GENEROVÁNÍ 72+ ROBOTŮ)
    $genesisPath = Join-Path $orchestratorPath "Genesis"
    if (-not (Test-Path $genesisPath)) {
        Write-Log "Vytvářím složku 'Genesis'..." -Color "Yellow"
        New-Item -ItemType Directory -Path $genesisPath -Force | Out-Null
    }
    
    $pythonScriptPath = Join-Path $genesisPath "generate_full_genesis.py"
    Write-Log "Generuji rozšířený Python skript pro vytvoření 72+ GEM robotů..." -Color "Cyan"
    
    $pythonScriptContent = @'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
generate_full_genesis.py
Vytvoří kompletní strukturu Genesis Aeterna v9.5 včetně 72+ specializovaných GEM robotů.
Spouští se z orchestrátoru.
"""

import os
import json
import shutil
from pathlib import Path
from datetime import datetime

# ==================== DNA MASTER REGISTRY (72+ gemů) ====================
# Generováno na základě kategorií a specializací – lze libovolně rozšířit
GEM_CATEGORIES = {
    "Core": {
        "description": "Jádrové GEMy – správa architektury, konfigurace a orchestrace",
        "count": 8,
        "prefix": "CORE"
    },
    "Tech": {
        "description": "Technologické GEMy – vývoj, integrace, DevOps, databáze",
        "count": 18,
        "prefix": "TECH"
    },
    "Security": {
        "description": "Bezpečnostní GEMy – audit, šifrování, zero-trust",
        "count": 10,
        "prefix": "SEC"
    },
    "Strategy": {
        "description": "Strategické GEMy – data, AI, business analýza",
        "count": 12,
        "prefix": "STRAT"
    },
    "Operations": {
        "description": "Operační GEMy – monitoring, logování, automatizace",
        "count": 10,
        "prefix": "OPS"
    },
    "Knowledge": {
        "description": "Znalostní GEMy – dokumentace, wiki, tréninkové materiály",
        "count": 8,
        "prefix": "KB"
    },
    "Integration": {
        "description": "Integrační GEMy – API, webhooky, messaging",
        "count": 8,
        "prefix": "INT"
    }
}

# Globální znalostní báze (z původního skriptu – rozšířeno)
KNOWLEDGE_BASE = {
    "core/01_global_constitution.md": """# 🌌 GLOBÁLNÍ ÚSTAVA PROJEKTU GENESIS AETERNA (v2.6)
**Poslední revize:** 2026 | **Priorita:** Kritická

## 1. ZÁKLADNÍ FILOZOFIE A ETICKÝ RÁMEC
- **Symbióza Člověka a AI:** Systém existuje jako rozšíření lidské vůle.
- **Integrita a Stabilita:** Žádná akce nesmí ohrozit integritu hostitelského systému...
- **Transparentnost:** Všechny operace jsou logovány a auditovány.
""",
    "core/02_dna_master_registry.md": """# 📋 DNA MASTER REGISTRY
Celkem 72 specializovaných Gemů rozdělených do 7 divizí.
Každý Gem má unikátní ID, popis a odpovědnosti.
""",
    "tech/08_dev_knowledge_base.md": """# DEVELOPMENT KNOWLEDGE BASE v2.5
Standardy: Python 3.12+, Docker, HAL, REST API.
Doporučené postupy pro vývoj a nasazení.
""",
    "security/09_security_knowledge_base.md": """# SECURITY KNOWLEDGE BASE
Principy Zero-Trust, mTLS, AES-256 šifrování, bezpečnostní audit.
""",
    "strategy/10_data_knowledge_base.md": """# DATA & AI STRATEGY
Strategie RAG, vektorizace, token management, AI governance.
""",
    "setup/install_all.sh": """#!/bin/bash
# Automatický instalátor pro Linux
mkdir -p ~/genesis/logs
echo 'Genesis Core Ready'
""",
    "setup/genesis_hud_v10.py": """#!/usr/bin/env python3
# Dashboard a HUD pro Genesis Aeterna
print('Genesis HUD v1.0 - Dashboard ready')
"""
}

def create_gem_structure(base_path):
    """Vytvoří složky pro všechny GEM roboty podle DNA registru."""
    base = Path(base_path)
    print(f"🚀 Zahajuji generování Genesis Aeterna v9.5 v: {base.absolute()}")
    
    # 1. Vytvoření složek pro jednotlivé GEMy
    total_gems = 0
    gem_list = []
    
    for category, info in GEM_CATEGORIES.items():
        cat_path = base / category
        cat_path.mkdir(parents=True, exist_ok=True)
        print(f"📁 Kategorie: {category} – {info['description']}")
        
        for i in range(1, info['count'] + 1):
            gem_name = f"{info['prefix']}_{i:03d}_{category}"
            gem_path = cat_path / gem_name
            gem_path.mkdir(parents=True, exist_ok=True)
            
            # README.md
            (gem_path / "README.md").write_text(
                f"# GEM Robot: {gem_name}\n\n"
                f"## Kategorie: {category}\n"
                f"## Popis: {info['description']}\n"
                f"## Stav: Inicializován\n"
                f"## Vygenerováno: {datetime.now().isoformat()}\n",
                encoding="utf-8"
            )
            # gem_config.json
            config = {
                "gem_id": gem_name,
                "category": category,
                "created": datetime.now().isoformat(),
                "status": "initialized",
                "version": "1.0"
            }
            (gem_path / "gem_config.json").write_text(json.dumps(config, indent=2), encoding="utf-8")
            gem_list.append(gem_name)
            total_gems += 1
    
    # 2. Vytvoření globální znalostní báze
    kb_root = base / "_knowledge_base"
    for rel_path, content in KNOWLEDGE_BASE.items():
        full = kb_root / rel_path
        full.parent.mkdir(parents=True, exist_ok=True)
        full.write_text(content, encoding="utf-8")
        print(f"✅ Znalost: {rel_path}")
    
    # 3. Globální konfigurace
    global_config = base / "_global_config.json"
    if not global_config.exists():
        default_config = {
            "relevanceThreshold": 0.3,
            "stopWords": ["a","an","and","the","of","to","in","for","on","with","by"],
            "lowRelevanceExtensions": [".jpg",".png",".zip",".exe"],
            "keywordBoost": {"fileName":0.4, "content":0.3, "extension":0.2},
            "gitEnabled": False,
            "gitRemoteUrl": "",
            "parallelJobs": 3,
            "backupRetentionDays": 30
        }
        global_config.write_text(json.dumps(default_config, indent=2), encoding="utf-8")
    
    # 4. Souhrnný manifest
    manifest = {
        "project": "Genesis Aeterna v9.5",
        "generated": datetime.now().isoformat(),
        "total_gems": total_gems,
        "categories": list(GEM_CATEGORIES.keys()),
        "gem_list": gem_list
    }
    (base / "genesis_manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    
    print(f"\n✨ GENEROVÁNÍ DOKONČENO – vytvořeno {total_gems} GEM robotů.")
    print("Složka je připravena k integraci do hlavního adresáře GEM robotů.")

if __name__ == "__main__":
    import sys
    target = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()
    create_gem_structure(target)
'@
    Set-Content -Path $pythonScriptPath -Value $pythonScriptContent -Encoding UTF8
    Write-Log "Python skript vytvořen: $pythonScriptPath" -Color "Green"
    
    # 3. Spuštění Python skriptu
    Write-Host "`nSpouštím Python skript pro vytvoření struktury 72+ GEM robotů..." -ForegroundColor Cyan
    try {
        $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
        if (-not $pythonCmd) {
            Write-Log "Python není nainstalován. Instalace není automatická – nainstalujte Python ručně." -Color "Red"
            Write-Host "Můžete skript spustit ručně: python `"$pythonScriptPath`" `"$script:rootPath`"" -ForegroundColor Yellow
        } else {
            & python $pythonScriptPath $script:rootPath
            Write-Log "Python skript úspěšně spuštěn." -Color "Green"
        }
    } catch {
        Write-Log "Chyba při spouštění Python skriptu: $_" -Color "Red"
    }
    
    # 4. Oživení armády GEM robotů (včetně nově vytvořených)
    Write-Host "`n=== OŽIVENÍ ARMÁDY GEM ROBOTŮ ===" -ForegroundColor Magenta
    $folders = Get-GemFolders
    if ($folders.Count -eq 0) {
        Write-Log "Žádné GEM složky k oživení." -Color "Yellow"
    } else {
        $total = $folders.Count
        $current = 0
        foreach ($folder in $folders) {
            $current++
            Write-Host "`n[$current / $total] Zpracovávám: $($folder.Name)" -ForegroundColor Cyan
            # Smart update (vytvoření KB)
            Process-GemFolder -SourceFolder $folder.FullName
            # Smart analýza (vyčištění)
            SmartAnalyze-And-Clean -FolderPath $folder.FullName
            # README je již v Process-GemFolder, ale pro jistotu
            Generate-Readme -FolderPath $folder.FullName
        }
        Write-Log "Všichni GEM roboti byli oživeni a integrováni." -Color "Green"
    }
    
    # 5. Souhrnný report
    Write-Host "`n=== SOUHRNNÝ REPORT PO OŽIVENÍ ===" -ForegroundColor Magenta
    Show-Overview
    Write-Host "`nOrchestrátor dokončil svou práci. Všichni roboti jsou připraveni." -ForegroundColor Green
}

# ----- HLAVNÍ MENU -----
function Show-MainMenu {
    do {
        Write-Host "`n=======================================================" -ForegroundColor Cyan
        Write-Host " 🧠 GEM KNOWLEDGE MANAGER: PRO EDITION (Orchestrator)" -ForegroundColor Cyan
        Write-Host "=======================================================" -ForegroundColor Cyan
        Write-Host " [1] Smart Update (inkrementální záloha) – jedna složka"
        Write-Host " [2] Sloučit PDF v jedné složce (qpdf)"
        Write-Host " [3] ZPRACOVAT VŠECHNY GEM SLOŽKY (sekvenčně)"
        Write-Host " [4] Vybrat konkrétní GEM složku k zpracování"
        Write-Host " [5] Zobrazit přehled všech GEM složek"
        Write-Host " [6] Export přehledu do HTML/CSV"
        Write-Host " [7] SMART ANALÝZA (automatické určení nepatřících souborů)"
        Write-Host " [8] PŘIDAT NOVÉHO ROBOTA (z libovolné složky)"
        Write-Host " [9] EXPORTOVAT BALÍČEK PRO PŘENOS (LLM / vlastní AI)"
        Write-Host " [10] Správa záloh (ruční záloha vybraného robota)"
        Write-Host " [11] Nastavit plánovanou úlohu (denní automatický update)"
        Write-Host " [12] Změnit kořenovou cestu"
        Write-Host " [13] HLOUBKOVÝ AUDIT SLOŽKY (detailní MD report)"
        Write-Host " [14] KOMPLEXNÍ ANALÝZA + KLASIFIKACE (včetně doporučení)"
        Write-Host " [15] 🎵 ORCHESTRÁTOR – Správa a oživení všech GEM robotů (72+ robotů)"
        Write-Host " [Q] Ukončit aplikaci"
        Write-Host "-------------------------------------------------------"

        $choice = Read-Host "Vyberte akci"

        switch -Regex ($choice) {
            "1" { $f = Select-GemFolder; if ($f) { Process-GemFolder -SourceFolder $f } }
            "2" { $f = Select-GemFolder; if ($f) { Merge-PdfInFolder -FolderPath $f } }
            "3" { Process-AllGemFolders }
            "4" { $f = Select-GemFolder; if ($f) { Process-GemFolder -SourceFolder $f } }
            "5" { Show-Overview }
            "6" { Export-Report }
            "7" { $f = Select-GemFolder; if ($f) { SmartAnalyze-And-Clean -FolderPath $f } }
            "8" { Add-NewGemRobot }
            "9" { $f = Select-GemFolder; if ($f) { Export-Package -FolderPath $f } }
            "10" { $f = Select-GemFolder; if ($f) { Backup-GemFolder -FolderPath $f } }
            "11" { Schedule-Task }
            "12" { Set-RootPath }
            "13" { $f = Select-GemFolder; if ($f) { Deep-AuditFolder -FolderPath $f } }
            "14" { $f = Select-GemFolder; if ($f) { Deep-AnalyzeAndClassify -FolderPath $f } }
            "15" { Invoke-Orchestrator }
            "[qQ]" { Write-Log "Ukončuji..." -Color "Cyan"; break }
            default { Write-Log "Neplatná volba." -Color "Red" }
        }
    } while ($choice -notmatch "[qQ]")
}

# ----- SPUŠTĚNÍ -----
if ($args[0] -eq "-AutoUpdate") {
    Load-Config
    AutoUpdate
    exit
}

Load-Config
if (-not (Test-Administrator)) {
    Write-Log "POZOR: Nemáte administrátorská práva. Instalace závislostí a plánování úloh může selhat." -Color "Yellow"
}
Show-MainMenu