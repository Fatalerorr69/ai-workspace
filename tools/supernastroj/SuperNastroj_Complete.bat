@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title SUPER NÁSTROJ v5.0 - FatalErorr69 Ultimate Edition

:: ==================================================
:: BARVY PRO WINDOWS
:: ==================================================
set "ESC="
set "RED=%ESC%[91m"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "BLUE=%ESC%[94m"
set "MAGENTA=%ESC%[95m"
set "CYAN=%ESC%[96m"
set "WHITE=%ESC%[97m"
set "RESET=%ESC%[0m"

:: ==================================================
:: INICIALIZACE SYSTÉMU
:: ==================================================
:INIT_SYSTEM
cls
echo.
echo %CYAN%=================================================%RESET%
echo %CYAN%     🚀 SUPER NÁSTROJ v5.0 - FATALERROR69%RESET%
echo %CYAN%=================================================%RESET%
echo.
echo %YELLOW%🔍 Inicializuji SuperNástroj v5.0...%RESET%
echo %YELLOW%📋 Kontroluji systémové požadavky...%RESET%

:: Kontrola administrátorských práv
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%❌ SPUSŤTE SKRIPT JAKO SPRÁVCE (Run as Administrator)!%RESET%
    echo.
    pause
    exit /b 1
)

:: Kontrola PowerShell
powershell -Command "exit 0" >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%❌ PowerShell není dostupný - je vyžadován!%RESET%
    pause
    exit /b 1
)

:: Vytvoření systémových složek
if not exist "SuperNastroj_Logs" mkdir "SuperNastroj_Logs"
if not exist "SuperNastroj_Tools" mkdir "SuperNastroj_Tools"
if not exist "SuperNastroj_Backups" mkdir "SuperNastroj_Backups"
if not exist "SuperNastroj_ISOs" mkdir "SuperNastroj_ISOs"

:: Logování spuštění
echo [%date% %time%] SuperNástroj v5.0 spuštěn >> "SuperNastroj_Logs\system.log"

echo %GREEN%✅ Inicializace dokončena!%RESET%
timeout /t 2 >nul

goto MAIN_MENU

:: ==================================================
:: HLAVNÍ MENU
:: ==================================================
:MAIN_MENU
cls
echo.
echo %CYAN%==================================================%RESET%
echo %CYAN%     🚀 SUPER NÁSTROJ v5.0 - FATALERROR69%RESET%
echo %CYAN%==================================================%RESET%
echo.
echo %GREEN%[1]%RESET%  🛠️  Rychlá oprava systému
echo %GREEN%[2]%RESET%  🔍 Pokročilá diagnostika
echo %GREEN%[3]%RESET%  📁 Generátor souborů a nástrojů
echo %GREEN%[4]%RESET%  🚀 Boot Disk Creator
echo %GREEN%[5]%RESET%  🛡️  Bezpečnost a optimalizace
echo %GREEN%[6]%RESET%  🌐 Síťové nástroje
echo %GREEN%[7]%RESET%  💾 Správa disků a zálohování
echo %GREEN%[8]%RESET%  🔧 Nástroje pro obnovu systému
echo %GREEN%[9]%RESET%  ⚙️  Nastavení a konfigurace
echo %GREEN%[10]%RESET% 📊 Generovat diagnostický report
echo %GREEN%[11]%RESET% ❌ Konec
echo.
set /p choice="%WHITE%Vyberte možnost [1-11]: %RESET%"

if "%choice%"=="" goto MAIN_MENU
if "%choice%"=="1" goto QUICK_REPAIR
if "%choice%"=="2" goto ADVANCED_DIAGNOSTICS
if "%choice%"=="3" goto FILE_TOOL_GENERATOR
if "%choice%"=="4" goto BOOT_DISK_CREATOR
if "%choice%"=="5" goto SECURITY_OPTIMIZATION
if "%choice%"=="6" goto NETWORK_TOOLS
if "%choice%"=="7" goto DISK_MANAGEMENT
if "%choice%"=="8" goto SYSTEM_RECOVERY
if "%choice%"=="9" goto SETTINGS_CONFIG
if "%choice%"=="10" goto GENERATE_REPORT
if "%choice%"=="11" goto END
goto MAIN_MENU

