@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title SuperNastroj v5.0 - INSTALÁTOR

:: ==================================================
:: INSTALÁTOR SUPERNASTROJ v5.0
:: ==================================================
cls
color 0A
echo.
echo ╔════════════════════════════════════════════╗
echo ║   🚀 SUPERNASTROJ v5.0 - INSTALÁTOR       ║
echo ║        FatalErorr69 Edition               ║
echo ╚════════════════════════════════════════════╝
echo.

:: Kontrola admin práv
net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo ❌ VYŽADOVÁNA ADMINISTRÁTORSKÁ PRÁVA!
    echo.
    echo Pravý klik na tento soubor → "Spustit jako správce"
    echo.
    pause
    exit /b 1
)

echo ✅ Administrátorská práva: OK
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo  INSTALACE
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

:: Vytvoření složek
echo 📁 Vytvářím systémové složky...
if not exist "SuperNastroj_Logs" mkdir "SuperNastroj_Logs"
if not exist "SuperNastroj_Tools" mkdir "SuperNastroj_Tools"
if not exist "SuperNastroj_Backups" mkdir "SuperNastroj_Backups"
if not exist "SuperNastroj_ISOs" mkdir "SuperNastroj_ISOs"
if not exist "docs" mkdir "docs"
if not exist "tools" mkdir "tools"
if not exist "examples" mkdir "examples"
echo ✅ Složky vytvořeny
echo.

:: Kontrola souborů
echo 🔍 Kontroluji soubory...
set missing=0
if not exist "SuperNastroj_Complete.bat" (
    echo ❌ Chybí: SuperNastroj_Complete.bat
    set /a missing+=1
)
if not exist "SuperNastroj_Launcher.bat" (
    echo ❌ Chybí: SuperNastroj_Launcher.bat
    set /a missing+=1
)
if not exist "README.md" (
    echo ⚠️  Chybí: README.md
)

if %missing% gtr 0 (
    echo.
    echo ❌ Chybí některé důležité soubory!
    echo 💡 Stáhněte kompletní balíček z GitHubu
    pause
    exit /b 1
)
echo ✅ Všechny soubory v pořádku
echo.

:: Vytvoření zástupců
echo 🔗 Vytvářím zástupce...
echo Set oWS = WScript.CreateObject("WScript.Shell") > CreateShortcut.vbs
echo sLinkFile = "%USERPROFILE%\Desktop\SuperNastroj.lnk" >> CreateShortcut.vbs
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> CreateShortcut.vbs
echo oLink.TargetPath = "%CD%\SuperNastroj_Launcher.bat" >> CreateShortcut.vbs
echo oLink.WorkingDirectory = "%CD%" >> CreateShortcut.vbs
echo oLink.Description = "SuperNastroj v5.0 - Systémový nástroj" >> CreateShortcut.vbs
echo oLink.Save >> CreateShortcut.vbs
cscript //nologo CreateShortcut.vbs
del CreateShortcut.vbs
echo ✅ Zástupce vytvořen na ploše
echo.

:: Log instalace
echo [%date% %time%] SuperNastroj v5.0 instalován >> "SuperNastroj_Logs\install.log"

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo  INSTALACE DOKONČENA!
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo ✅ SuperNastroj v5.0 byl úspěšně nainstalován
echo.
echo 📂 Umístění: %CD%
echo 🖥️  Zástupce: Plocha\SuperNastroj.lnk
echo 📁 Složky vytvořeny:
echo    - SuperNastroj_Logs (logy)
echo    - SuperNastroj_Tools (nástroje)
echo    - SuperNastroj_Backups (zálohy)
echo    - SuperNastroj_ISOs (boot disky)
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo  JAK SPUSTIT
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo 🎯 DOPORUČENO:
echo    1. Dvojklik na zástupce na ploše
echo    2. NEBO pravý klik → "Spustit jako správce"
echo.
echo 💡 ALTERNATIVNĚ:
echo    Spustit: SuperNastroj_Launcher.bat
echo.
echo 📚 DOKUMENTACE:
echo    README.md - Hlavní dokumentace
echo    QUICKSTART.md - Rychlý start
echo    INSTALLATION.md - Detailní návod
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

set /p launch="Chcete spustit SuperNastroj nyní? [Y/N]: "
if /i "%launch%"=="Y" (
    echo.
    echo 🚀 Spouštím SuperNastroj...
    timeout /t 2 >nul
    call SuperNastroj_Launcher.bat
) else (
    echo.
    echo 👋 Děkuji za instalaci!
    echo    Spusťte později pomocí zástupce na ploše
    timeout /t 5 >nul
)

endlocal
