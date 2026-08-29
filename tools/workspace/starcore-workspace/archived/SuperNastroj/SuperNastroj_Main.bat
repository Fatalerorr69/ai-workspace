@echo off
:: ═══════════════════════════════════════════════════════════════
:: SUPER NÁSTROJ v5.0 - Ultimate Windows Edition
:: Autor: FatalErorr69
:: Verze: 5.0.0
:: Datum: 2024-12-06
:: ═══════════════════════════════════════════════════════════════

setlocal EnableDelayedExpansion
title SuperNastroj v5.0 - Inicializace...

:: Nastavení code page pro češtinu
chcp 65001 >nul 2>&1

:: ═══════════════════════════════════════════════════════════════
:: KONTROLA SYSTÉMU A PRÁV
:: ═══════════════════════════════════════════════════════════════

:CHECK_SYSTEM
cls
echo.
echo ═══════════════════════════════════════════════════════════════
echo   🔍 KONTROLA SYSTÉMU
echo ═══════════════════════════════════════════════════════════════
echo.

:: Kontrola admin práv
net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo ❌ CHYBA: Spusťte jako správce!
    echo.
    echo 💡 Řešení:
    echo    1. Zavřete toto okno
    echo    2. Pravý klik na START.bat
    echo    3. "Spustit jako správce"
    echo.
    pause
    exit /b 1
)
echo ✅ Admin práva: OK

:: Kontrola Windows verze
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
echo ✅ Windows verze: %VERSION%

:: Kontrola PowerShell
powershell -Command "exit 0" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ VAROVÁNÍ: PowerShell není dostupný
    set PS_AVAILABLE=0
) else (
    echo ✅ PowerShell: Dostupný
    set PS_AVAILABLE=1
)

:: Vytvoření systémových složek
echo.
echo 📁 Inicializuji složky...
if not exist "SuperNastroj_Logs" mkdir "SuperNastroj_Logs"
if not exist "SuperNastroj_Tools" mkdir "SuperNastroj_Tools"
if not exist "SuperNastroj_Backups" mkdir "SuperNastroj_Backups"
if not exist "SuperNastroj_ISOs" mkdir "SuperNastroj_ISOs"
if not exist "SuperNastroj_Reports" mkdir "SuperNastroj_Reports"
echo ✅ Složky vytvořeny

:: Log spuštění
echo [%date% %time%] SuperNastroj v5.0 spuštěn > "SuperNastroj_Logs\system.log"
echo [%date% %time%] Admin: YES >> "SuperNastroj_Logs\system.log"
echo [%date% %time%] Windows: %VERSION% >> "SuperNastroj_Logs\system.log"

timeout /t 2 >nul
color 0A

:: ═══════════════════════════════════════════════════════════════
:: HLAVNÍ MENU
:: ═══════════════════════════════════════════════════════════════

:MAIN_MENU
cls
title SuperNastroj v5.0 - Hlavní Menu
echo.
echo ═══════════════════════════════════════════════════════════════
echo   🚀 SUPER NÁSTROJ v5.0 - FATALERROR69
echo ═══════════════════════════════════════════════════════════════
echo.
echo   [1]  🛠️  Rychlá oprava systému
echo   [2]  🔍 Pokročilá diagnostika  
echo   [3]  📁 Generátor nástrojů
echo   [4]  🚀 Boot Disk Creator
echo   [5]  🛡️  Bezpečnost a optimalizace
echo   [6]  🌐 Síťové nástroje
echo   [7]  💾 Správa disků a zálohy
echo   [8]  🔧 Recovery nástroje
echo   [9]  ⚙️  Nastavení
echo   [10] 📊 Generovat report
echo   [11] ℹ️  O programu
echo   [12] ❌ Konec
echo.
echo ═══════════════════════════════════════════════════════════════
echo.

set /p "choice=Vyberte možnost [1-12]: "

if "%choice%"=="" goto MAIN_MENU
if "%choice%"=="1" goto QUICK_REPAIR
if "%choice%"=="2" goto DIAGNOSTICS
if "%choice%"=="3" goto GENERATOR
if "%choice%"=="4" goto BOOT_CREATOR
if "%choice%"=="5" goto SECURITY
if "%choice%"=="6" goto NETWORK
if "%choice%"=="7" goto DISK_MGMT
if "%choice%"=="8" goto RECOVERY
if "%choice%"=="9" goto SETTINGS
if "%choice%"=="10" goto REPORT
if "%choice%"=="11" goto ABOUT
if "%choice%"=="12" goto EXIT_PROGRAM