:: ==================================================
:: 1. RYCHLÁ OPRAVA SYSTÉMU
:: ==================================================
:QUICK_REPAIR
cls
echo.
echo %CYAN%==================================================%RESET%
echo %CYAN%          🛠️  KOMPLETNÍ OPRAVA SYSTÉMU%RESET%
echo %CYAN%==================================================%RESET%
echo.
echo %YELLOW%⏳ Tato operace může trvat 15-30 minut...%RESET%
echo.
pause

echo %YELLOW%🔍 Kontroluji systémové soubory (SFC)...%RESET%
sfc /scannow
call :CHECK_ERROR "SFC scan"

echo.
echo %YELLOW%🗃️  Kontroluji image systému (DISM)...%RESET%
DISM /Online /Cleanup-Image /RestoreHealth
call :CHECK_ERROR "DISM repair"

echo.
echo %YELLOW%💾 Kontroluji disky (CHKDSK)...%RESET%
chkdsk /scan
call :CHECK_ERROR "CHKDSK scan"

echo.
echo %YELLOW%🔄 Obnovuji systémové komponenty...%RESET%
powershell -Command "Repair-WindowsImage -Online -RestoreHealth" >nul 2>&1

echo.
echo %YELLOW%🧹 Čistím dočasné soubory...%RESET%
call :CLEAN_TEMP_FILES

echo.
echo %YELLOW%🌐 Obnovuji síťové nastavení...%RESET%
ipconfig /flushdns >nul
netsh winsock reset >nul
netsh int ip reset >nul

echo.
echo %GREEN%✅ Kompletní oprava systému dokončena!%RESET%
call :LOG_INFO "System repair completed"
echo %CYAN%📊 Podrobný report: SuperNastroj_Logs\system.log%RESET%
pause
goto MAIN_MENU

:: ==================================================
:: 2. POKROČILÁ DIAGNOSTIKA
:: ==================================================
:ADVANCED_DIAGNOSTICS
cls
echo.
echo %CYAN%==================================================%RESET%
echo %CYAN%          🔍 POKROČILÁ DIAGNOSTIKA%RESET%
echo %CYAN%==================================================%RESET%
echo.
echo %GREEN%[1]%RESET% Kompletní systémová diagnostika
echo %GREEN%[2]%RESET% Diagnostika hardware
echo %GREEN%[3]%RESET% Výkonostní analýza
echo %GREEN%[4]%RESET% Diagnostika sítě
echo %GREEN%[5]%RESET% Analýza bezpečnosti
echo %GREEN%[6]%RESET% Diagnostika bootování
echo %GREEN%[7]%RESET% Zpět do hlavního menu
echo.
set /p diag_choice="%WHITE%Vyberte možnost [1-7]: %RESET%"

if "%diag_choice%"=="" goto ADVANCED_DIAGNOSTICS
if "%diag_choice%"=="1" goto FULL_SYSTEM_DIAG
if "%diag_choice%"=="2" goto HARDWARE_DIAG
if "%diag_choice%"=="3" goto PERFORMANCE_DIAG
if "%diag_choice%"=="4" goto NETWORK_DIAG
if "%diag_choice%"=="5" goto SECURITY_DIAG
if "%diag_choice%"=="6" goto BOOT_DIAG
if "%diag_choice%"=="7" goto MAIN_MENU
goto ADVANCED_DIAGNOSTICS

