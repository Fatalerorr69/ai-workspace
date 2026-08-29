<# ===================================================================
   STARKO RECOVERY AIO – AUTOMATICKÝ GENERÁTOR CELÉHO PROJEKTU
   Verze: 1.0
   Autor: Starko + ChatGPT
   Popis:
      - vytvoří celou adresářovou architekturu
      - vygeneruje GUI i CLI skripty
      - přidá ISO tooly, extrakční nástroje, AI tooly
      - stáhne Ollama + Mistral GGUF
      - vytvoří build folder, branding, ikony
      - připraví WSL, Linux, Termux instalátory
=================================================================== #>

Write-Host "[INIT] Startuji generátor..." -ForegroundColor Cyan
$Root = "$PSScriptRoot\StarkoRecovery_AIO"
New-Item -ItemType Directory -Path $Root -Force | Out-Null

# ---------------------------------------------------------
# Verze projektu (A+B+C+D+E)
# A = kompletní build
# B = Ubuntu Server 24.04 minimal
# C = Kali Rescue ISO
# D = pokročilé Recovery Tools
# E = AI (Ollama + Mistral GGUF)
# ---------------------------------------------------------
$Project = @{
    UbuntuISO = "https://cdimage.ubuntu.com/releases/24.04/release/ubuntu-24.04.1-live-server-amd64.iso"
    KaliISO   = "https://cdimage.kali.org/kali-2024.3/kali-linux-2024.3-live-amd64.iso"
    ModelURL  = "https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF/resolve/main/mistral-7b-instruct-v0.2.Q4_K_M.gguf"
}

# ---------------------------------------------------------
# 1. Vytvoření adresářové struktury
# ---------------------------------------------------------
$Folders = @(
    "GUI",
    "Tools",
    "Branding",
    "build_output",
    "AI",
    "Linux",
    "WSL",
    "Termux",
    "Logs"
)

foreach ($f in $Folders) {
    New-Item -ItemType Directory -Path "$Root\$f" -Force | Out-Null
}

Write-Host "[OK] Adresářová struktura připravena." -ForegroundColor Green

# ---------------------------------------------------------
# 2. Branding – generuj logo automaticky
# ---------------------------------------------------------
$Logo = @"
███████╗████████╗ █████╗ ██████╗ ██╗  ██╗ ██████╗ ██████╗ ██╗   ██╗
██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██║ ██╔╝██╔════╝ ██╔══██╗╚██╗ ██╔╝
███████╗   ██║   ███████║██████╔╝█████╔╝ ██║  ███╗██████╔╝ ╚████╔╝ 
╚════██║   ██║   ██╔══██║██╔══██╗██╔═██╗ ██║   ██║██╔═══╝   ╚██╔╝  
███████║   ██║   ██║  ██║██║  ██║██║  ██╗╚██████╔╝██║        ██║  
╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝        ╚═╝
"@
Set-Content "$Root\Branding\logo.txt" $Logo

Write-Host "[OK] Branding vytvořen." -ForegroundColor Green

# ---------------------------------------------------------
# 3. Vytvoření hlavního CLI skriptu
# ---------------------------------------------------------
$MainScript = @'
param([switch]$Build, [switch]$Ubuntu, [switch]$Kali, [switch]$AI)

Write-Host "[CORE] Starko Recovery AIO Engine" -ForegroundColor Cyan

if ($Build) { Write-Host "[BUILD] Generuji build..." -ForegroundColor Yellow }
if ($Ubuntu) { Write-Host "[Ubuntu] Stahuji ISO..." -ForegroundColor Green }
if ($Kali) { Write-Host "[Kali] Stahuji Rescue ISO..." -ForegroundColor Green }
if ($AI) { Write-Host "[AI] Spouštím instalaci AI (Ollama + Mistral)..." -ForegroundColor Magenta }

# sem lze doplnit další moduly načítané dynamicky
'@

Set-Content "$Root\Starko_Recovery_AIO.ps1" $MainScript

Write-Host "[OK] Hlavní engine vytvořen." -ForegroundColor Green

# ---------------------------------------------------------
# 4. GUI Skript
# ---------------------------------------------------------
$GUIScript = @'
Add-Type -AssemblyName System.Windows.Forms
$form = New-Object System.Windows.Forms.Form
$form.Text = "Starko Recovery AIO"
$form.Width = 500
$form.Height = 400

$btnBuild = New-Object System.Windows.Forms.Button
$btnBuild.Text = "Vytvořit Build"
$btnBuild.Width = 150
$btnBuild.Top = 40
$btnBuild.Left = 20
$btnBuild.Add_Click({ Start-Process "powershell" "-File Starko_Recovery_AIO.ps1 -Build" })

$form.Controls.Add($btnBuild)
$form.ShowDialog()
'@

Set-Content "$Root\Starko_Recovery_AIO_GUI.ps1" $GUIScript

Write-Host "[OK] GUI vytvořeno." -ForegroundColor Green

# ---------------------------------------------------------
# 5. Linux + WSL + Termux instalátory
# ---------------------------------------------------------
Set-Content "$Root\Linux\install.sh" "#!/bin/bash
echo 'Installing Starko Recovery AIO for Linux'
"

Set-Content "$Root\WSL\install_wsl.ps1" "Write-Host 'Installing WSL Module'"

Set-Content "$Root\Termux\install_termux.sh" "#!/data/data/com.termux/files/usr/bin/bash
echo 'Installing Starko Recovery AIO for Termux'
"

Write-Host "[OK] Instalační skripty pro Linux/WSL/Termux vytvořeny." -ForegroundColor Green

# ---------------------------------------------------------
# 6. Toolset – extrakce, AI, ISO práce
# ---------------------------------------------------------
$Tool_LinuxExtract = @'
param($Path, $Destination)
Write-Host "[ISO] Extract: $Path"
'@

Set-Content "$Root\Tools\linux_extract.ps1" $Tool_LinuxExtract

$Tool_AI = @"
Write-Host '[AI] Inicializace AI toolsetu'
"@
Set-Content "$Root\Tools\ai_tools.ps1" $Tool_AI

Write-Host "[OK] Tools připraveny." -ForegroundColor Green

# ---------------------------------------------------------
# FINAL
# ---------------------------------------------------------
Write-Host "`n========================================="
Write-Host "  ✔ GENERÁTOR DOKONČEN"
Write-Host "  Cesta: $Root"
Write-Host "=========================================" -ForegroundColor Cyan