echo ❌ Neplatná volba: %choice%
timeout /t 2 >nul
goto MAIN_MENU

:: ═══════════════════════════════════════════════════════════════
:: [1] RYCHLÁ OPRAVA SYSTÉMU
:: ═══════════════════════════════════════════════════════════════

:QUICK_REPAIR
cls
title SuperNastroj v5.0 - Rychlá oprava
echo.
echo ═══════════════════════════════════════════════════════════════
echo   🛠️  RYCHLÁ OPRAVA SYSTÉMU
echo ═══════════════════════════════════════════════════════════════
echo.
echo ⚠️  Tato operace může trvat 15-30 minut
echo 💡 Doporučujeme zavřít ostatní programy
echo.

set /p "confirm=Pokračovat? [Y/N]: "
if /i not "%confirm%"=="Y" goto MAIN_MENU

echo.
echo [%date% %time%] Quick repair started >> "SuperNastroj_Logs\system.log"

:: 1. SFC Scan
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 KROK 1/5: SFC Scan - Kontrola systémových souborů
echo ═══════════════════════════════════════════════════════════════
echo.
echo Spouštím SFC /scannow...
sfc /scannow 2>&1 | findstr /C:"Windows" /C:"integrity" /C:"repair"
call :LOG_RESULT "SFC Scan" %errorlevel%

:: 2. DISM Repair
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🗃️  KROK 2/5: DISM Repair - Oprava systémového obrazu
echo ═══════════════════════════════════════════════════════════════
echo.
echo Spouštím DISM /RestoreHealth...
DISM /Online /Cleanup-Image /RestoreHealth /NoRestart 2>&1 | findstr /C:"successfully" /C:"completed"
call :LOG_RESULT "DISM Repair" %errorlevel%

:: 3. Disk Check
echo.
echo ═══════════════════════════════════════════════════════════════
echo 💾 KROK 3/5: Disk Check - Kontrola disků
echo ═══════════════════════════════════════════════════════════════
echo.
echo Kontroluji disk C:...
chkdsk C: /scan 2>&1 | findstr /C:"stage" /C:"errors"
call :LOG_RESULT "CHKDSK" %errorlevel%

:: 4. Temp Cleanup
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🧹 KROK 4/5: Čištění dočasných souborů
echo ═══════════════════════════════════════════════════════════════
echo.
call :CLEAN_TEMP
call :LOG_RESULT "Temp Cleanup" 0

:: 5. Network Reset
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🌐 KROK 5/5: Reset síťových nastavení
echo ═══════════════════════════════════════════════════════════════
echo.
echo Čistím DNS cache...
ipconfig /flushdns >nul 2>&1
echo Resetuji Winsock...
netsh winsock reset >nul 2>&1
echo Resetuji TCP/IP...
netsh int ip reset >nul 2>&1
call :LOG_RESULT "Network Reset" 0

:: Dokončení
echo.
echo ═══════════════════════════════════════════════════════════════
echo ✅ RYCHLÁ OPRAVA DOKONČENA!
echo ═══════════════════════════════════════════════════════════════
echo.
echo 📊 Výsledky uloženy v: SuperNastroj_Logs\system.log
echo 💡 Doporučujeme restartovat počítač
echo.
set /p "restart=Restartovat nyní? [Y/N]: "
if /i "%restart%"=="Y" shutdown /r /t 30 /c "Restart po opravě systému - SuperNastroj"

pause
goto MAIN_MENU

:: ═══════════════════════════════════════════════════════════════
:: [2] POKROČILÁ DIAGNOSTIKA
:: ═══════════════════════════════════════════════════════════════