:FULL_SYSTEM_DIAG
cls
echo.
echo %YELLOW%🔍 KOMPLETNÍ SYSTÉMOVÁ DIAGNOSTIKA...%RESET%
echo.
echo %CYAN%📊 Základní informace o systému:%RESET%
systeminfo | findstr /C:"Host Name" /C:"OS Name" /C:"OS Version" /C:"System Type"
echo.
echo %CYAN%💻 Informace o procesoru:%RESET%
wmic cpu get name,numberofcores,maxclockspeed
echo.
echo %CYAN%🧠 Informace o paměti:%RESET%
wmic memorychip get capacity,speed,manufacturer
echo.
echo %CYAN%💾 Informace o discích:%RESET%
wmic diskdrive get model,size,status
echo.
call :LOG_INFO "Full system diagnostic completed"
pause
goto ADVANCED_DIAGNOSTICS

:HARDWARE_DIAG
cls
echo.
echo %YELLOW%⚙️  DIAGNOSTIKA HARDWARE...%RESET%
echo.
echo %CYAN%🖥️  CPU:%RESET%
wmic cpu get name,numberofcores,numberoflogicalprocessors,maxclockspeed
echo.
echo %CYAN%🧠 RAM:%RESET%
wmic memorychip get capacity,speed,manufacturer,partnumber
echo.
echo %CYAN%💾 Disky:%RESET%
wmic diskdrive get model,size,interfacetype,status
echo.
echo %CYAN%🖥️  GPU:%RESET%
wmic path win32_VideoController get name,adapterram,driverversion
echo.
echo %CYAN%🌡️  Teploty (pokud dostupné):%RESET%
powershell -Command "Get-WmiObject MSAcpi_ThermalZoneTemperature -Namespace root/wmi | Select-Object CurrentTemperature" 2>nul
call :LOG_INFO "Hardware diagnostic completed"
pause
goto ADVANCED_DIAGNOSTICS

:PERFORMANCE_DIAG
cls
echo.
echo %YELLOW%📈 VÝKONOSTNÍ ANALÝZA...%RESET%
echo.
echo %CYAN%⚡ Využití CPU:%RESET%
wmic cpu get loadpercentage
echo.
echo %CYAN%🧠 Stav paměti:%RESET%
systeminfo | findstr /C:"Available Physical Memory" /C:"Virtual Memory"
echo.
echo %CYAN%💾 Výkon disků:%RESET%
wmic logicaldisk get name,size,freespace,filesystem
echo.
echo %CYAN%🌐 Síťová statistika:%RESET%
netstat -e
call :LOG_INFO "Performance diagnostic completed"
pause
goto ADVANCED_DIAGNOSTICS

:NETWORK_DIAG
cls
echo.
echo %YELLOW%🌐 DIAGNOSTIKA SÍTĚ...%RESET%
echo.
echo %CYAN%📊 Síťová konfigurace:%RESET%
ipconfig /all
echo.
echo %CYAN%🔍 Test připojení:%RESET%
ping 8.8.8.8 -n 4
echo.
echo %CYAN%🌐 DNS informace:%RESET%
nslookup google.com
call :LOG_INFO "Network diagnostic completed"
pause
goto ADVANCED_DIAGNOSTICS

:SECURITY_DIAG
cls
echo.
echo %YELLOW%🛡️  ANALÝZA BEZPEČNOSTI...%RESET%
echo.
echo %CYAN%🔍 Windows Defender Status:%RESET%
powershell -Command "Get-MpComputerStatus | Select-Object AntivirusEnabled,RealTimeProtectionEnabled,IoavProtectionEnabled" 2>nul
echo.
echo %CYAN%🔥 Firewall Status:%RESET%
netsh advfirewall show allprofiles state
echo.
echo %CYAN%📋 Otevřené porty:%RESET%
netstat -an | find "LISTENING" | more
call :LOG_INFO "Security diagnostic completed"
pause
goto ADVANCED_DIAGNOSTICS

