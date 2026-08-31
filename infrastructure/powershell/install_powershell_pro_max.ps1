# ============================================================
#  POWERHELL 7.5+ PRO MAX – Kompletní instalace a konfigurace
# ============================================================

Write-Host "=== PowerShell PRO MAX – Start ===" -ForegroundColor Cyan

# ------------------------------------------------------------
# 1) Instalace PowerShell 7.5+
# ------------------------------------------------------------
Write-Host "[1/12] Instalace PowerShell 7.5+" -ForegroundColor Yellow

winget install --id Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements -h

# ------------------------------------------------------------
# 2) Povolit skripty + optimalizace bezpečnostních politik
# ------------------------------------------------------------
Write-Host "[2/12] Nastavuji ExecutionPolicy..." -ForegroundColor Yellow

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Set-ExecutionPolicy Unrestricted -Scope Process -Force

# ------------------------------------------------------------
# 3) Instalace klíčových modulů PowerShellu
# ------------------------------------------------------------
Write-Host "[3/12] Instalace PS modulů..." -ForegroundColor Yellow

$modules = @(
  "PSReadLine",
  "posh-git",
  "Terminal-Icons",
  "PackageManagement",
  "Microsoft.PowerShell.SecretManagement",
  "Microsoft.PowerShell.SecretStore",
  "Pester",
  "ThreadJob"
)

foreach ($m in $modules) {
    Write-Host "Instaluji modul: $m"
    Install-Module $m -Force -ErrorAction SilentlyContinue
}

# ------------------------------------------------------------
# 4) Instalace rozšířených systémových nástrojů (winget)
# ------------------------------------------------------------
Write-Host "[4/12] Instalace nástrojů..." -ForegroundColor Yellow

$tools = @(
  "Git.Git",
  "Microsoft.WinGet",
  "Microsoft.VisualStudioCode",
  "Microsoft.PowerToys",
  "Gsudo",
  "7zip.7zip",
  "Microsoft.Sysinternals",
  "OpenJS.NodeJS",
  "Python.Python.3",
  "JanDeDobbeleer.OhMyPosh",
  "nmap",
  "WiresharkFoundation.Wireshark"
)

foreach ($t in $tools) {
    Write-Host "Instaluji: $t"
    winget install --id $t --accept-package-agreements --accept-source-agreements -h
}

# ------------------------------------------------------------
# 5) Základní systémová optimalizace
# ------------------------------------------------------------
Write-Host "[5/12] Optimalizace systému..." -ForegroundColor Yellow

# Rychlejší DNS + základní síťové optimalizace
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v MaxCacheTtl /t REG_DWORD /d 86400 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpAckFrequency /t REG_DWORD /d 1 /f

# Zakázání úlohy "MapsBroker"
Get-Service MapsBroker -ErrorAction SilentlyContinue | Stop-Service -Force
Set-Service MapsBroker -StartupType Disabled

# ------------------------------------------------------------
# 6) Vytvoření PowerShell profilu (Oh-My-Posh + Terminal-Icons)
# ------------------------------------------------------------
Write-Host "[6/12] Tvořím PowerShell profil..." -ForegroundColor Yellow

$profileContent = @'
Import-Module PSReadLine
Import-Module posh-git
Import-Module Terminal-Icons

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -EditMode Windows

# Oh-My-Posh
oh-my-posh init pwsh --config "$env:LOCALAPPDATA\oh-my-posh\themes\agnoster.omp.json" | Invoke-Expression

# Alias
Set-Alias ll Get-ChildItem
Set-Alias gs git status
Set-Alias gc git commit
Set-Alias gp git push
'@

if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

$profileContent | Set-Content -Path $PROFILE

# ------------------------------------------------------------
# 7) Instalace balíčků Pythonu
# ------------------------------------------------------------
Write-Host "[7/12] Instalace Python utilit..." -ForegroundColor Yellow

python -m pip install --upgrade pip
pip install requests colorama rich psutil

# ------------------------------------------------------------
# 8) Instalace Node.js utilit (globálně)
# ------------------------------------------------------------
Write-Host "[8/12] Instalace Node utilit..." -ForegroundColor Yellow

npm install -g http-server nodemon yarn ts-node zx

# ------------------------------------------------------------
# 9) Instalace Sysinternals do PATH
# ------------------------------------------------------------
Write-Host "[9/12] Rozšiřuji PATH o Sysinternals..." -ForegroundColor Yellow

$sysinternals = "C:\Sysinternals"
if (!(Test-Path $sysinternals)) {
    mkdir $sysinternals
    Invoke-WebRequest -Uri "https://download.sysinternals.com/files/SysinternalsSuite.zip" -OutFile "$sysinternals\sys.zip"
    Expand-Archive "$sysinternals\sys.zip" -DestinationPath $sysinternals -Force
    Remove-Item "$sysinternals\sys.zip"
}
setx PATH "$env:PATH;$sysinternals"

# ------------------------------------------------------------
# 10) Aktivace SecretStore
# ------------------------------------------------------------
Write-Host "[10/12] Nastavení SecretStore..." -ForegroundColor Yellow

Register-SecretVault -Name Vault -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault

# ------------------------------------------------------------
# 11) Reset WinGet cache + údržba
# ------------------------------------------------------------
Write-Host "[11/12] Čistím WinGet cache..." -ForegroundColor Yellow

winget source reset --force
winget source update

# ------------------------------------------------------------
# 12) Hotovo
# ------------------------------------------------------------
Write-Host "=== Instalace dokončena ===" -ForegroundColor Green
Write-Host "Restartuj PowerShell a použij: pwsh" -ForegroundColor Cyan