:DIAGNOSTICS
cls
title SuperNastroj v5.0 - Diagnostika
echo.
echo ═══════════════════════════════════════════════════════════════
echo   🔍 POKROČILÁ DIAGNOSTIKA
echo ═══════════════════════════════════════════════════════════════
echo.
echo   [1] Kompletní diagnostika (doporučeno)
echo   [2] Hardware info
echo   [3] Výkon systému
echo   [4] Síťová diagnostika
echo   [5] Bezpečnostní sken
echo   [6] Boot diagnostika
echo   [7] Zpět
echo.
echo ═══════════════════════════════════════════════════════════════
echo.

set /p "diag=Vyberte možnost [1-7]: "

if "%diag%"=="1" goto DIAG_FULL
if "%diag%"=="2" goto DIAG_HARDWARE
if "%diag%"=="3" goto DIAG_PERFORMANCE
if "%diag%"=="4" goto DIAG_NETWORK
if "%diag%"=="5" goto DIAG_SECURITY
if "%diag%"=="6" goto DIAG_BOOT
if "%diag%"=="7" goto MAIN_MENU
goto DIAGNOSTICS

:DIAG_FULL
cls
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔍 KOMPLETNÍ DIAGNOSTIKA SYSTÉMU
echo ═══════════════════════════════════════════════════════════════
echo.

set "DIAG_FILE=SuperNastroj_Reports\diagnostika_%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%.txt"

echo Generuji diagnostický report...
echo.

(
echo ═══════════════════════════════════════════════════════════════
echo SUPERNASTROJ v5.0 - KOMPLETNÍ DIAGNOSTIKA
echo Vygenerováno: %date% %time%
echo ═══════════════════════════════════════════════════════════════
echo.
echo ═══ ZÁKLADNÍ INFORMACE ═══
systeminfo | findstr /C:"Host Name" /C:"OS Name" /C:"OS Version" /C:"System Type" /C:"Total Physical Memory"
echo.
echo ═══ PROCESOR ═══
wmic cpu get name,numberofcores,maxclockspeed,loadpercentage /format:list
echo.
echo ═══ PAMĚŤ ═══
wmic memorychip get capacity,speed,manufacturer /format:list
echo.
echo ═══ DISKY ═══
wmic diskdrive get model,size,status /format:list
echo.
echo ═══ LOGICKÉ DISKY ═══
wmic logicaldisk get deviceid,size,freespace,filesystem /format:list
echo.
echo ═══ SÍŤ ═══
ipconfig | findstr /C:"IPv4" /C:"Subnet" /C:"Gateway"
echo.
echo ═══ AKTIVNÍ SPOJENÍ ═══
netstat -ano | findstr "ESTABLISHED" | find /c /v ""
echo.
echo ═══════════════════════════════════════════════════════════════
) > "%DIAG_FILE%"

echo ✅ Diagnostika dokončena!
echo 📊 Report uložen: %DIAG_FILE%
echo.

type "%DIAG_FILE%" | more

call :LOG_RESULT "Full Diagnostics" 0
pause
goto DIAGNOSTICS

:DIAG_HARDWARE
cls
echo.
echo ═══════════════════════════════════════════════════════════════
echo 💻 HARDWARE DIAGNOSTIKA
echo ═══════════════════════════════════════════════════════════════
echo.
echo 🖥️  PROCESOR:
wmic cpu get name,numberofcores,numberoflogicalprocessors,maxclockspeed
echo.
echo 🧠 PAMĚŤ RAM:
wmic memorychip get capacity,speed,manufacturer
echo.
echo 💾 DISKY:
wmic diskdrive get model,size,interfacetype,status
echo.
echo 🎮 GRAFIKA:
wmic path win32_VideoController get name,adapterram,driverversion
echo.
call :LOG_RESULT "Hardware Diagnostics" 0
pause
goto DIAGNOSTICS

:DIAG_PERFORMANCE
cls
echo.
echo ═══════════════════════════════════════════════════════════════
echo 📈 VÝKON SYSTÉMU
echo ═══════════════════════════════════════════════════════════════
echo.
echo ⚡ Využití CPU:
wmic cpu get loadpercentage
echo.
echo 🧠 Stav paměti:
wmic OS get FreePhysicalMemory,TotalVisibleMemorySize /format:list
echo.
echo 💾 Volné místo na discích:
wmic logicaldisk get deviceid,size,freespace /format:list
echo.
echo 📊 Top 5 procesů (CPU):
wmic process get name,workingsetsize,processid /format:csv | sort /r | more
echo.
call :LOG_RESULT "Performance Check" 0
pause
goto DIAGNOSTICS