:BOOT_DIAG
cls
echo.
echo %YELLOW%🚀 DIAGNOSTIKA BOOTOVÁNÍ...%RESET%
echo.
echo %CYAN%⏱️  Boot čas:%RESET%
powershell -Command "Get-WinEvent -LogName System -MaxEvents 1 | Where-Object {$_.Id -eq 6005} | Select-Object TimeCreated"
echo.
echo %CYAN%📋 Startup programy:%RESET%
wmic startup get caption,command,location
echo.echo %CYAN%🔧 Boot konfigurace:%RESET%
bcdedit /enum {current}
call :LOG_INFO "Boot diagnostic completed"
pause
goto ADVANCED_DIAGNOSTICS

:: ==================================================
:: 3. GENERÁTOR SOUBORŮ A NÁSTROJŮ
:: ==================================================
:FILE_TOOL_GENERATOR
cls
echo.
echo %CYAN%==================================================%RESET%
echo %CYAN%          📁 GENERÁTOR SOUBORŮ A NÁSTROJŮ%RESET%
echo %CYAN%==================================================%RESET%
echo.
echo %GREEN%[1]%RESET% Vytvořit základní soubory projektu
echo %GREEN%[2]%RESET% Vytvořit bezpečnostní skripty
echo %GREEN%[3]%RESET% Vytvořit síťové nástroje
echo %GREEN%[4]%RESET% Vytvořit záchranné soubory
echo %GREEN%[5]%RESET% Vytvořit diagnostické nástroje
echo %GREEN%[6]%RESET% Vytvořit kompletní sadu nástrojů
echo %GREEN%[7]%RESET% Zpět do hlavního menu
echo.
set /p file_choice="%WHITE%Vyberte možnost [1-7]: %RESET%"

if "%file_choice%"=="" goto FILE_TOOL_GENERATOR
if "%file_choice%"=="1" goto CREATE_PROJECT_FILES
if "%file_choice%"=="2" goto CREATE_SECURITY_SCRIPTS
if "%file_choice%"=="3" goto CREATE_NETWORK_TOOLS
if "%file_choice%"=="4" goto CREATE_RESCUE_FILES
if "%file_choice%"=="5" goto CREATE_DIAGNOSTIC_TOOLS
if "%file_choice%"=="6" goto CREATE_COMPLETE_TOOLKIT
if "%file_choice%"=="7" goto MAIN_MENU
goto FILE_TOOL_GENERATOR

:CREATE_SECURITY_SCRIPTS
echo.
echo %YELLOW%🛡️  VYTVÁŘÍM BEZPEČNOSTNÍ SKRIPTY...%RESET%
(
echo # Security Scan Script - FatalErorr69
echo Write-Host "🔍 Spouštím bezpečnostní sken..." -ForegroundColor Cyan
echo.
echo # Windows Defender Status
echo Write-Host "🛡️  Windows Defender:" -ForegroundColor Yellow
echo Get-MpComputerStatus ^| Select-Object AntivirusEnabled, RealTimeProtectionEnabled
echo.
echo # Firewall Status
echo Write-Host "🔥 Firewall Status:" -ForegroundColor Yellow
echo Get-NetFirewallProfile ^| Select-Object Name, Enabled
echo.
echo # User Accounts
echo Write-Host "👤 Uživatelské účty:" -ForegroundColor Yellow
echo Get-LocalUser ^| Select-Object Name, Enabled, LastLogon
echo.
echo Write-Host "✅ Sken dokončen!" -ForegroundColor Green
) > "SuperNastroj_Tools\security_scan.ps1"
echo %GREEN%✅ Vytvořen: security_scan.ps1%RESET%
call :LOG_INFO "Security scripts created"
pause
goto FILE_TOOL_GENERATOR

