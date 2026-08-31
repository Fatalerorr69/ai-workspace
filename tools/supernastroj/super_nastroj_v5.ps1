#requires -RunAsAdministrator
<#
.SYNOPSIS
SUPER NÁSTROJ v5.0 – Full Max Edition
Author: FatalErorr69
PowerShell framework replacement of legacy batch version
#>

# =====================================================================
# KONSTANTY A CESTY
# =====================================================================
$Host.UI.RawUI.ForegroundColor = "White"
$BasePath = "C:\SuperNastroj"
$LogPath = "$BasePath\Logs"
$ToolsPath = "$BasePath\Tools"
$BackupPath = "$BasePath\Backups"
$ISOPath = "$BasePath\ISOs"

# =====================================================================
# FUNKCE
# =====================================================================

function Write-Color {
    param([string]$Text,[ConsoleColor]$Color=[ConsoleColor]::White)
    Write-Host $Text -ForegroundColor $Color
}

function Write-Log {
    param([string]$Message)
    if (!(Test-Path $LogPath)) { New-Item -ItemType Directory -Path $LogPath >$null }
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path "$LogPath\system.log" -Value "[$time] $Message"
}

function Init-System {
    Clear-Host
    Write-Color "==================================================" Cyan
    Write-Color "    SUPER NÁSTROJ v5.0 – Full Max Edition" Cyan
    Write-Color "==================================================" Cyan
    Write-Host ""

    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-Color "❌ Vyžadován PowerShell 5.1 nebo vyšší!" Red
        exit
    }

    foreach ($dir in @($LogPath,$ToolsPath,$BackupPath,$ISOPath)) {
        if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir >$null }
    }

    Write-Log "Super Nástroj v5.0 spuštěn"
    Write-Color "✅ Inicializace dokončena!" Green
    Start-Sleep -Seconds 1
}

# --------------------------
# 1. RYCHLÁ OPRAVA SYSTÉMU
# --------------------------
function Quick-Repair {
    Clear-Host
    Write-Color "==================================================" Cyan
    Write-Color "           KOMPLETNÍ OPRAVA SYSTÉMU" Cyan
    Write-Color "==================================================" Cyan
    Write-Host ""

    Write-Color "⏳ Spouštím SFC..." Yellow
    sfc /scannow

    Write-Color "⏳ Spouštím DISM..." Yellow
    DISM /Online /Cleanup-Image /RestoreHealth

    Write-Color "⏳ Čistím dočasné soubory..." Yellow
    Get-ChildItem "C:\Windows\Temp" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Get-ChildItem "$env:TEMP" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

    Write-Color "⏳ Obnovuji síť..." Yellow
    ipconfig /flushdns
    netsh winsock reset
    netsh int ip reset

    Write-Color "✅ Oprava systému dokončena!" Green
    Write-Log "Quick Repair completed"
    Pause
}

# --------------------------
# 2. POKROČILÁ DIAGNOSTIKA
# --------------------------
function Full-Diagnostic {
    Clear-Host
    Write-Color "🔍 KOMPLETNÍ SYSTÉMOVÁ DIAGNOSTIKA" Yellow
    Write-Host ""

    Write-Color "📌 Základní informace" Cyan
    systeminfo

    Write-Color "📌 Procesor" Cyan
    Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, MaxClockSpeed

    Write-Color "📌 Paměť" Cyan
    Get-CimInstance Win32_PhysicalMemory | Select-Object Manufacturer, Capacity, Speed

    Write-Color "📌 Disky" Cyan
    Get-CimInstance Win32_DiskDrive | Select-Object Model, Size, Status

    Write-Color "📌 Grafika" Cyan
    Get-CimInstance Win32_VideoController | Select-Object Name, AdapterRAM, DriverVersion

    Write-Log "Full diagnostic completed"
    Pause
}

function Hardware-Diagnostic {
    Clear-Host
    Write-Color "⚙️  DIAGNOSTIKA HARDWARE" Yellow
    Write-Host ""

    Get-CimInstance Win32_Processor | Format-Table
    Get-CimInstance Win32_PhysicalMemory | Format-Table
    Get-CimInstance Win32_DiskDrive | Format-Table
    Get-CimInstance Win32_VideoController | Format-Table

    Write-Log "Hardware diagnostic completed"
    Pause
}

function Network-Diagnostic {
    Clear-Host
    Write-Color "🌐 DIAGNOSTIKA SÍTĚ" Yellow
    Write-Host ""

    ipconfig /all
    ping 8.8.8.8 -n 4
    nslookup google.com

    Write-Log "Network diagnostic completed"
    Pause
}

# --------------------------
# 3. GENERÁTOR NÁSTROJŮ
# --------------------------
function Create-SecurityScripts {
    $path = "$ToolsPath\security_scan.ps1"

@"
Write-Host '🔍 Spouštím bezpečnostní sken...' -ForegroundColor Cyan
Get-MpComputerStatus | Select-Object AntivirusEnabled, RealTimeProtectionEnabled
Get-NetFirewallProfile | Select-Object Name,Enabled
Get-LocalUser | Select-Object Name,Enabled,LastLogon
Write-Host '✅ Hotovo!' -ForegroundColor Green
"@ | Out-File $path -Encoding UTF8

    Write-Color "✅ Vytvořen: security_scan.ps1" Green
    Write-Log "Security scripts created"
    Pause
}

function Create-NetworkTools {
    $path = "$ToolsPath\network_tools.ps1"

@"
Write-Host '🌐 SÍŤOVÉ NÁSTROJE' -ForegroundColor Cyan
ipconfig /all
ping 8.8.8.8
tracert google.com
netstat -ano
"@ | Out-File $path -Encoding UTF8

    Write-Color "✅ Vytvořen: network_tools.ps1" Green
    Write-Log "Network tools created"
    Pause
}

# --------------------------
# HLAVNÍ MENU
# --------------------------
function Main-Menu {
    while ($true) {
        Clear-Host
        Write-Color "==================================================" Cyan
        Write-Color "       SUPER NÁSTROJ v5.0 – Hlavní menu" Cyan
        Write-Color "==================================================" Cyan
        Write-Host ""

        Write-Color "[1] 🛠️  Rychlá oprava systému" Green
        Write-Color "[2] 🔍 Pokročilá diagnostika" Green
        Write-Color "[3] 📁 Generátor nástrojů" Green
        Write-Color "[4] ❌ Ukončit" Red
        Write-Host ""

        $choice = Read-Host "Vyberte možnost"

        switch ($choice) {
            "1" { Quick-Repair }
            "2" { 
                Clear-Host
                Write-Color "[1] Kompletní diagnostika" Green
                Write-Color "[2] Hardware diagnostika" Green
                Write-Color "[3] Síťová diagnostika" Green
                Write-Color "[4] Zpět" Yellow

                $sub = Read-Host "Vyberte možnost"
                switch ($sub) {
                    "1" { Full-Diagnostic }
                    "2" { Hardware-Diagnostic }
                    "3" { Network-Diagnostic }
                    "4" { return }
                }
            }
            "3" {
                Clear-Host
                Write-Color "[1] Vytvořit bezpečnostní skripty" Green
                Write-Color "[2] Vytvořit síťové nástroje" Green
                Write-Color "[3] Zpět" Yellow

                $sub = Read-Host "Vyberte možnost"
                switch ($sub) {
                    "1" { Create-SecurityScripts }
                    "2" { Create-NetworkTools }
                    "3" { return }
                }
            }
            "4" { exit }
        }
    }
}

# =====================================================================
# SPUŠTĚNÍ
# =====================================================================
Init-System
Main-Menu