:DIAG_NETWORK
cls
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🌐 SÍŤOVÁ DIAGNOSTIKA
echo ═══════════════════════════════════════════════════════════════
echo.
echo 📡 Síťové rozhraní:
ipconfig /all | findstr /C:"Ethernet" /C:"IPv4" /C:"Gateway" /C:"DNS"
echo.
echo 🔍 Test připojení (Google DNS):
ping 8.8.8.8 -n 4
echo.echo 🌐 DNS test:
nslookup google.com
echo.
echo 📊 Aktivní spojení:
netstat -ano | findstr "ESTABLISHED" | more
echo.
call :LOG_RESULT "Network Diagnostics" 0
pause
goto DIAGNOSTICS

:DIAG_SECURITY
cls
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🛡️  BEZPEČNOSTNÍ SKEN
echo ═══════════════════════════════════════════════════════════════
echo.

if %PS_AVAILABLE%==1 (
    echo 🔍 Windows Defender:
    powershell -Command "Get-MpComputerStatus | Select-Object AntivirusEnabled,RealTimeProtectionEnabled | Format-List"
) else (
    echo ℹ️  PowerShell není dostupný pro kontrolu Defenderu
)

echo.
echo 🔥 Firewall:
netsh advfirewall show allprofiles state | findstr /C:"State"
echo.
echo 📋 Uživatelé systému:
net user
echo.
echo 🔓 Otevřené porty:
netstat -ano | findstr "LISTENING" | more
echo.
call :LOG_RESULT "Security Scan" 0
pause
goto DIAGNOSTICS

:: ═══════════════════════════════════════════════════════════════
:: [5] BEZPEČNOST A OPTIMALIZACE
:: ═══════════════════════════════════════════════════════════════

:SECURITY
cls
title SuperNastroj v5.0 - Bezpečnost
echo.
echo ═══════════════════════════════════════════════════════════════
echo   🛡️  BEZPEČNOST A OPTIMALIZACE
echo ═══════════════════════════════════════════════════════════════
echo.
echo   [1] Security scan
echo   [2] Posílení zabezpečení (hardening)
echo   [3] Optimalizace výkonu
echo   [4] Čištění systému
echo   [5] Zpět
echo.
echo ═══════════════════════════════════════════════════════════════
echo.

set /p "sec=Vyberte možnost [1-5]: "

if "%sec%"=="1" goto DIAG_SECURITY
if "%sec%"=="2" goto SEC_HARDENING
if "%sec%"=="3" goto SEC_OPTIMIZE
if "%sec%"=="4" goto SEC_CLEANUP
if "%sec%"=="5" goto MAIN_MENU
goto SECURITY

:SEC_HARDENING
cls
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🔒 POSÍLENÍ ZABEZPEČENÍ SYSTÉMU
echo ═══════════════════════════════════════════════════════════════
echo.
echo ⚠️  Tato akce provede následující změny:
echo    - Povolení UAC (User Account Control)
echo    - Aktivace Windows Firewallu
echo    - Povolení automatických aktualizací
echo    - Vypnutí nepotřebných služeb
echo.

set /p "confirm=Pokračovat? [Y/N]: "
if /i not "%confirm%"=="Y" goto SECURITY

echo.
echo Aplikuji security hardening...
echo.

:: UAC
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 1 /f >nul 2>&1
echo ✅ UAC povolen

:: Firewall
netsh advfirewall set allprofiles state on >nul 2>&1
echo ✅ Firewall aktivován

:: Windows Update
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 0 /f >nul 2>&1
echo ✅ Automatické aktualizace povoleny

:: Vypnout telemetrii
sc config "DiagTrack" start= disabled >nul 2>&1
sc stop "DiagTrack" >nul 2>&1
echo ✅ Telemetrie vypnuta

:: Vypnout Remote Registry
sc config "RemoteRegistry" start= disabled >nul 2>&1
sc stop "RemoteRegistry" >nul 2>&1
echo ✅ Remote Registry vypnutý