:CREATE_NETWORK_TOOLS
echo.
echo %YELLOW%🌐 VYTVÁŘÍM SÍŤOVÉ NÁSTROJE...%RESET%
(
echo @echo off
echo title SÍŤOVÉ NÁSTROJE - FatalErorr69
echo echo 🌐 SÍŤOVÉ DIAGNOSTICKÉ NÁSTROJE
echo echo ========================================
echo echo.
echo echo [1] Zobrazit síťovou konfiguraci
echo echo [2] Test připojení ^(ping^)
echo echo [3] Traceroute
echo echo [4] DNS lookup
echo echo [5] Zobrazit aktivní spojení
echo echo [6] Reset síťových nastavení
echo echo.
echo set /p choice="Vyberte možnost: "
echo.
echo if "%%choice%%"=="1" ipconfig /all
echo if "%%choice%%"=="2" ping 8.8.8.8
echo if "%%choice%%"=="3" tracert google.com
echo if "%%choice%%"=="4" nslookup google.com
echo if "%%choice%%"=="5" netstat -ano
echo if "%%choice%%"=="6" ^(
echo     ipconfig /flushdns
echo     netsh winsock reset
echo     netsh int ip reset
echo ^)
echo.
echo pause
) > "SuperNastroj_Tools\network_tools.bat"
echo %GREEN%✅ Vytvořen: network_tools.bat%RESET%
call :LOG_INFO "Network tools created"
pause
goto FILE_TOOL_GENERATOR

:: ==================================================
:: 4. BOOT DISK CREATOR
:: ==================================================
:BOOT_DISK_CREATOR
cls
echo.
echo %CYAN%==================================================%RESET%
echo %CYAN%          🚀 BOOT DISK CREATOR%RESET%
echo %CYAN%==================================================%RESET%
echo.
echo %GREEN%[1]%RESET% Vytvořit Windows Repair USB
echo %GREEN%[2]%RESET% Vytvořit Linux Boot USB
echo %GREEN%[3]%RESET% Vytvořit Multiboot USB
echo %GREEN%[4]%RESET% Zpět do hlavního menu
echo.
set /p boot_choice="%WHITE%Vyberte možnost [1-4]: %RESET%"

if "%boot_choice%"=="" goto BOOT_DISK_CREATOR
if "%boot_choice%"=="1" goto CREATE_WINDOWS_USB
if "%boot_choice%"=="2" goto CREATE_LINUX_USB
if "%boot_choice%"=="3" goto CREATE_MULTIBOOT_USB
if "%boot_choice%"=="4" goto MAIN_MENU
goto BOOT_DISK_CREATOR

:CREATE_WINDOWS_USB
cls
echo.
echo %YELLOW%🚀 VYTVÁŘENÍ WINDOWS REPAIR USB%RESET%
echo.
echo %RED%⚠️  VAROVÁNÍ: Všechna data na USB budou smazána!%RESET%
echo.
list disk
echo.
set /p usb_drive="%WHITE%Zadejte písmeno USB disku (např. F): %RESET%"
if "%usb_drive%"=="" goto BOOT_DISK_CREATOR

echo.
echo %YELLOW%📋 Formátuji USB disk %usb_drive%...%RESET%
format %usb_drive%: /FS:NTFS /Q /V:WindowsRepair

echo.
echo %YELLOW%📁 Vytvářím strukturu složek...%RESET%
mkdir "%usb_drive%:\ISOs"
mkdir "%usb_drive%:\Tools"
mkdir "%usb_drive%:\Drivers"
mkdir "%usb_drive%:\Recovery"

echo.
echo %GREEN%✅ Windows Repair USB vytvořen!%RESET%
echo %CYAN%💡 Zkopírujte Windows ISO do %usb_drive%:\ISOs\%RESET%
call :LOG_INFO "Windows USB created on drive %usb_drive%"
pause
goto BOOT_DISK_CREATOR

