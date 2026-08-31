@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -NoExit -File "%~dp0STARCORE_36.20E_TERMUX_AUTOCONNECT.ps1"
endlocal