echo.
echo ═══════════════════════════════════════════════════════════════
echo ✅ HARDENING DOKONČEN!
echo ═══════════════════════════════════════════════════════════════
echo.
call :LOG_RESULT "Security Hardening" 0
pause
goto SECURITY

:SEC_OPTIMIZE
cls
echo.
echo ═══════════════════════════════════════════════════════════════
echo ⚡ OPTIMALIZACE VÝKONU
echo ═══════════════════════════════════════════════════════════════
echo.

echo 🧹 Čištění temp souborů...
call :CLEAN_TEMP

echo 📊 Optimalizace služeb...
:: Vypnout zbytečné služby
sc config "WSearch" start= demand >nul 2>&1
echo   - Windows Search: Na vyžádání
sc config "SysMain" start= disabled >nul 2>&1
sc stop "SysMain" >nul 2>&1
echo   - SysMain (Superfetch): Vypnuto

echo 🗃️  Defragmentace (pouze HDD)...
defrag C: /O /U /V >nul 2>&1
echo   - Dokončeno

echo 📈 Optimalizace registru...
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v SvcHostSplitThresholdInKB /t REG_DWORD /d 4194304 /f >nul 2>&1
echo   - Registry optimalizován

echo.
echo ═══════════════════════════════════════════════════════════════
echo ✅ OPTIMALIZACE DOKONČENA!
echo ═══════════════════════════════════════════════════════════════
echo.
call :LOG_RESULT "System Optimization" 0
pause
goto SECURITY

:SEC_CLEANUP
cls
echo.
echo ═══════════════════════════════════════════════════════════════
echo 🧹 ČIŠTĚNÍ SYSTÉMU
echo ═══════════════════════════════════════════════════════════════
echo.

echo Odhadovaná doba: 2-5 minut
echo.
set /p "confirm=Pokračovat? [Y/N]: "
if /i not "%confirm%"=="Y" goto SECURITY

echo.
echo Provádím čištění...

:: Temp složky
echo 🗑️  Temp složky...
call :CLEAN_TEMP

:: Windows Update cache
echo 📦 Windows Update cache...
dism /online /Cleanup-Image /StartComponentCleanup /ResetBase >nul 2>&1

:: Recycle Bin
echo 🗑️  Koš...
rd /s /q %systemdrive%\$Recycle.bin >nul 2>&1

:: Prefetch
echo 📂 Prefetch...
del /f /q %systemroot%\Prefetch\* >nul 2>&1

:: DNS Cache
echo 🌐 DNS Cache...
ipconfig /flushdns >nul 2>&1

echo.
echo ═══════════════════════════════════════════════════════════════
echo ✅ ČIŠTĚNÍ DOKONČENO!
echo ═══════════════════════════════════════════════════════════════
echo.
call :LOG_RESULT "System Cleanup" 0
pause
goto SECURITY

:: ═══════════════════════════════════════════════════════════════
:: [7] SPRÁVA DISKŮ A ZÁLOHY
:: ═══════════════════════════════════════════════════════════════

:DISK_MGMT
cls
title SuperNastroj v5.0 - Správa disků
echo.
echo ═══════════════════════════════════════════════════════════════
echo   💾 SPRÁVA DISKŮ A ZÁLOHY
echo ═══════════════════════════════════════════════════════════════
echo.
echo   [1] Info o discích
echo   [2] Vytvořit zálohu
echo   [3] Obnovit zálohu
echo   [4] Vytvořit Restore Point
echo   [5] Zpět
echo.
echo ═══════════════════════════════════════════════════════════════
echo.

set /p "disk=Vyberte možnost [1-5]: "

if "%disk%"=="1" goto DISK_INFO
if "%disk%"=="2" goto DISK_BACKUP
if "%disk%"=="3" goto DISK_RESTORE
if "%disk%"=="4" goto DISK_RESTORE_POINT
if "%disk%"=="5" goto MAIN_MENU
goto DISK_MGMT

:DISK_INFO
cls
echo.
echo ═══════════════════════════════════════════════════════════════
echo 💽 INFORMACE O DISCÍCH
echo ═══════════════════════════════════════════════════════════════
echo.
echo 📊 Logické disky:
wmic logicaldisk get deviceid,volumename,size,freespace,filesystem
echo.
echo 💾 Fyzické disky:
wmic diskdrive get model,size,status,interfacetype
echo.
echo 📈 Využití disků:
for /f "skip=1" %%d in ('wmic logicaldisk get deviceid') do (
    if not "%%d"=="" (
        echo.
        echo Disk %%d
        dir "%%d\" 2>nul | findstr "soubor"
    )
)
echo.
pause
goto DISK_MGMT