:: ==================================================
:: 5. BEZPEČNOST A OPTIMALIZACE
:: ==================================================
:SECURITY_OPTIMIZATION
cls
echo.
echo %CYAN%==================================================%RESET%
echo %CYAN%          🛡️  BEZPEČNOST A OPTIMALIZACE%RESET%
echo %CYAN%==================================================%RESET%
echo.
echo %GREEN%[1]%RESET% Security scan
echo %GREEN%[2]%RESET% Security hardening
echo %GREEN%[3]%RESET% Optimalizace systému
echo %GREEN%[4]%RESET% Zpět do hlavního menu
echo.
set /p sec_choice="%WHITE%Vyberte možnost [1-4]: %RESET%"

if "%sec_choice%"=="" goto SECURITY_OPTIMIZATION
if "%sec_choice%"=="1" goto SECURITY_SCAN
if "%sec_choice%"=="2" goto SECURITY_HARDENING
if "%sec_choice%"=="3" goto SYSTEM_OPTIMIZATION
if "%sec_choice%"=="4" goto MAIN_MENU
goto SECURITY_OPTIMIZATION

:SECURITY_SCAN
cls
echo.
echo %YELLOW%🔍 SECURITY SCAN...%RESET%
echo.
echo %CYAN%🛡️  Windows Defender:%RESET%
powershell -Command "Get-MpComputerStatus | Format-List"
echo.
echo %CYAN%🔥 Firewall:%RESET%
netsh advfirewall show allprofiles
echo.
echo %CYAN%📋 Uživatelé:%RESET%
net user
call :LOG_INFO "Security scan completed"
pause
goto SECURITY_OPTIMIZATION

:SECURITY_HARDENING
cls
echo.
echo %YELLOW%🔒 SECURITY HARDENING...%RESET%
echo.
echo %CYAN%Posiluji zabezpečení systému...%RESET%
echo.

:: UAC na maximum
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 1 /f >nul
echo %GREEN%✅ UAC povolen%RESET%

:: Firewall on
netsh advfirewall set allprofiles state on >nul
echo %GREEN%✅ Firewall aktivován%RESET%

:: Windows Update
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 0 /f >nul
echo %GREEN%✅ Automatické aktualizace povoleny%RESET%

echo.
echo %GREEN%✅ Security hardening dokončen!%RESET%
call :LOG_INFO "Security hardening completed"
pause
goto SECURITY_OPTIMIZATION

:SYSTEM_OPTIMIZATION
cls
echo.
echo %YELLOW%⚡ OPTIMALIZACE SYSTÉMU...%RESET%
echo.

echo %CYAN%🧹 Čištění temp souborů...%RESET%
call :CLEAN_TEMP_FILES

echo %CYAN%📊 Optimalizace služeb...%RESET%
sc config "DiagTrack" start= disabled >nul 2>&1
sc stop "DiagTrack" >nul 2>&1
echo %GREEN%✅ Telemetrie vypnuta%RESET%

echo %CYAN%🗃️  Defragmentace...%RESET%
defrag C: /O >nul 2>&1
echo %GREEN%✅ Defragmentace dokončena%RESET%

echo.
echo %GREEN%✅ Optimalizace systému dokončena!%RESET%
call :LOG_INFO "System optimization completed"
pause
goto SECURITY_OPTIMIZATION

:: ==================================================
:: 6. SÍŤOVÉ NÁSTROJE
:: ==================================================
:NETWORK_TOOLS
cls
echo.
echo %CYAN%==================================================%RESET%
echo %CYAN%          🌐 SÍŤOVÉ NÁSTROJE%RESET%
echo %CYAN%==================================================%RESET%
echo.
echo %GREEN%[1]%RESET% Síťová diagnostika
echo %GREEN%[2]%RESET% WiFi analýza
echo %GREEN%[3]%RESET% Test rychlosti
echo %GREEN%[4]%RESET% Port scanner
echo %GREEN%[5]%RESET% Zpět do hlavního menu
echo.
set /p net_choice="%WHITE%Vyberte možnost [1-5]: %RESET%"

