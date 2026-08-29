@echo off
:: ═══════════════════════════════════════════════════════════════
:: SUPERNASTROJ v5.0 - HLAVNÍ SPOUŠTĚČ
:: Tento soubor spustí hlavní program
:: ═══════════════════════════════════════════════════════════════

setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1

:: Získat cestu ke skriptu
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

:: Spustit hlavní program
if exist "SuperNastroj_Main.bat" (
    call "SuperNastroj_Main.bat"
) else if exist "SuperNastroj_Complete.bat" (
    call "SuperNastroj_Complete.bat"
) else (
    cls
    color 0C
    echo.
    echo ═══════════════════════════════════════════════════════════════
    echo   ❌ CHYBA: Hlavní program nenalezen!
    echo ═══════════════════════════════════════════════════════════════
    echo.
    echo 📁 Hledám v: %CD%
    echo.
    echo 💡 Ujistěte se, že máte soubor:
    echo    - SuperNastroj_Main.bat
    echo    NEBO
    echo    - SuperNastroj_Complete.bat
    echo.
    pause
    exit /b 1
)

endlocal
exit /b 0