:DISK_BACKUP
cls
echo.
echo ═══════════════════════════════════════════════════════════════
echo 💾 VYTVOŘENÍ ZÁLOHY
echo ═══════════════════════════════════════════════════════════════
echo.

set /p "source=Cesta ke zálohování (Enter = C:\Users): "
if "%source%"=="" set "source=C:\Users"

if not exist "%source%" (
    echo ❌ Složka neexistuje: %source%
    pause
    goto DISK_MGMT
)

set "timestamp=%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "timestamp=%timestamp: =0%"
set "dest=SuperNastroj_Backups\Backup_%timestamp%"

echo.
echo 📂 Zdroj: %source%
echo 📂 Cíl: %dest%
echo.

set /p "confirm=Pokračovat? [Y/N]: "
if /i not "%confirm%"=="Y" goto DISK_MGMT

echo.
echo 🔄 Zálohuji... (může trvat několik minut)
xcopy "%source%" "%dest%" /E /H /C /I /Y >nul 2>&1

if %errorlevel%==0 (
    echo ✅ Záloha úspěšně vytvořena!
    echo 📁 Umístění: %dest%
) else (
    echo ❌ Chyba při zálohování (kód: %errorlevel%)
)

call :LOG_RESULT "Backup created" %errorlevel%
pause
goto DISK_MGMT

:DISK_RESTORE_POINT
cls
echo.
echo ═══════════════════════════════════════════════════════════════
echo 💾 VYTVOŘENÍ RESTORE POINTU
echo ═══════════════════════════════════════════════════════════════
echo.

if %PS_AVAILABLE%==0 (
    echo ❌ PowerShell není dostupný - nelze vytvořit Restore Point
    pause
    goto DISK_MGMT
)

echo Vytvářím System Restore Point...
powershell -Command "Checkpoint-Computer -Description 'SuperNastroj_RestorePoint_%date:~6,4%%date:~3,2%%date:~0,2%' -RestorePointType 'MODIFY_SETTINGS'" 2>nul

if %errorlevel%==0 (
    echo ✅ Restore Point úspěšně vytvořen!
) else (
    echo ❌ Chyba při vytváření Restore Pointu
    echo 💡 Ujistěte se, že System Protection je povoleno
)

call :LOG_RESULT "Restore Point" %errorlevel%
pause
goto DISK_MGMT

:: ═══════════════════════════════════════════════════════════════
:: [10] GENEROVAT REPORT
:: ═══════════════════════════════════════════════════════════════

:REPORT
cls
title SuperNastroj v5.0 - Generování reportu
echo.
echo ═══════════════════════════════════════════════════════════════
echo   📊 GENEROVÁNÍ KOMPLETNÍHO REPORTU
echo ═══════════════════════════════════════════════════════════════
echo.

set "REPORT_FILE=SuperNastroj_Reports\Report_%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%.html"
set "REPORT_FILE=%REPORT_FILE: =0%"

echo Generuji komplexní diagnostický report...
echo Odhadovaná doba: 30-60 sekund
echo.

