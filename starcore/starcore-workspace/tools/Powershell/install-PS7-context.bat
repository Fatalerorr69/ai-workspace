@echo off
title Instalátor kontextového menu PowerShell 7
color 0A

echo ================================================
echo   Instalator: Kontextove menu PowerShell 7
echo   Autor: Starko
echo ================================================
echo.

:: Cesta k REG souboru
set REGFILE=Open_PS7_Auto.reg

:: Kontrola existence souboru
if not exist "%~dp0%REGFILE%" (
    echo [CHYBA] Soubor %REGFILE% nebyl nalezen ve stejne slozce!
    echo.
    pause
    exit /b
)

:: Nabidka akci
echo Vyber akci:
echo   [1] Instalovat / aktualizovat polozky (Otevrit v PS7 / WT)
echo   [2] Odinstalovat polozky z kontextoveho menu
echo   [3] Ukoncit
echo.
choice /c 123 /m "Zadej volbu: "
set CH=%errorlevel%

if %CH%==3 exit /b

:: Zaloha registru
echo.
echo Vytvarim zalohu registru...
reg export "HKEY_CLASSES_ROOT\Directory\shell\Powershell7" "%~dp0backup_PS7.reg" /y >nul 2>&1
reg export "HKEY_CLASSES_ROOT\Directory\shell\WTPS7" "%~dp0backup_WTPS7.reg" /y >nul 2>&1
reg export "HKEY_CLASSES_ROOT\Drive\shell\Powershell7" "%~dp0backup_PS7_drive.reg" /y >nul 2>&1
reg export "HKEY_CLASSES_ROOT\Drive\shell\WTPS7" "%~dp0backup_WTPS7_drive.reg" /y >nul 2>&1
echo [OK] Zaloha byla ulozena do aktualni slozky.
echo.

if %CH%==1 (
    echo Importuji %REGFILE%...
    reg import "%~dp0%REGFILE%"
    echo [HOTOVO] Kontextove menu bylo pridano/aktualizovano.
    echo.
    pause
    exit /b
)

if %CH%==2 (
    echo Odstranuji polozky...
    reg delete "HKEY_CLASSES_ROOT\Directory\Background\shell\Powershell7" /f >nul 2>&1
    reg delete "HKEY_CLASSES_ROOT\Directory\Background\shell\WTPS7" /f >nul 2>&1
    reg delete "HKEY_CLASSES_ROOT\Directory\shell\Powershell7" /f >nul 2>&1
    reg delete "HKEY_CLASSES_ROOT\Directory\shell\WTPS7" /f >nul 2>&1
    reg delete "HKEY_CLASSES_ROOT\Drive\shell\Powershell7" /f >nul 2>&1
    reg delete "HKEY_CLASSES_ROOT\Drive\shell\WTPS7" /f >nul 2>&1
    echo [HOTOVO] Kontextove menu bylo odstraneno.
    echo.
    pause
    exit /b
)