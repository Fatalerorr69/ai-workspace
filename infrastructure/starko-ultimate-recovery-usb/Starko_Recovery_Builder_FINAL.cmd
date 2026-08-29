@echo off
title STARKO RECOVERY USB BUILDER - STABILNI VERZE
color 0A

:: ==================================================
::  STARKO RECOVERY USB BUILDER - STABILNI v1.0
:: ==================================================

:: Kontrola admin prav
net session >nul 2>&1
if errorlevel 1 (
    echo [CHYBA] Spustte skript jako spravce!
    pause
    exit /b 1
)

:: Zakladni nastaveni
set "ROOT=%~dp0"
set "USB=L:"
set "WORK=%ROOT%Work"
set "ISO=%ROOT%ISO"

:: Vytvoreni slozek
if not exist "%WORK%" mkdir "%WORK%"
if not exist "%ISO%" mkdir "%ISO%"

:: Hlavni menu
:menu
cls
echo ==================================================
echo      STARKO RECOVERY USB BUILDER
echo ==================================================
echo.
echo [1] Vytvorit kompletni USB
echo [2] Pouzit lokalni soubory
echo [3] Formatovat USB
echo [4] Vytvorit WinPE ISO
echo [5] Test instalace ADK
echo [0] Ukoncit
echo.
set /p volba=Zvolte moznost: 

if "%volba%"=="1" goto volba1
if "%volba%"=="2" goto volba2
if "%volba%"=="3" goto volba3
if "%volba%"=="4" goto volba4
if "%volba%"=="5" goto volba5
if "%volba%"=="0" exit /b 0
goto menu

:: VOLBA 1: Kompletni USB
:volba1
cls
echo ==================================================
echo      KOMPLETNI TVORBA USB
echo ==================================================

:: Kontrola USB
:check_usb
if not exist "%USB%\" (
    echo USB disk %USB% nebyl nalezen!
    echo.
    set /p new_usb=Zadejte pismeno USB disku: 
    set "USB=%new_usb%"
    goto check_usb
)

echo.
echo !!! UPOZORNENI !!!
echo USB disk %USB% bude kompletne smazan!
echo.
set /p confirm=Pokracovat? (A/N): 
if /i not "%confirm%"=="A" goto menu

echo.
echo [1/8] Kontrola ADK souboru...
if not exist "%ROOT%adksetup.exe" (
    echo [CHYBA] adksetup.exe nebyl nalezen!
    echo Stahnete ADK do: %ROOT%
    pause
    goto menu
)

:: Instalace ADK
echo [2/8] Instalace ADK...
if not exist "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat" (
    echo Probiha instalace ADK...
    start /wait "" "%ROOT%adksetup.exe" /quiet /norestart /features OptionId.DeploymentTools
    start /wait "" "%ROOT%adkwinpesetup.exe" /quiet /norestart /features OptionId.WindowsPreinstallationEnvironment
    echo Instalace dokoncena.
) else (
    echo ADK je jiz nainstalovan.
)

:: Kontrola instalace
echo [3/8] Kontrola instalace...
if not exist "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat" (
    echo [CHYBA] ADK nebyl spravne nainstalovan!
    pause
    goto menu
)

:: Vytvoreni WinPE
echo [4/8] Vytvareni WinPE...
call "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat"
copype amd64 "%WORK%\WinPE" 2>nul

if not exist "%WORK%\WinPE\media\sources\boot.wim" (
    echo [CHYBA] Nepodarilo se vytvorit WinPE!
    pause
    goto menu
)

:: Uprava startovaciho souboru
echo [5/8] Priprava startovaciho menu...
echo @echo off > "%WORK%\WinPE\media\Windows\System32\startnet.cmd"
echo wpeinit >> "%WORK%\WinPE\media\Windows\System32\startnet.cmd"
echo cls >> "%WORK%\WinPE\media\Windows\System32\startnet.cmd"
echo echo ======================================== >> "%WORK%\WinPE\media\Windows\System32\startnet.cmd"
echo echo    STARKO RECOVERY ULTIMATE EDITION >> "%WORK%\WinPE\media\Windows\System32\startnet.cmd"
echo echo ======================================== >> "%WORK%\WinPE\media\Windows\System32\startnet.cmd"
echo echo. >> "%WORK%\WinPE\media\Windows\System32\startnet.cmd"
echo echo [1] Oprava bootu Windows >> "%WORK%\WinPE\media\Windows\System32\startnet.cmd"
echo echo [2] Obnova dat >> "%WORK%\WinPE\media\Windows\System32\startnet.cmd"
echo echo [3] Diagnostika hardware >> "%WORK%\WinPE\media\Windows\System32\startnet.cmd"
echo echo [4] Sprava disku >> "%WORK%\WinPE\media\Windows\System32\startnet.cmd"
echo echo [5] Sitove nastroje >> "%WORK%\WinPE\media\Windows\System32\startnet.cmd"
echo echo [0] Ukoncit >> "%WORK%\WinPE\media\Windows\System32\startnet.cmd"
echo echo. >> "%WORK%\WinPE\media\Windows\System32\startnet.cmd"
echo set /p op=Vyber:  >> "%WORK%\WinPE\media\Windows\System32\startnet.cmd"
echo if "%%op%%"=="1" echo Spoustim opravu bootu... >> "%WORK%\WinPE\media\Windows\System32\startnet.cmd"
echo if "%%op%%"=="2" echo Spoustim obnovu dat... >> "%WORK%\WinPE\media\Windows\System32\startnet.cmd"
echo if "%%op%%"=="0" exit >> "%WORK%\WinPE\media\Windows\System32\startnet.cmd"