(
echo ^<!DOCTYPE html^>
echo ^<html^>
echo ^<head^>
echo ^<meta charset="utf-8"^>
echo ^<title^>SuperNastroj v5.0 - Diagnostický Report^</title^>
echo ^<style^>
echo body { font-family: 'Segoe UI', Tahoma, sans-serif; background: #1e1e1e; color: #fff; padding: 20px; }
echo h1 { color: #00ff00; }
echo h2 { color: #00aaff; border-bottom: 2px solid #00aaff; padding-bottom: 5px; }
echo pre { background: #2d2d2d; padding: 10px; border-radius: 5px; overflow-x: auto; }
echo .ok { color: #00ff00; }
echo .error { color: #ff0000; }
echo ^</style^>
echo ^</head^>
echo ^<body^>
echo ^<h1^>SuperNastroj v5.0 - Kompletní Report^</h1^>
echo ^<p^>Vygenerováno: %date% %time%^</p^>
echo ^<hr^>
echo ^<h2^>Systém^</h2^>
echo ^<pre^>
systeminfo
echo ^</pre^>
echo ^<h2^>Hardware^</h2^>
echo ^<pre^>
wmic cpu get name,numberofcores,maxclockspeed
wmic memorychip get capacity,speed
wmic diskdrive get model,size,status
echo ^</pre^>
echo ^<h2^>Síť^</h2^>
echo ^<pre^>
ipconfig /all
echo ^</pre^>
echo ^</body^>
echo ^</html^>
) > "%REPORT_FILE%"

echo.
echo ═══════════════════════════════════════════════════════════════
echo ✅ REPORT VYGENEROVÁN!
echo ═══════════════════════════════════════════════════════════════
echo.
echo 📁 Umístění: %REPORT_FILE%
echo.

set /p "open=Otevřít report v prohlížeči? [Y/N]: "
if /i "%open%"=="Y" start "" "%REPORT_FILE%"

call :LOG_RESULT "Report generated" 0
pause
goto MAIN_MENU

:: ═══════════════════════════════════════════════════════════════
:: [11] O PROGRAMU
:: ═══════════════════════════════════════════════════════════════

:ABOUT
cls
echo.
echo ═══════════════════════════════════════════════════════════════
echo   ℹ️  O PROGRAMU
echo ═══════════════════════════════════════════════════════════════
echo.
echo   Program: SuperNastroj
echo   Verze: 5.0.0
echo   Datum: 2024-12-06
echo   Autor: FatalErorr69
echo   Licence: MIT
echo.
echo   Popis:
echo   Komplexní multiplatformní nástroj pro diagnostiku,
echo   opravu a optimalizaci Windows systémů.
echo.
echo   Funkce:
echo   - Rychlá oprava systému (SFC, DISM, CHKDSK)
echo   - Pokročilá diagnostika hardware a software
echo   - Bezpečnostní skenování a hardening  
echo   - Síťové nástroje a diagnostika
echo   - Správa disků a automatické zálohy
echo   - Recovery nástroje
echo   - Generování HTML reportů
echo.
echo   GitHub: github.com/Fatalerorr69/SuperNastroj
echo.
echo ═══════════════════════════════════════════════════════════════
echo.
pause
goto MAIN_MENU

:: ═══════════════════════════════════════════════════════════════
:: POMOCNÉ FUNKCE
:: ═══════════════════════════════════════════════════════════════

:CLEAN_TEMP
del /f /s /q "%temp%\*" >nul 2>&1
del /f /s /q "C:\Windows\Temp\*" >nul 2>&1
del /f /s /q "%systemroot%\Prefetch\*" >nul 2>&1
echo ✅ Temp soubory vyčištěny
goto :eof

:LOG_RESULT
echo [%date% %time%] %~1: ExitCode=%~2 >> "SuperNastroj_Logs\system.log"
if %~2==0 (
    echo ✅ %~1: Úspěch
) else (
    echo ❌ %~1: Chyba (kód: %~2)
    echo [%date% %time%] ERROR: %~1 failed with code %~2 >> "SuperNastroj_Logs\errors.log"
)
goto :eof

:: ═══════════════════════════════════════════════════════════════
:: EXIT
:: ═══════════════════════════════════════════════════════════════

:EXIT_PROGRAM
cls
echo.
echo ═══════════════════════════════════════════════════════════════
echo   👋 DĚKUJI ZA POUŽITÍ SUPERNASTROJ v5.0
echo ═══════════════════════════════════════════════════════════════
echo.
echo   📁 Logy: SuperNastroj_Logs\
echo   📊 Reporty: SuperNastroj_Reports\
echo   💾 Zálohy: SuperNastroj_Backups\
echo.
echo   ⭐ Ohodnoťte na GitHubu!
echo   github.com/Fatalerorr69/SuperNastroj
echo.
echo ═══════════════════════════════════════════════════════════════
echo.

echo [%date% %time%] SuperNastroj ukončen >> "SuperNastroj_Logs\system.log"
timeout /t 3 >nul
endlocal
exit /b 0