if "%net_choice%"=="" goto NETWORK_TOOLS
if "%net_choice%"=="1" goto NETWORK_DIAGNOSTIC
if "%net_choice%"=="2" goto WIFI_ANALYSIS
if "%net_choice%"=="3" goto SPEED_TEST
if "%net_choice%"=="4" goto PORT_SCANNER
if "%net_choice%"=="5" goto MAIN_MENU
goto NETWORK_TOOLS

:NETWORK_DIAGNOSTIC
cls
echo.
echo %YELLOW%🌐 SÍŤOVÁ DIAGNOSTIKA...%RESET%
echo.
ipconfig /all
echo.
echo %CYAN%🔍 Test připojení:%RESET%
ping 8.8.8.8 -n 4
echo.
echo %CYAN%🌐 DNS test:%RESET%
nslookup google.com
call :LOG_INFO "Network diagnostic completed"
pause
goto NETWORK_TOOLS

:WIFI_ANALYSIS
cls
echo.
echo %YELLOW%📡 WIFI ANALÝZA...%RESET%
echo.
netsh wlan show networks mode=bssid
echo.
netsh wlan show interfaces
call :LOG_INFO "WiFi analysis completed"
pause
goto NETWORK_TOOLS

:: ==================================================
:: 7. SPRÁVA DISKŮ A ZÁLOHOVÁNÍ
:: ==================================================
:DISK_MANAGEMENT
cls
echo.
echo %CYAN%==================================================%RESET%
echo %CYAN%          💾 SPRÁVA DISKŮ A ZÁLOHOVÁNÍ%RESET%
echo %CYAN%==================================================%RESET%
echo.
echo %GREEN%[1]%RESET% Zobrazit informace o discích
echo %GREEN%[2]%RESET% Analyzovat využití prostoru
echo %GREEN%[3]%RESET% Vytvořit zálohu
echo %GREEN%[4]%RESET% Obnovit zálohu
echo %GREEN%[5]%RESET% Optimalizovat disky
echo %GREEN%[6]%RESET% Zpět do hlavního menu
echo.
set /p disk_choice="%WHITE%Vyberte možnost [1-6]: %RESET%"

if "%disk_choice%"=="" goto DISK_MANAGEMENT
if "%disk_choice%"=="1" goto SHOW_DISK_INFO
if "%disk_choice%"=="2" goto ANALYZE_SPACE
if "%disk_choice%"=="3" goto CREATE_BACKUP
if "%disk_choice%"=="4" goto RESTORE_BACKUP
if "%disk_choice%"=="5" goto OPTIMIZE_DISKS
if "%disk_choice%"=="6" goto MAIN_MENU
goto DISK_MANAGEMENT

:SHOW_DISK_INFO
cls
echo.
echo %YELLOW%💽 INFORMACE O DISCÍCH...%RESET%
echo.
wmic logicaldisk get deviceid,size,freespace,filesystem
echo.
wmic diskdrive get model,size,status
call :LOG_INFO "Disk info displayed"
pause
goto DISK_MANAGEMENT

:CREATE_BACKUP
cls
echo.
echo %YELLOW%💾 VYTVÁŘENÍ ZÁLOHY...%RESET%
set /p backup_source="%WHITE%Zadejte cestu k zálohování (C:\Users): %RESET%"
if "%backup_source%"=="" set backup_source=C:\Users

set backup_dest=SuperNastroj_Backups\Backup_%date:~6,4%%date:~3,2%%date:~0,2%

echo.
echo %CYAN%🔄 Zálohuji z %backup_source% do %backup_dest%...%RESET%
xcopy "%backup_source%" "%backup_dest%" /E /H /C /I /Y

if %errorlevel% equ 0 (
    echo %GREEN%✅ Záloha úspěšně vytvořena%RESET%
) else (
    echo %RED%❌ Chyba při zálohování%RESET%
)
call :LOG_INFO "Backup created from %backup_source%"
pause
goto DISK_MANAGEMENT

