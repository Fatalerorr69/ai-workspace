@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title SUPER NÁSTROJ v5.0 - Universal Launcher

:: ==================================================
:: DETEKCE PLATFORMY A SPUŠTĚNÍ
:: ==================================================
cls
echo.
echo =========================================
echo   🚀 SUPER NÁSTROJ v5.0 - LAUNCHER
echo =========================================
echo.
echo 🔍 Detekuji platformu...
echo.

:: Detekce Windows
ver >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Platforma: Windows
    echo 🚀 Spouštím Windows verzi...
    echo.
    
    :: Kontrola existence souboru
    if exist "%~dp0SuperNastroj_Complete.bat" (
        timeout /t 2 >nul
        call "%~dp0SuperNastroj_Complete.bat"
    ) else (
        echo ❌ Soubor SuperNastroj_Complete.bat nebyl nalezen!
        echo 📁 Hledám v: %~dp0
        echo.
        dir /b "%~dp0*.bat"
        echo.
        pause
    )
) else (
    echo ℹ️  Toto není Windows prostředí
    echo 💡 Pro Linux/macOS použijte: chmod +x *.sh ^&^& sudo ./SuperNastroj_launcher.sh
    echo 💡 Pro Android použijte: chmod +x SuperNastroj_android.sh ^&^& ./SuperNastroj_android.sh
    pause
)

endlocal
