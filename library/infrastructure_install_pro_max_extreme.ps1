# ============================================================
# INSTALL_PRO_MAX_EXTREME.PS1 – FULL AUTOMATIC INSTALL
# ============================================================

Write-Host "=== STARKO PRO MAX EXTREME INSTALLER ===" -ForegroundColor Cyan
Write-Host "Start: $(Get-Date)" -ForegroundColor Green

# -------------------------------
# 0) Vytvoření složky pro modul
# -------------------------------
$ModulePath = "$env:USERPROFILE\Documents\PowerShell\Modules\Starko.SystemToolsProExtreme"
if (!(Test-Path $ModulePath)) { New-Item -ItemType Directory -Path $ModulePath -Force }

# -------------------------------
# 1) Instalace PowerShell 7.6+
# -------------------------------
Write-Host "[1/12] Instalace PowerShell 7.6+" -ForegroundColor Yellow
winget install --id Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements -h

# -------------------------------
# 2) Nastavení PATH a ExecutionPolicy
# -------------------------------
Write-Host "[2/12] Konfigurace prostředí..." -ForegroundColor Yellow
$paths = @(
    "$env:ProgramFiles\PowerShell\7",
    "$env:ProgramFiles\Git\bin",
    "$env:ProgramFiles\dotnet",
    "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps"
)
foreach ($p in $paths) {
    if ($env:PATH -notlike "*$p*") { [System.Environment]::SetEnvironmentVariable("PATH","$env:PATH;$p","User") }
}
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Set-ExecutionPolicy Unrestricted -Scope Process -Force

# -------------------------------
# 3) Instalace modulů PowerShell
# -------------------------------
Write-Host "[3/12] Instalace modulů..." -ForegroundColor Yellow
$modules = @("PSReadLine","posh-git","Terminal-Icons","PackageManagement","Microsoft.PowerShell.SecretManagement","Microsoft.PowerShell.SecretStore","Pester","ThreadJob")
foreach ($m in $modules) { Install-Module $m -Force -Scope CurrentUser -AllowClobber -ErrorAction SilentlyContinue }

# -------------------------------
# 4) Instalace klíčových nástrojů Winget
# -------------------------------
Write-Host "[4/12] Instalace nástrojů..." -ForegroundColor Yellow
$tools = @("Git.Git","Microsoft.VisualStudioCode","7zip.7zip","Microsoft.Sysinternals","OpenJS.NodeJS","Python.Python.3","JanDeDobbeleer.OhMyPosh","nmap","WiresharkFoundation.Wireshark","Docker.DockerDesktop","Microsoft.PowerToys")
foreach ($t in $tools) { winget install --id $t --accept-package-agreements --accept-source-agreements -h }

# -------------------------------
# 5) Optimalizace Windows
# -------------------------------
Write-Host "[5/12] Optimalizace Windows..." -ForegroundColor Yellow
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v MaxCacheTtl /t REG_DWORD /d 86400 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpAckFrequency /t REG_DWORD /d 1 /f
Get-Service MapsBroker -ErrorAction SilentlyContinue | Stop-Service -Force
Set-Service MapsBroker -StartupType Disabled

# -------------------------------
# 6) Vytvoření PowerShell profilu
# -------------------------------
Write-Host "[6/12] Nastavení profilu..." -ForegroundColor Yellow
$profileContent = @'
Import-Module PSReadLine
Import-Module posh-git
Import-Module Terminal-Icons
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -EditMode Windows
oh-my-posh init pwsh --config "$env:LOCALAPPDATA\oh-my-posh\themes\agnoster.omp.json" | Invoke-Expression
Set-Alias ll Get-ChildItem
Set-Alias gs git status
Set-Alias gc git commit
Set-Alias gp git push
'@
if (!(Test-Path -Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force | Out-Null }
$profileContent | Set-Content -Path $PROFILE

# -------------------------------
# 7) Instalace Python utilit
# -------------------------------
Write-Host "[7/12] Instalace Python balíčků..." -ForegroundColor Yellow
python -m pip install --upgrade pip
pip install requests colorama rich psutil tensorflow torch torchvision torchaudio

# -------------------------------
# 8) Instalace Node.js utilit
# -------------------------------
Write-Host "[8/12] Instalace Node utilit..." -ForegroundColor Yellow
npm install -g http-server nodemon yarn ts-node zx

# -------------------------------
# 9) Sysinternals + PATH
# -------------------------------
Write-Host "[9/12] Sysinternals..." -ForegroundColor Yellow
$sysinternals = "C:\Sysinternals"
if (!(Test-Path $sysinternals)) {
    mkdir $sysinternals
    Invoke-WebRequest "https://download.sysinternals.com/files/SysinternalsSuite.zip" -OutFile "$sysinternals\sys.zip"
    Expand-Archive "$sysinternals\sys.zip" -DestinationPath $sysinternals -Force
    Remove-Item "$sysinternals\sys.zip"
}
setx PATH "$env:PATH;$sysinternals"

# -------------------------------
# 10) WSL2 + Linux distribuce
# -------------------------------
Write-Host "[10/12] Instalace WSL2 a distribucí..." -ForegroundColor Yellow
wsl --install -d Ubuntu-22.04
wsl --install -d Kali-Linux
wsl --install -d Debian
wsl --set-default-version 2
$distros = wsl -l -q
foreach($d in $distros){ wsl -d $d -- sudo apt update && sudo apt upgrade -y }

# -------------------------------
# 11) Android Toolkit
# -------------------------------
Write-Host "[11/12] Instalace Android SDK a ADB/FASTBOOT..." -ForegroundColor Yellow
$android = "$env:USERPROFILE\AndroidSDK"
if (!(Test-Path $android)) { mkdir $android }
Invoke-WebRequest "https://dl.google.com/android/repository/commandlinetools-win-9477386_latest.zip" -OutFile "$android\cmdline-tools.zip"
Expand-Archive "$android\cmdline-tools.zip" -DestinationPath "$android" -Force
Remove-Item "$android\cmdline-tools.zip"
setx PATH "$env:PATH;$android\cmdline-tools\bin"

# -------------------------------
# 12) Finální nastavení & log
# -------------------------------
Write-Host "[12/12] Dokončuji instalaci..." -ForegroundColor Yellow

# Inicializace Starko modul (automatický)
$psm1 = @'
function Update-System { Write-Host "Update-System spustěn (stub)..." }
function SysReport { Write-Host "SysReport spustěn (stub)..." }
function starko { param([string]$Command); Write-Host "starko CLI: $Command" }
'@
$psm1 | Set-Content "$ModulePath\Starko.SystemToolsProExtreme.psm1"

# Import modulu do profilu
Add-Content -Path $PROFILE -Value "`nImport-Module '$ModulePath\Starko.SystemToolsProExtreme.psm1'"

Write-Host "=== INSTALACE HOTOVA ===" -ForegroundColor Green
Write-Host "Restartuj PowerShell a spusť příkaz: pwsh" -ForegroundColor Cyan
Write-Host "Poté spusť: starko update | starko gui | starko android | starko wsl | starko rpi" -ForegroundColor Cyan