:: ==================================================
:: 8. NÁSTROJE PRO OBNOVU SYSTÉMU
:: ==================================================
:SYSTEM_RECOVERY
cls
echo.
echo %CYAN%==================================================%RESET%
echo %CYAN%          🔧 NÁSTROJE PRO OBNOVU SYSTÉMU%RESET%
echo %CYAN%==================================================%RESET%
echo.
echo %GREEN%[1]%RESET% System Restore Point
echo %GREEN%[2]%RESET% Boot Repair
echo %GREEN%[3]%RESET% Registry Backup
echo %GREEN%[4]%RESET% Zpět do hlavního menu
echo.
set /p rec_choice="%WHITE%Vyberte možnost [1-4]: %RESET%"

if "%rec_choice%"=="" goto SYSTEM_RECOVERY
if "%rec_choice%"=="1" goto SYSTEM_RESTORE_POINT
if "%rec_choice%"=="2" goto BOOT_REPAIR
if "%rec_choice%"=="3" goto REGISTRY_BACKUP
if "%rec_choice%"=="4" goto MAIN_MENU
goto SYSTEM_RECOVERY

:SYSTEM_RESTORE_POINT
cls
echo.
echo %YELLOW%💾 VYTVÁŘENÍ RESTORE POINTU...%RESET%
powershell -Command "Checkpoint-Computer -Description 'SuperNastroj_Backup' -RestorePointType 'MODIFY_SETTINGS'"
if %errorlevel% equ 0 (
    echo %GREEN%✅ Restore point vytvořen%RESET%
) else (
    echo %RED%❌ Chyba při vytváření restore pointu%RESET%
)
call :LOG_INFO "Restore point created"
pause
goto SYSTEM_RECOVERY

:: ==================================================
:: POMOCNÉ FUNKCE
:: ==================================================
:CHECK_ERROR
if %errorlevel% neq 0 (
    echo %RED%❌ Chyba: %~1 (kód: %errorlevel%)%RESET%
    echo [%date% %time%] ERROR: %~1 (code: %errorlevel%) >> "SuperNastroj_Logs\errors.log"
) else (
    echo %GREEN%✅ %~1 úspěšně dokončeno%RESET%
)
goto :eof

:LOG_INFO
echo [%date% %time%] INFO: %~1 >> "SuperNastroj_Logs\system.log"
goto :eof

:CLEAN_TEMP_FILES
del /f /q "%temp%\*" >nul 2>&1
del /f /q "C:\Windows\Temp\*" >nul 2>&1
cleanmgr /sagerun:1 >nul 2>&1
echo %GREEN%✅ Temp soubory vyčištěny%RESET%
goto :eof

:: ==================================================
:: 10. GENEROVAT REPORT
:: ==================================================
:GENERATE_REPORT
cls
echo.
echo %YELLOW%📊 GENERUJI DIAGNOSTICKÝ REPORT...%RESET%
set report_file=SuperNastroj_Logs\report_%date:~6,4%%date:~3,2%%date:~0,2%.txt
(
echo ========================================
echo SUPER NÁSTROJ - DIAGNOSTICKÝ REPORT
echo ========================================
echo Datum: %date% %time%
echo.
echo === SYSTÉM ===
systeminfo
echo.
echo === HARDWARE ===
wmic cpu get name
wmic memorychip get capacity
echo.
echo === DISKY ===
wmic diskdrive get model,size
echo.
echo === SÍŤ ===
ipconfig /all
) > "%report_file%"
echo %GREEN%✅ Report vytvořen: %report_file%%RESET%
pause
goto MAIN_MENU

:: ==================================================
:: KONEC
:: ==================================================
:END
cls
echo.
echo %CYAN%==========================================%RESET%
echo %CYAN%    DĚKUJI ZA POUŽITÍ SUPER NÁSTROJE!%RESET%
echo %CYAN%==========================================%RESET%
echo.
call :LOG_INFO "SuperNástroj řádně ukončen"
timeout /t 3 >nul
endlocal
exit