:: Vytvoreni ISO
echo [6/8] Vytvareni ISO souboru...
oscdimg -m -o -u2 -udfver102 -bootdata:2#p0,e,b"%WORK%\WinPE\fwfiles\etfsboot.com"#pEF,e,b"%WORK%\WinPE\fwfiles\efisys.bin" "%WORK%\WinPE\media" "%ISO%\WinPE_Starko.iso"

:: Formatovani USB
echo [7/8] Formatovani USB...
echo select volume %USB% > "%TEMP%\format.txt"
echo clean >> "%TEMP%\format.txt"
echo create partition primary >> "%TEMP%\format.txt"
echo format fs=ntfs quick label="STARKO_RECOVERY" >> "%TEMP%\format.txt"
echo assign letter=%USB% >> "%TEMP%\format.txt"
echo exit >> "%TEMP%\format.txt"

diskpart /s "%TEMP%\format.txt" >nul
del "%TEMP%\format.txt" 2>nul

:: Kopirovani na USB
echo [8/8] Kopirovani na USB...
if not exist "%USB%\ISO" mkdir "%USB%\ISO"
copy "%ISO%\WinPE_Starko.iso" "%USB%\ISO\" >nul

echo.
echo ==================================================
echo      HOTOVO! USB JE PRIPRAVENO
echo ==================================================
echo.
echo USB disk: %USB%
echo Obsahuje: WinPE s diagnostickymi nastroji
echo.
pause
goto menu

:: VOLBA 2: Lokalni soubory
:volba2
cls
echo ==================================================
echo      POUZITI LOKALNICH SOUBORU
echo ==================================================

echo Kontroluji soubory v %ROOT%...
echo.
dir "%ROOT%adk*.exe" /b
echo.
echo Pokud vidite soubory adksetup.exe a adkwinpesetup.exe,
echo pak muzete pokracovat s volbou 1.
echo.
pause
goto menu

:: VOLBA 3: Formatovat USB
:volba3
cls
echo ==================================================
echo      FORMATOVANI USB
echo ==================================================

set /p format_usb=Zadejte pismeno USB disku: 
if "%format_usb%"=="" set "format_usb=%USB%"

echo.
echo !!! VAROVANI !!!
echo Disk %format_usb% bude kompletne smazan!
echo.
set /p format_confirm=Opravdu formatovat? (A/N): 
if /i not "%format_confirm%"=="A" goto menu

echo select volume %format_usb% > "%TEMP%\format2.txt"
echo clean >> "%TEMP%\format2.txt"
echo create partition primary >> "%TEMP%\format2.txt"
echo format fs=ntfs quick label="STARKO_USB" >> "%TEMP%\format2.txt"
echo assign letter=%format_usb% >> "%TEMP%\format2.txt"
echo exit >> "%TEMP%\format2.txt"

diskpart /s "%TEMP%\format2.txt" >nul
del "%TEMP%\format2.txt" 2>nul

echo.
echo USB disk %format_usb% byl uspesne naformatovan.
pause
goto menu

:: VOLBA 4: Vytvorit ISO
:volba4
cls
echo ==================================================
echo      TVORBA ISO SOUBORU
echo ==================================================

if not exist "%WORK%\WinPE\media\sources\boot.wim" (
    echo Nejprve vytvorte WinPE (volba 1).
    pause
    goto menu
)

echo Vytvarim ISO soubor...
oscdimg -m -o -u2 -udfver102 -bootdata:2#p0,e,b"%WORK%\WinPE\fwfiles\etfsboot.com"#pEF,e,b"%WORK%\WinPE\fwfiles\efisys.bin" "%WORK%\WinPE\media" "%ISO%\Starko_Recovery.iso"

echo.
echo ISO vytvoreno: %ISO%\Starko_Recovery.iso
pause
goto menu

:: VOLBA 5: Test ADK
:volba5
cls
echo ==================================================
echo      TEST INSTALACE ADK
echo ==================================================

echo Kontroluji instalaci ADK...
echo.

if exist "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat" (
    echo [OK] ADK je nainstalovan.
    echo.
    echo Spoustim test WinPE...
    call "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat"
    copype amd64 "%WORK%\TestWinPE" 2>nul
    
    if exist "%WORK%\TestWinPE\media\sources\boot.wim" (
        echo [OK] WinPE lze vytvorit.
    ) else (
        echo [CHYBA] Problem s vytvorenim WinPE.
    )
) else (
    echo [CHYBA] ADK neni nainstalovan.
    echo.
    echo Postup instalace:
    echo 1. Stahnete ADK z Microsoft
    echo 2. Spustte adksetup.exe
    echo 3. Vyberte "Deployment Tools"
    echo 4. Spustte adkwinpesetup.exe
    echo 5. Vyberte "Windows Preinstallation Environment"
)

echo.
pause
goto menu

:: Konec
exit /b 0