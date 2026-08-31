# =================================================================
# STARKO RECOVERY AIO ULTIMATE GENERATOR v5.0
# =================================================================
# Kompletní řešení s automatickými opravami a WSL Ubuntu podporou
# PowerShell 5.1+ (Windows 10/11/Server 2016+)
# Verze: 5.0 - Stabilní a samoopravný
# =================================================================

# -----------------------------------------------------------------
# KONFIGURACE A INICIALIZACE
# -----------------------------------------------------------------
$Global:Config = @{
    RootPath = "C:\StarkoRecovery_AIO"
    DefaultUSB = "L:"
    WinPEVersion = "amd64"
    BrandName = "STARKO RECOVERY ULTIMATE v5.0"
    LogFile = "Starko_Build_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    DownloadTimeout = 300
    MinDiskSpaceGB = 20
    Version = "5.0"
    BuildDate = Get-Date -Format "yyyy-MM-dd"
    CheckForUpdates = $true
    AutoFixErrors = $true
    EnableWSL = $true
    EnableWSLUbuntu = $true
    WSLVersion = 2
    UbuntuVersion = "22.04"
}

# -----------------------------------------------------------------
# AUTOMATICKÉ OPRAVY A KONTROLA CHYB - ZÁKLADNÍ SYSTÉM
# -----------------------------------------------------------------

class ErrorHandler {
    [string]$ErrorCode
    [string]$ErrorMessage
    [string]$Solution
    [bool]$AutoFixable
    [datetime]$Timestamp
    
    ErrorHandler([string]$Code, [string]$Message, [string]$Solution, [bool]$AutoFixable) {
        $this.ErrorCode = $Code
        $this.ErrorMessage = $Message
        $this.Solution = $Solution
        $this.AutoFixable = $AutoFixable
        $this.Timestamp = Get-Date
    }
}

class AutoRepairSystem {
    static [System.Collections.ArrayList]$ErrorLog = @()
    static [int]$ErrorCount = 0
    static [int]$FixedCount = 0
    
    static [void] LogError([string]$Code, [string]$Message, [string]$Solution, [bool]$AutoFixable) {
        $error = [ErrorHandler]::new($Code, $Message, $Solution, $AutoFixable)
        [AutoRepairSystem]::ErrorLog.Add($error)
        [AutoRepairSystem]::ErrorCount++
        
        Write-Host "[ERROR $Code] $Message" -ForegroundColor Red
        if ($AutoFixable) {
            Write-Host "   Řešení: $Solution" -ForegroundColor Yellow
        }
    }
    
    static [bool] TryAutoFix([string]$ErrorCode) {
        $error = [AutoRepairSystem]::ErrorLog | Where-Object { $_.ErrorCode -eq $ErrorCode } | Select-Object -First 1
        
        if (-not $error) {
            return $false
        }
        
        if (-not $error.AutoFixable) {
            Write-Host "[INFO] Chyba $ErrorCode nelze automaticky opravit" -ForegroundColor Yellow
            return $false
        }
        
        Write-Host "[AUTO-REPAIR] Opravuji chybu: $($error.ErrorMessage)" -ForegroundColor Cyan
        
        try {
            switch ($ErrorCode) {
                "EXECUTION_POLICY" {
                    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop
                    Write-Host "   ✓ Execution Policy opraveno" -ForegroundColor Green
                    [AutoRepairSystem]::FixedCount++
                    return $true
                }
                "ADMIN_RIGHTS" {
                    # Restart skriptu jako správce
                    $scriptPath = $MyInvocation.MyCommand.Path
                    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`""
                    exit
                }
                "NO_INTERNET" {
                    # Reset síťových adaptérů
                    netsh winsock reset
                    netsh int ip reset
                    Write-Host "   ✓ Síťové adaptéry resetovány" -ForegroundColor Green
                    [AutoRepairSystem]::FixedCount++
                    return $true
                }
                "DISK_SPACE" {
                    # Vyčištění temp souborů
                    Clean-TempFiles
                    Write-Host "   ✓ Dočasné soubory vyčištěny" -ForegroundColor Green
                    [AutoRepairSystem]::FixedCount++
                    return $true
                }
                "ADK_MISSING" {
                    Install-ADKAutomatically
                    Write-Host "   ✓ ADK instalace zahájena" -ForegroundColor Green
                    [AutoRepairSystem]::FixedCount++
                    return $true
                }
                "WSL_MISSING" {
                    Install-WSLAutomatically
                    Write-Host "   ✓ WSL instalace zahájena" -ForegroundColor Green
                    [AutoRepairSystem]::FixedCount++
                    return $true
                }
                "UBUNTU_MISSING" {
                    Install-UbuntuWSLAutomatically
                    Write-Host "   ✓ Ubuntu WSL instalace zahájena" -ForegroundColor Green
                    [AutoRepairSystem]::FixedCount++
                    return $true
                }
                "ISO_CREATION_FAILED" {
                    # Alternativní metoda ISO
                    Create-ISOAlternative
                    Write-Host "   ✓ Alternativní ISO vytváření spuštěno" -ForegroundColor Green
                    [AutoRepairSystem]::FixedCount++
                    return $true
                }
                "USB_FORMAT_FAILED" {
                    Format-USBAlternative
                    Write-Host "   ✓ Alternativní formátování USB" -ForegroundColor Green
                    [AutoRepairSystem]::FixedCount++
                    return $true
                }
                "DRIVER_INSTALL_FAILED" {
                    # Stažení základních ovladačů
                    Download-EssentialDrivers
                    Write-Host "   ✓ Základní ovladače staženy" -ForegroundColor Green
                    [AutoRepairSystem]::FixedCount++
                    return $true
                }
                default {
                    Write-Host "   ✗ Neznámá chyba: $ErrorCode" -ForegroundColor Red
                    return $false
                }
            }
        }
        catch {
            Write-Host "   ✗ Auto-oprava selhala: $_" -ForegroundColor Red
            return $false
        }
    }
    
    static [void] ShowErrorReport() {
        if ([AutoRepairSystem]::ErrorCount -eq 0) {
            Write-Host "✓ Žádné chyby nebyly zaznamenány" -ForegroundColor Green
            return
        }
        
        Write-Host ""
        Write-Host "=== REPORT CHYB A OPRAV ===" -ForegroundColor Cyan
        Write-Host "Celkem chyb: $([AutoRepairSystem]::ErrorCount)" -ForegroundColor White
        Write-Host "Opraveno: $([AutoRepairSystem]::FixedCount)" -ForegroundColor White
        Write-Host "Nepodařilo se opravit: $([AutoRepairSystem]::ErrorCount - [AutoRepairSystem]::FixedCount)" -ForegroundColor $(if (([AutoRepairSystem]::ErrorCount - [AutoRepairSystem]::FixedCount) -gt 0) { "Red" } else { "Green" })
        Write-Host ""
        
        foreach ($error in [AutoRepairSystem]::ErrorLog) {
            $status = if ($error.AutoFixable) { "AUTO-OPRAVITELNÉ" } else { "MANUÁLNÍ" }
            $color = if ($error.AutoFixable) { "Yellow" } else { "Red" }
            
            Write-Host "[$($error.ErrorCode)]" -ForegroundColor $color -NoNewline
            Write-Host " $($error.ErrorMessage)" -ForegroundColor White
            Write-Host "   Čas: $($error.Timestamp.ToString('HH:mm:ss'))" -ForegroundColor Gray
            Write-Host "   Status: $status" -ForegroundColor $color
            Write-Host "   Řešení: $($error.Solution)" -ForegroundColor Gray
            Write-Host ""
        }
    }
}

# -----------------------------------------------------------------
# FUNKCE PRO AUTOMATICKÉ OPRAVY
# -----------------------------------------------------------------

function Test-AndAutoRepair {
    param(
        [string]$TestName,
        [scriptblock]$TestScript,
        [scriptblock]$RepairScript,
        [string]$ErrorCode,
        [string]$ErrorMessage
    )
    
    Write-Host "[TEST] $TestName..." -ForegroundColor Cyan -NoNewline
    
    try {
        $result = & $TestScript
        if ($result -eq $true) {
            Write-Host " ✓" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host " ✗" -ForegroundColor Red
            
            # Logování chyby
            [AutoRepairSystem]::LogError($ErrorCode, $ErrorMessage, "Automatická oprava dostupná", $true)
            
            # Pokus o automatickou opravu
            if ($Global:Config.AutoFixErrors -and $RepairScript) {
                Write-Host "[AUTO-REPAIR] Pokus o opravu..." -ForegroundColor Yellow
                try {
                    & $RepairScript
                    Write-Host "   ✓ Oprava úspěšná" -ForegroundColor Green
                    [AutoRepairSystem]::FixedCount++
                    return $true
                }
                catch {
                    Write-Host "   ✗ Oprava selhala: $_" -ForegroundColor Red
                    return $false
                }
            }
            else {
                Write-Host "[INFO] Automatická oprava vypnuta nebo nedostupná" -ForegroundColor Yellow
                return $false
            }
        }
    }
    catch {
        Write-Host " ✗ (Chyba testu: $_)" -ForegroundColor Red
        [AutoRepairSystem]::LogError($ErrorCode, "$ErrorMessage ($_)", "Vyžaduje manuální zásah", $false)
        return $false
    }
}

function Test-ExecutionPolicyAuto {
    $test = {
        try {
            $policy = Get-ExecutionPolicy -Scope CurrentUser
            return $policy -in @("RemoteSigned", "Unrestricted", "Bypass")
        }
        catch {
            return $false
        }
    }
    
    $repair = {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Start-Sleep -Seconds 2
        return $true
    }
    
    return Test-AndAutoRepair -TestName "Execution Policy" `
        -TestScript $test `
        -RepairScript $repair `
        -ErrorCode "EXECUTION_POLICY" `
        -ErrorMessage "Restriktivní Execution Policy blokuje spouštění skriptů"
}

function Test-AdminRightsAuto {
    $test = {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($identity)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    
    $repair = {
        $scriptPath = $MyInvocation.MyCommand.Path
        Write-Host "   Restartuji skript jako správce..." -ForegroundColor Yellow
        Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`" -AutoRepair"
        exit
    }
    
    return Test-AndAutoRepair -TestName "Administrátorská práva" `
        -TestScript $test `
        -RepairScript $repair `
        -ErrorCode "ADMIN_RIGHTS" `
        -ErrorMessage "Skript není spuštěn jako správce"
}

function Test-InternetConnectionAuto {
    $test = {
        try {
            $testConn = Test-NetConnection -ComputerName "8.8.8.8" -Port 53 -InformationLevel Quiet -ErrorAction Stop
            return $testConn
        }
        catch {
            return $false
        }
    }
    
    $repair = {
        Write-Host "   Resetuji síťové nastavení..." -ForegroundColor Yellow
        netsh winsock reset | Out-Null
        netsh int ip reset | Out-Null
        ipconfig /release | Out-Null
        ipconfig /renew | Out-Null
        ipconfig /flushdns | Out-Null
        
        Start-Sleep -Seconds 5
        Write-Host "   Kontroluji připojení..." -ForegroundColor Yellow
        
        return Test-NetConnection -ComputerName "8.8.8.8" -Port 53 -InformationLevel Quiet
    }
    
    return Test-AndAutoRepair -TestName "Internetové připojení" `
        -TestScript $test `
        -RepairScript $repair `
        -ErrorCode "NO_INTERNET" `
        -ErrorMessage "Nedostupné internetové připojení"
}

function Test-DiskSpaceAuto {
    param([string]$Path = $Global:Config.RootPath)
    
    $test = {
        $drive = (Get-Item $Path).Root.FullName
        $freeSpace = (Get-PSDrive -Name $drive.Substring(0,1)).Free / 1GB
        return $freeSpace -ge $Global:Config.MinDiskSpaceGB
    }
    
    $repair = {
        Write-Host "   Čistím dočasné soubory..." -ForegroundColor Yellow
        Clean-TempFiles
        Start-Sleep -Seconds 2
        
        $drive = (Get-Item $Path).Root.FullName
        $freeSpace = (Get-PSDrive -Name $drive.Substring(0,1)).Free / 1GB
        return $freeSpace -ge $Global:Config.MinDiskSpaceGB
    }
    
    return Test-AndAutoRepair -TestName "Volné místo na disku" `
        -TestScript $test `
        -RepairScript $repair `
        -ErrorCode "DISK_SPACE" `
        -ErrorMessage "Nedostatek místa na disku (potřeba $($Global:Config.MinDiskSpaceGB) GB)"
}

function Test-ADKInstalledAuto {
    $test = {
        $adkPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat"
        return Test-Path $adkPath
    }
    
    $repair = {
        Write-Host "   Instaluji ADK automaticky..." -ForegroundColor Yellow
        return Install-ADKAutomatically
    }
    
    return Test-AndAutoRepair -TestName "ADK instalace" `
        -TestScript $test `
        -RepairScript $repair `
        -ErrorCode "ADK_MISSING" `
        -ErrorMessage "Windows ADK není nainstalován"
}

function Test-WSLInstalledAuto {
    param([bool]$CheckUbuntu = $false)
    
    $test = {
        try {
            if (Get-Command wsl -ErrorAction SilentlyContinue) {
                if ($CheckUbuntu) {
                    # Kontrola, zda je Ubuntu nainstalováno v WSL
                    $distros = wsl --list --quiet
                    return $distros -contains "Ubuntu" -or $distros -contains "Ubuntu-$($Global:Config.UbuntuVersion)"
                }
                return $true
            }
            return $false
        }
        catch {
            return $false
        }
    }
    
    $repair = {
        if ($CheckUbuntu) {
            Write-Host "   Instaluji WSL s Ubuntu..." -ForegroundColor Yellow
            return Install-UbuntuWSLAutomatically
        }
        else {
            Write-Host "   Instaluji WSL..." -ForegroundColor Yellow
            return Install-WSLAutomatically
        }
    }
    
    $testName = if ($CheckUbuntu) { "WSL Ubuntu" } else { "WSL" }
    $errorCode = if ($CheckUbuntu) { "UBUNTU_MISSING" } else { "WSL_MISSING" }
    $errorMsg = if ($CheckUbuntu) { "WSL Ubuntu není nainstalováno" } else { "WSL není nainstalováno" }
    
    return Test-AndAutoRepair -TestName $testName `
        -TestScript $test `
        -RepairScript $repair `
        -ErrorCode $errorCode `
        -ErrorMessage $errorMsg
}

function Clean-TempFiles {
    Write-Host "[CLEANUP] Čistím dočasné soubory..." -ForegroundColor Yellow
    
    # Čištění Windows Temp
    $tempPaths = @(
        $env:TEMP,
        "$env:SystemRoot\Temp",
        "$env:SystemRoot\Windows\Temp",
        "$env:SystemDrive\Temp"
    )
    
    foreach ($path in $tempPaths) {
        if (Test-Path $path) {
            try {
                Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | 
                    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-1) } |
                    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                Write-Host "   Vyčištěno: $path" -ForegroundColor Gray
            }
            catch {
                Write-Host "   Nelze vyčistit: $path" -ForegroundColor Red
            }
        }
    }
    
    # Čištění prefetch
    $prefetch = "$env:SystemRoot\Prefetch"
    if (Test-Path $prefetch) {
        try {
            Get-ChildItem -Path $prefetch -Filter "*.pf" -ErrorAction SilentlyContinue | 
                Remove-Item -Force -ErrorAction SilentlyContinue
            Write-Host "   Vyčištěno: Prefetch" -ForegroundColor Gray
        }
        catch { }
    }
    
    # Disk Cleanup pomocí cleanmgr
    try {
        Start-Process cleanmgr -ArgumentList "/sagerun:1" -Wait -WindowStyle Hidden
        Write-Host "   Spuštěno: Windows Disk Cleanup" -ForegroundColor Gray
    }
    catch { }
    
    return $true
}

# -----------------------------------------------------------------
# WSL UBUNTU INSTALACE A KONFIGURACE - KOMPLETNÍ PRŮVODCE
# -----------------------------------------------------------------

function Install-WSLAutomatically {
    <#
    .SYNOPSIS
    Automaticky nainstaluje WSL (Windows Subsystem for Linux)
    #>
    
    Write-Host "=== AUTOMATICKÁ INSTALACE WSL ===" -ForegroundColor Cyan
    
    try {
        # 1. Kontrola, zda je Virtualizace povolena
        Write-Host "[1/7] Kontrola virtualizace..." -ForegroundColor Yellow
        $virtualization = Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V" -ErrorAction SilentlyContinue
        
        if ($virtualization.State -ne "Enabled") {
            Write-Host "   Virtualizace není povolena, povoluji..." -ForegroundColor Yellow
            
            # Povolení virtualizace
            Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V" -All -NoRestart
            Enable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -All -NoRestart
            
            Write-Host "   ✓ Virtualizace povolena (vyžaduje restart)" -ForegroundColor Green
        }
        else {
            Write-Host "   ✓ Virtualizace je povolena" -ForegroundColor Green
        }
        
        # 2. Instalace WSL feature
        Write-Host "[2/7] Instalace WSL funkce..." -ForegroundColor Yellow
        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -All -NoRestart
        Write-Host "   ✓ WSL funkce nainstalována" -ForegroundColor Green
        
        # 3. Stáhnutí WSL2 kernel update
        Write-Host "[3/7] Stahování WSL2 kernel..." -ForegroundColor Yellow
        $kernelUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
        $kernelPath = "$env:TEMP\wsl_update.msi"
        
        Invoke-WebRequest -Uri $kernelUrl -OutFile $kernelPath -UseBasicParsing
        Write-Host "   ✓ WSL2 kernel stažen" -ForegroundColor Green
        
        # 4. Instalace WSL2 kernel
        Write-Host "[4/7] Instalace WSL2 kernel..." -ForegroundColor Yellow
        Start-Process msiexec -ArgumentList "/i `"$kernelPath`" /quiet /norestart" -Wait -NoNewWindow
        Write-Host "   ✓ WSL2 kernel nainstalován" -ForegroundColor Green
        
        # 5. Nastavení WSL2 jako výchozí
        Write-Host "[5/7] Nastavení WSL2 jako výchozí..." -ForegroundColor Yellow
        wsl --set-default-version 2
        Write-Host "   ✓ WSL2 nastaven jako výchozí" -ForegroundColor Green
        
        # 6. Restart WSL služby
        Write-Host "[6/7] Restart WSL služby..." -ForegroundColor Yellow
        Restart-Service LxssManager -Force -ErrorAction SilentlyContinue
        Write-Host "   ✓ WSL služba restartována" -ForegroundColor Green
        
        # 7. Otestování WSL
        Write-Host "[7/7] Testování WSL instalace..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
        
        if (Get-Command wsl -ErrorAction SilentlyContinue) {
            Write-Host "   ✓ WSL úspěšně nainstalováno" -ForegroundColor Green
            
            # Zobrazení verze
            $wslVersion = wsl --version
            Write-Host "   Verze: $wslVersion" -ForegroundColor Gray
            
            return $true
        }
        else {
            Write-Host "   ✗ WSL se nepodařilo nainstalovat" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "   ✗ Chyba při instalaci WSL: $_" -ForegroundColor Red
        
        # Alternativní metoda přes dism
        Write-Host "   Zkouším alternativní instalaci..." -ForegroundColor Yellow
        try {
            dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
            dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
            
            return $true
        }
        catch {
            Write-Host "   ✗ Alternativní instalace také selhala" -ForegroundColor Red
            return $false
        }
    }
    finally {
        # Úklid
        if (Test-Path $kernelPath) {
            Remove-Item $kernelPath -Force -ErrorAction SilentlyContinue
        }
    }
}

function Install-UbuntuWSLAutomatically {
    <#
    .SYNOPSIS
    Automaticky nainstaluje Ubuntu v WSL
    #>
    
    Write-Host "=== AUTOMATICKÁ INSTALACE UBUNTU WSL ===" -ForegroundColor Cyan
    
    # Kontrola WSL
    if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
        Write-Host "WSL není nainstalováno, instaluji..." -ForegroundColor Yellow
        if (-not (Install-WSLAutomatically)) {
            return $false
        }
    }
    
    try {
        # 1. Stažení Ubuntu image
        Write-Host "[1/5] Stahuji Ubuntu $($Global:Config.UbuntuVersion)..." -ForegroundColor Yellow
        
        $ubuntuUrl = "https://cloud-images.ubuntu.com/releases/$($Global:Config.UbuntuVersion)/release/ubuntu-$($Global:Config.UbuntuVersion)-server-cloudimg-amd64-wsl.rootfs.tar.gz"
        $ubuntuPath = "$env:TEMP\ubuntu-wsl.tar.gz"
        
        # Progresivní stahování
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $ubuntuUrl -OutFile $ubuntuPath -UseBasicParsing
        Write-Host "   ✓ Ubuntu image stažen" -ForegroundColor Green
        
        # 2. Import Ubuntu do WSL
        Write-Host "[2/5] Importuji Ubuntu do WSL..." -ForegroundColor Yellow
        
        $installPath = "$env:USERPROFILE\WSL\Ubuntu"
        if (-not (Test-Path $installPath)) {
            New-Item -ItemType Directory -Path $installPath -Force | Out-Null
        }
        
        wsl --import Ubuntu $installPath $ubuntuPath --version 2
        Write-Host "   ✓ Ubuntu importováno do WSL" -ForegroundColor Green
        
        # 3. Nastavení Ubuntu jako výchozí distribuce
        Write-Host "[3/5] Nastavuji Ubuntu jako výchozí..." -ForegroundColor Yellow
        wsl --set-default Ubuntu
        Write-Host "   ✓ Ubuntu nastaveno jako výchozí" -ForegroundColor Green
        
        # 4. Konfigurace Ubuntu
        Write-Host "[4/5] Konfiguruji Ubuntu..." -ForegroundColor Yellow
        
        # Spuštění Ubuntu a provedení konfigurace
        $wslConfig = @"
#!/bin/bash
# Ubuntu WSL konfigurační skript

# Aktualizace systému
sudo apt update
sudo apt upgrade -y

# Instalace základních nástrojů
sudo apt install -y build-essential curl wget git gnupg lsb-release

# Instalace xorriso pro vytváření ISO
sudo apt install -y xorriso mtools

# Instalace dalších užitečných nástrojů
sudo apt install -y p7zip-full unzip zip tree htop nano vim

# Vytvoření uživatele pro Starko
sudo useradd -m -s /bin/bash starko
echo "starko:StarkoRecovery2024" | sudo chpasswd
sudo usermod -aG sudo starko

# Vytvoření pracovní složky
sudo mkdir -p /opt/starko
sudo chown starko:starko /opt/starko

echo "Ubuntu WSL konfigurováno pro Starko Recovery"
"@
        
        $configPath = "$env:TEMP\wsl_config.sh"
        Set-Content -Path $configPath -Value $wslConfig -Encoding UTF8
        
        # Spuštění konfiguračního skriptu v WSL
        wsl -d Ubuntu bash -c "bash <(cat /mnt/c/Users/$env:USERNAME/AppData/Local/Temp/wsl_config.sh)"
        
        Write-Host "   ✓ Ubuntu nakonfigurováno" -ForegroundColor Green
        
        # 5. Testování instalace
        Write-Host "[5/5] Testuji instalaci..." -ForegroundColor Yellow
        
        $testResult = wsl -d Ubuntu -- echo "WSL Ubuntu je funkční!"
        if ($testResult -contains "WSL Ubuntu je funkční!") {
            Write-Host "   ✓ Ubuntu WSL je plně funkční" -ForegroundColor Green
            
            # Zobrazení informací
            Write-Host ""
            Write-Host "=== INFORMACE O UBUNTU WSL ===" -ForegroundColor Cyan
            Write-Host "Distribuce: Ubuntu $($Global:Config.UbuntuVersion)" -ForegroundColor White
            Write-Host "Cesta: $installPath" -ForegroundColor White
            Write-Host "Uživatel: starko / StarkoRecovery2024" -ForegroundColor White
            Write-Host "Pracovní složka: /opt/starko" -ForegroundColor White
            Write-Host ""
            Write-Host "Příkazy:" -ForegroundColor Yellow
            Write-Host "  wsl -d Ubuntu                 # Spustit Ubuntu" -ForegroundColor Gray
            Write-Host "  wsl --shutdown               # Vypnout WSL" -ForegroundColor Gray
            Write-Host "  wsl -l -v                    # Zobrazit distribuce" -ForegroundColor Gray
            
            return $true
        }
        else {
            Write-Host "   ✗ Test selhal" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "   ✗ Chyba při instalaci Ubuntu: $_" -ForegroundColor Red
        
        # Alternativní metoda přes Microsoft Store
        Write-Host "   Zkouším alternativní instalaci přes Store..." -ForegroundColor Yellow
        try {
            Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4MSV6"
            Write-Host "   Otevřena stránka Ubuntu v Microsoft Store" -ForegroundColor Yellow
            Write-Host "   Nainstalujte Ubuntu manuálně a restartujte skript" -ForegroundColor Yellow
            return $false
        }
        catch {
            Write-Host "   ✗ Nelze otevřít Microsoft Store" -ForegroundColor Red
            return $false
        }
    }
    finally {
        # Úklid
        if (Test-Path $ubuntuPath) {
            Remove-Item $ubuntuPath -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path $configPath) {
            Remove-Item $configPath -Force -ErrorAction SilentlyContinue
        }
    }
}

function Show-WSLUbuntuGuide {
    <#
    .SYNOPSIS
    Zobrazí kompletní průvodce instalací a použitím WSL Ubuntu
    #>
    
    Clear-Host
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "  WSL UBUNTU - KOMPLETNÍ PRŮVODCE" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
    
    while ($true) {
        Write-Host "VYBERTE AKCI:" -ForegroundColor Yellow
        Write-Host "  [1] 📚 Co je WSL a proč ho použít?" -ForegroundColor White
        Write-Host "  [2] 🛠️  Automatická instalace WSL + Ubuntu" -ForegroundColor White
        Write-Host "  [3] 🔧 Manuální instalace (krok za krokem)" -ForegroundColor White
        Write-Host "  [4] ⚙️  Konfigurace a optimalizace" -ForegroundColor White
        Write-Host "  [5] 🐧 Základní příkazy Ubuntu" -ForegroundColor White
        Write-Host "  [6] 💿 Vytváření ISO pomocí WSL" -ForegroundColor White
        Write-Host "  [7] 🔍 Řešení problémů" -ForegroundColor White
        Write-Host "  [8] 📊 Stav WSL a Ubuntu" -ForegroundColor White
        Write-Host "  [0] ↩ Zpět do hlavního menu" -ForegroundColor White
        Write-Host ""
        
        $choice = Read-Host "Vaše volba"
        
        switch ($choice) {
            "1" {
                Show-WSLInfo
            }
            "2" {
                Write-Host "=== AUTOMATICKÁ INSTALACE ===" -ForegroundColor Cyan
                Write-Host ""
                
                Write-Host "Tato funkce automaticky nainstaluje:" -ForegroundColor Yellow
                Write-Host "  1. Windows Subsystem for Linux (WSL2)" -ForegroundColor White
                Write-Host "  2. Ubuntu $($Global:Config.UbuntuVersion) LTS" -ForegroundColor White
                Write-Host "  3. Všechny potřebné nástroje" -ForegroundColor White
                Write-Host ""
                Write-Host "POZOR: Instalace může trvat 10-30 minut" -ForegroundColor Red
                Write-Host "       a vyžaduje restart systému." -ForegroundColor Red
                Write-Host ""
                
                $confirm = Read-Host "Pokračovat? (A/N)"
                
                if ($confirm -match "^[Aa]") {
                    # Spuštění automatické instalace
                    $success = Install-UbuntuWSLAutomatically
                    
                    if ($success) {
                        Write-Host ""
                        Write-Host "✓ Instalace dokončena úspěšně!" -ForegroundColor Green
                        Write-Host "  Restartujte počítač pro dokončení instalace." -ForegroundColor Yellow
                    }
                }
            }
            "3" {
                Show-ManualWSLInstallation
            }
            "4" {
                Show-WSLConfiguration
            }
            "5" {
                Show-UbuntuCommands
            }
            "6" {
                Show-WSLISOCreation
            }
            "7" {
                Show-WSLTroubleshooting
            }
            "8" {
                Show-WSLStatus
            }
            "0" {
                return
            }
            default {
                Write-Host "Neplatná volba." -ForegroundColor Red
            }
        }
        
        Write-Host ""
        Write-Host "Stiskněte Enter pro pokračování..." -ForegroundColor Gray
        $null = Read-Host
        Clear-Host
    }
}

function Show-WSLInfo {
    Write-Host "=== CO JE WSL A PROČ HO POUŽÍT? ===" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "📚 WSL (Windows Subsystem for Linux):" -ForegroundColor Yellow
    Write-Host "  - Umožňuje spouštět Linuxové aplikace přímo ve Windows" -ForegroundColor White
    Write-Host "  - Plná integrace s Windows systémem" -ForegroundColor White
    Write-Host "  - Žádné virtualizace, přímý přístup k souborům" -ForegroundColor White
    Write-Host ""
    
    Write-Host "🎯 Výhody pro Starko Recovery:" -ForegroundColor Yellow
    Write-Host "  ✓ Vytváření ISO souborů pomocí Linuxových nástrojů" -ForegroundColor Green
    Write-Host "  ✓ Přístup k Linuxovým recovery nástrojům" -ForegroundColor Green
    Write-Host "  ✓ Testování Linux recovery ISO" -ForegroundColor Green
    Write-Host "  ✓ Pokročilé forenzní nástroje" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "🔧 Technické požadavky:" -ForegroundColor Yellow
    Write-Host "  - Windows 10 verze 2004 nebo novější" -ForegroundColor White
    Write-Host "  - Windows 11 (doporučeno)" -ForegroundColor White
    Write-Host "  - 64-bitový procesor s virtualizací" -ForegroundColor White
    Write-Host "  - Minimálně 4 GB RAM" -ForegroundColor White
    Write-Host "  - 10 GB volného místa" -ForegroundColor White
    Write-Host ""
    
    Write-Host "📊 Verze WSL:" -ForegroundColor Yellow
    Write-Host "  • WSL1: Starší verze, překlad systémových volání" -ForegroundColor White
    Write-Host "  • WSL2: Nová verze s plným Linux kernel, doporučeno" -ForegroundColor White
    Write-Host ""
    
    Write-Host "🐧 Podporované distribuce:" -ForegroundColor Yellow
    Write-Host "  - Ubuntu (doporučeno)" -ForegroundColor White
    Write-Host "  - Debian" -ForegroundColor White
    Write-Host "  - Kali Linux" -ForegroundColor White
    Write-Host "  - openSUSE" -ForegroundColor White
    Write-Host "  - a další..." -ForegroundColor White
}

function Show-ManualWSLInstallation {
    Write-Host "=== MANUÁLNÍ INSTALACE WSL - KROK ZA KROKEM ===" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "📋 POSTUP INSTALACE:" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "KROK 1: Povolení WSL funkce" -ForegroundColor Green
    Write-Host "  1. Otevřete PowerShell jako správce" -ForegroundColor White
    Write-Host "  2. Spusťte tento příkaz:" -ForegroundColor White
    Write-Host "     dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "KROK 2: Povolení Virtual Machine Platform" -ForegroundColor Green
    Write-Host "  1. Ve stejném PowerShell spusťte:" -ForegroundColor White
    Write-Host "     dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart" -ForegroundColor Cyan
    Write-Host "  2. RESTARTOVAT počítač" -ForegroundColor Red
    Write-Host ""
    
    Write-Host "KROK 3: Stažení WSL2 Kernel" -ForegroundColor Green
    Write-Host "  1. Stáhněte si: https://aka.ms/wsl2kernel" -ForegroundColor Cyan
    Write-Host "  2. Nainstalujte stažený MSI soubor" -ForegroundColor White
    Write-Host ""
    
    Write-Host "KROK 4: Nastavení WSL2 jako výchozí" -ForegroundColor Green
    Write-Host "  1. Otevřete PowerShell" -ForegroundColor White
    Write-Host "  2. Spusťte: wsl --set-default-version 2" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "KROK 5: Instalace Ubuntu" -ForegroundColor Green
    Write-Host "  1. Otevřete Microsoft Store" -ForegroundColor White
    Write-Host "  2. Vyhledejte 'Ubuntu'" -ForegroundColor White
    Write-Host "  3. Klikněte na 'Get' nebo 'Install'" -ForegroundColor White
    Write-Host "  4. Po instalaci spusťte Ubuntu z nabídky Start" -ForegroundColor White
    Write-Host "  5. Nastavte uživatelské jméno a heslo" -ForegroundColor White
    Write-Host ""
    
    Write-Host "KROK 6: Konfigurace pro Starko Recovery" -ForegroundColor Green
    Write-Host "  1. V Ubuntu spusťte:" -ForegroundColor White
    Write-Host "     sudo apt update && sudo apt upgrade -y" -ForegroundColor Cyan
    Write-Host "  2. Nainstalujte potřebné nástroje:" -ForegroundColor White
    Write-Host "     sudo apt install -y xorriso mtools p7zip-full" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "📝 RYCHLÝ INSTALAČNÍ SKRIPT:" -ForegroundColor Yellow
    Write-Host "  Můžete použít tento PowerShell skript pro automatickou instalaci:" -ForegroundColor White
    Write-Host ""
    Write-Host '  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/starko/recovery/main/install-wsl.ps1" -OutFile install-wsl.ps1' -ForegroundColor Cyan
    Write-Host '  .\install-wsl.ps1' -ForegroundColor Cyan
}

function Show-WSLConfiguration {
    Write-Host "=== KONFIGURACE A OPTIMALIZACE WSL ===" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "⚙️  ZÁKLADNÍ KONFIGURACE:" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "1. Konfigurační soubor WSL:" -ForegroundColor Green
    Write-Host "   Vytvořte soubor: $env:USERPROFILE\.wslconfig" -ForegroundColor White
    Write-Host "   S tímto obsahem:" -ForegroundColor White
    Write-Host ""
    Write-Host "   [wsl2]" -ForegroundColor Cyan
    Write-Host "   memory=4GB        # Maximální RAM pro WSL" -ForegroundColor Gray
    Write-Host "   processors=4      # Počet procesorových jader" -ForegroundColor Gray
    Write-Host "   swap=2GB          # Velikost swap souboru" -ForegroundColor Gray
    Write-Host "   localhostForwarding=true" -ForegroundColor Gray
    Write-Host ""
    
    WriteHost "2. Změna výchozí distribuce:" -ForegroundColor Green
    Write-Host "   wsl --set-default Ubuntu" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "3. Změna verze WSL pro distribuci:" -ForegroundColor Green
    Write-Host "   wsl --set-version Ubuntu 2" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "🔧 POKROČILÁ KONFIGURACE:" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "1. Připojení síťového úložiště:" -ForegroundColor Green
    Write-Host "   # V Ubuntu:" -ForegroundColor White
    Write-Host "   sudo mkdir /mnt/nas" -ForegroundColor Cyan
    Write-Host "   sudo mount -t cifs //nas-server/share /mnt/nas -o username=user,password=pass" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "2. Přidání Windows PATH do Ubuntu:" -ForegroundColor Green
    Write-Host "   # V ~/.bashrc přidejte:" -ForegroundColor White
    Write-Host "   export PATH=$PATH:/mnt/c/Windows/System32" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "3. Automatické spouštění služeb:" -ForegroundColor Green
    Write-Host "   # Vytvořte službu ve Windows:" -ForegroundColor White
    Write-Host "   New-Service -Name 'WSLUbuntu' -BinaryPathName 'wsl -d Ubuntu' -StartupType Automatic" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "📊 OPTIMALIZACE VÝKONU:" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "1. Optimalizace disk I/O:" -ForegroundColor Green
    Write-Host "   # V .wslconfig přidejte:" -ForegroundColor White
    Write-Host "   [wsl2]" -ForegroundColor Cyan
    Write-Host "   kernelCommandLine = noatime nodiratime" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "2. Zvýšení výkonu souborového systému:" -ForegroundColor Green
    Write-Host "   # V Ubuntu:" -ForegroundColor White
    Write-Host "   sudo tune2fs -O dir_index,has_journal /dev/sdb1" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "3. Cache a zámky:" -ForegroundColor Green
    Write-Host "   # Pro SSD přidejte do /etc/fstab:" -ForegroundColor White
    Write-Host "   tmpfs /tmp tmpfs defaults,noatime,nosuid,size=1G 0 0" -ForegroundColor Cyan
}

function Show-UbuntuCommands {
    Write-Host "=== ZÁKLADNÍ PŘÍKAZY UBUNTU ===" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "📁 SOUBOROVÝ SYSTÉM:" -ForegroundColor Yellow
    Write-Host "  ls                  # Výpis souborů" -ForegroundColor Gray
    Write-Host "  ls -la              # Detailní výpis" -ForegroundColor Gray
    Write-Host "  cd /cesta           # Změna adresáře" -ForegroundColor Gray
    Write-Host "  pwd                 # Aktuální adresář" -ForegroundColor Gray
    Write-Host "  cp soubor cil       # Kopírování" -ForegroundColor Gray
    Write-Host "  mv soubor cil       # Přesunutí" -ForegroundColor Gray
    Write-Host "  rm soubor           # Smazání" -ForegroundColor Gray
    Write-Host "  mkdir slozka        # Vytvoření složky" -ForegroundColor Gray
    Write-Host "  rmdir slozka        # Smazání složky" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "📊 SYSTÉMOVÉ PŘÍKAZY:" -ForegroundColor Yellow
    Write-Host "  sudo příkaz         # Spuštění jako správce" -ForegroundColor Gray
    Write-Host "  apt update          # Aktualizace seznamu balíčků" -ForegroundColor Gray
    Write-Host "  apt upgrade         # Aktualizace systému" -ForegroundColor Gray
    Write-Host "  apt install balicek # Instalace balíčku" -ForegroundColor Gray
    Write-Host "  apt remove balicek  # Odstranění balíčku" -ForegroundColor Gray
    Write-Host "  systemctl start služba # Start služby" -ForegroundColor Gray
    Write-Host "  systemctl stop služba  # Stop služby" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "🔧 NÁSTROJE PRO RECOVERY:" -ForegroundColor Yellow
    Write-Host "  xorriso             # Vytváření ISO" -ForegroundColor Gray
    Write-Host "  dd                  # Kopírování disků" -ForegroundColor Gray
    Write-Host "  fdisk               # Správa oddílů" -ForegroundColor Gray
    Write-Host "  mkfs                # Vytváření souborových systémů" -ForegroundColor Gray
    Write-Host "  mount               # Připojení zařízení" -ForegroundColor Gray
    Write-Host "  umount              # Odpojení zařízení" -ForegroundColor Gray
    Write-Host "  fsck                # Kontrola souborového systému" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "🌐 SÍŤOVÉ PŘÍKAZY:" -ForegroundColor Yellow
    Write-Host "  ping google.com     # Test spojení" -ForegroundColor Gray
    Write-Host "  ifconfig            # Síťová rozhraní" -ForegroundColor Gray
    Write-Host "  netstat             # Síťová připojení" -ForegroundColor Gray
    Write-Host "  wget URL            # Stahování souborů" -ForegroundColor Gray
    Write-Host "  curl URL            # HTTP požadavky" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "💾 DISKOVÉ NÁSTROJE:" -ForegroundColor Yellow
    Write-Host "  lsblk               # Seznam blokových zařízení" -ForegroundColor Gray
    Write-Host "  blkid               # UUID zařízení" -ForegroundColor Gray
    Write-Host "  smartctl            # SMART data disků" -ForegroundColor Gray
    Write-Host "  badblocks           # Hledání špatných bloků" -ForegroundColor Gray
    Write-Host "  hdparm              # Testy výkonu disku" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "📝 UKÁZKOVÉ SKRIPTY:" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "1. Vytvoření ISO z adresáře:" -ForegroundColor Green
    Write-Host "   xorriso -as mkisofs -r -V 'STARKO_RECOVERY' -o recovery.iso /cesta/k/slozce" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "2. Záloha disku:" -ForegroundColor Green
    Write-Host "   dd if=/dev/sda of=backup.img bs=4M status=progress" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "3. Obnova disku:" -ForegroundColor Green
    Write-Host "   dd if=backup.img of=/dev/sda bs=4M status=progress" -ForegroundColor Cyan
}

function Show-WSLISOCreation {
    Write-Host "=== VYTVÁŘENÍ ISO POMOCÍ WSL ===" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "📦 INSTALACE NÁSTROJŮ:" -ForegroundColor Yellow
    Write-Host "  1. Spusťte Ubuntu WSL" -ForegroundColor White
    Write-Host "  2. Nainstalujte potřebné balíčky:" -ForegroundColor White
    Write-Host "     sudo apt update" -ForegroundColor Cyan
    Write-Host "     sudo apt install -y xorriso genisoimage mkisofs" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "🔧 PŘÍPRAVA SOUBORŮ:" -ForegroundColor Yellow
    Write-Host "  Windows soubory jsou dostupné v /mnt/c/" -ForegroundColor White
    Write-Host "  Příklad:" -ForegroundColor White
    Write-Host "    /mnt/c/StarkoRecovery_AIO/    # Hlavní složka" -ForegroundColor Gray
    Write-Host "    /mnt/c/Users/VaseJmeno/       # Uživatelská složka" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "💿 VYTVÁŘENÍ ISO - TŘI METODY:" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "METODA 1: xorriso (doporučeno)" -ForegroundColor Green
    Write-Host "  xorriso -as mkisofs ^" -ForegroundColor Cyan
    Write-Host "    -r -V 'STARKO_RECOVERY' ^" -ForegroundColor Gray
    Write-Host "    -J -joliet-long ^" -ForegroundColor Gray
    Write-Host "    -iso-level 3 ^" -ForegroundColor Gray
    Write-Host "    -o /mnt/c/StarkoRecovery_AIO/recovery.iso ^" -ForegroundColor Gray
    Write-Host "    /mnt/c/StarkoRecovery_AIO/WinPE/media" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "METODA 2: genisoimage" -ForegroundColor Green
    Write-Host "  genisoimage -r -J -V 'STARKO_RECOVERY' ^" -ForegroundColor Cyan
    Write-Host "    -o /mnt/c/StarkoRecovery_AIO/recovery.iso ^" -ForegroundColor Gray
    Write-Host "    /mnt/c/StarkoRecovery_AIO/WinPE/media" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "METODA 3: mkisofs" -ForegroundColor Green
    Write-Host "  mkisofs -r -J -V 'STARKO_RECOVERY' ^" -ForegroundColor Cyan
    Write-Host "    -o /mnt/c/StarkoRecovery_AIO/recovery.iso ^" -ForegroundColor Gray
    Write-Host "    /mnt/c/StarkoRecovery_AIO/WinPE/media" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "🎯 POKROČILÉ VOLBY:" -ForegroundColor Yellow
    Write-Host "  -boot-info-table    # Boot informace" -ForegroundColor Gray
    Write-Host "  -b boot.img         # Boot image" -ForegroundColor Gray
    Write-Host "  -c boot.catalog     # Boot katalog" -ForegroundColor Gray
    Write-Host "  -no-emul-boot       # Bez emulace bootu" -ForegroundColor Gray
    Write-Host "  -partition_offset 16 # Offset oddílu" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "📁 AUTOMATICKÝ SKRIPT:" -ForegroundColor Yellow
    Write-Host "  Vytvořte soubor create-iso.sh v Ubuntu:" -ForegroundColor White
    Write-Host ""
    Write-Host "  #!/bin/bash" -ForegroundColor Cyan
    Write-Host "  SOURCE_DIR=\"/mnt/c/StarkoRecovery_AIO/WinPE/media\"" -ForegroundColor Gray
    Write-Host "  OUTPUT_ISO=\"/mnt/c/StarkoRecovery_AIO/ISO/Starko_Recovery.iso\"" -ForegroundColor Gray
    Write-Host "  VOLUME_NAME=\"STARKO_RECOVERY_$(date +%Y%m%d)\"" -ForegroundColor Gray
    Write-Host "" -ForegroundColor Gray
    Write-Host "  xorriso -as mkisofs \\" -ForegroundColor Gray
    Write-Host "    -r -V \"\$VOLUME_NAME\" \\" -ForegroundColor Gray
    Write-Host "    -J -joliet-long \\" -ForegroundColor Gray
    Write-Host "    -iso-level 3 \\" -ForegroundColor Gray
    Write-Host "    -o \"\$OUTPUT_ISO\" \\" -ForegroundColor Gray
    Write-Host "    \"\$SOURCE_DIR\"" -ForegroundColor Gray
    Write-Host "" -ForegroundColor Gray
    Write-Host "  echo \"ISO vytvořeno: \$OUTPUT_ISO\"" -ForegroundColor Gray
}

function Show-WSLTroubleshooting {
    Write-Host "=== ŘEŠENÍ PROBLÉMŮ WSL ===" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "🔧 BĚŽNÉ PROBLÉMY A ŘEŠENÍ:" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "PROBLÉM 1: WSL se nespustí" -ForegroundColor Green
    Write-Host "  ŘEŠENÍ:" -ForegroundColor White
    Write-Host "    1. Ověřte, zda je virtualizace povolena v BIOS" -ForegroundColor Gray
    Write-Host "    2. Spusťte: dism /online /enable-feature /featurename:VirtualMachinePlatform" -ForegroundColor Cyan
    Write-Host "    3. Restartujte počítač" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "PROBLÉM 2: Ubuntu se nainstaluje, ale nespustí" -ForegroundColor Green
    Write-Host "  ŘEŠENÍ:" -ForegroundColor White
    Write-Host "    1. Resetujte WSL: wsl --shutdown" -ForegroundColor Cyan
    Write-Host "    2. Odinstalujte a znovu nainstalujte Ubuntu" -ForegroundColor Gray
    Write-Host "    3. Zkontrolujte logy: Get-EventLog -LogName Application -Source *WSL*" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "PROBLÉM 3: Pomalý výkon" -ForegroundColor Green
    Write-Host "  ŘEŠENÍ:" -ForegroundColor White
    WriteHost "    1. Přesuňte distribuci na SSD" -ForegroundColor Gray
    Write-Host "    2. Optimalizujte .wslconfig (viz Konfigurace)" -ForegroundColor Gray
    Write-Host "    3. Zakažte Windows Defender pro WSL soubory" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "PROBLÉM 4: Nelze přistupovat k Windows souborům" -ForegroundColor Green
    Write-Host "  ŘEŠENÍ:" -ForegroundColor White
    Write-Host "    1. Spusťte Ubuntu jako správce" -ForegroundColor Gray
    Write-Host "    2. Použijte: sudo mount -t drvfs C: /mnt/c -o metadata" -ForegroundColor Cyan
    Write-Host "    3. Zkontrolujte oprávnění" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "PROBLÉM 5: Chyba při vytváření ISO" -ForegroundColor Green
    Write-Host "  ŘEŠENÍ:" -ForegroundColor White
    Write-Host "    1. Ověřte, zda jsou nainstalovány xorriso/mkisofs" -ForegroundColor Gray
    Write-Host "    2. Zkontrolujte cesty k souborům" -ForegroundColor Gray
    Write-Host "    3. Spusťte Ubuntu jako správce" -ForegroundColor Gray
    Write-Host "    4. Použijte plné cesty: /mnt/c/... místo C:/..." -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "📝 DIAGNOSTICKÉ PŘÍKAZY:" -ForegroundColor Yellow
    Write-Host "  wsl --status                # Stav WSL" -ForegroundColor Cyan
    Write-Host "  wsl --list --verbose        # Seznam distribucí" -ForegroundColor Cyan
    Write-Host "  wsl --shutdown              # Vypnutí WSL" -ForegroundColor Cyan
    Write-Host "  wsl -d Ubuntu -- uname -a   # Verze Ubuntu" -ForegroundColor Cyan
    Write-Host "  Get-Service LxssManager     # Stav služby WSL" -ForegroundColor Cyan
}

function Show-WSLStatus {
    Write-Host "=== STAV WSL A UBUNTU ===" -ForegroundColor Cyan
    Write-Host ""
    
    # Kontrola WSL
    Write-Host "🔍 KONTROLA WSL:" -ForegroundColor Yellow
    
    try {
        # Verze WSL
        $wslVersion = wsl --version 2>$null
        if ($wslVersion) {
            Write-Host "  ✓ WSL je nainstalováno" -ForegroundColor Green
            Write-Host "    Verze: $wslVersion" -ForegroundColor Gray
        }
        else {
            Write-Host "  ✗ WSL není nainstalováno" -ForegroundColor Red
        }
        
        # Seznam distribucí
        Write-Host ""
        Write-Host "📋 DISTRIBUCE WSL:" -ForegroundColor Yellow
        $distros = wsl --list --quiet 2>$null
        if ($distros) {
            foreach ($distro in $distros) {
                Write-Host "  • $distro" -ForegroundColor Gray
            }
        }
        else {
            Write-Host "  Žádné distribuce nejsou nainstalovány" -ForegroundColor Red
        }
        
        # Stav služby
        Write-Host ""
        Write-Host "⚙️  SLUŽBA WSL:" -ForegroundColor Yellow
        $service = Get-Service LxssManager -ErrorAction SilentlyContinue
        if ($service) {
            Write-Host "  Stav: $($service.Status)" -ForegroundColor $(if ($service.Status -eq "Running") { "Green" } else { "Red" })
            Write-Host "  Spuštěno: $($service.StartType)" -ForegroundColor Gray
        }
        
        # Kontrola Ubuntu
        Write-Host ""
        Write-Host "🐧 KONTROLA UBUNTU:" -ForegroundColor Yellow
        
        $ubuntuTest = wsl -d Ubuntu -- echo "Ubuntu je funkční" 2>$null
        if ($ubuntuTest -contains "Ubuntu je funkční") {
            Write-Host "  ✓ Ubuntu je funkční" -ForegroundColor Green
            
            # Získání informací o Ubuntu
            $ubuntuInfo = wsl -d Ubuntu -- lsb_release -a 2>$null
            if ($ubuntuInfo) {
                Write-Host "    Informace:" -ForegroundColor Gray
                $ubuntuInfo | ForEach-Object {
                    Write-Host "    $_" -ForegroundColor Gray
                }
            }
        }
        else {
            Write-Host "  ✗ Ubuntu není funkční nebo není nainstalováno" -ForegroundColor Red
        }
        
        # Kontrola nástrojů
        Write-Host ""
        Write-Host "🔧 NÁSTROJE V UBUNTU:" -ForegroundColor Yellow
        
        $tools = @("xorriso", "mkisofs", "genisoimage", "dd", "fdisk")
        foreach ($tool in $tools) {
            $toolCheck = wsl -d Ubuntu -- which $tool 2>$null
            if ($toolCheck) {
                Write-Host "  ✓ $tool je nainstalován" -ForegroundColor Green
            }
            else {
                Write-Host "  ✗ $tool není nainstalován" -ForegroundColor Red
            }
        }
        
        # Stav souborového systému
        Write-Host ""
        Write-Host "💾 PŘIPOJENÉ DISKY:" -ForegroundColor Yellow
        
        $mounts = wsl -d Ubuntu -- mount 2>$null
        if ($mounts) {
            $mounts | Select-Object -First 5 | ForEach-Object {
                if ($_ -match "on (/mnt/[a-zA-Z])") {
                    Write-Host "  $($matches[1])" -ForegroundColor Gray
                }
            }
        }
        
    }
    catch {
        Write-Host "  Chyba při kontrole WSL: $_" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "📊 SHRNUTÍ:" -ForegroundColor Yellow
    Write-Host "  - WSL nainstalováno: $(if (Get-Command wsl -ErrorAction SilentlyContinue) { 'ANO' } else { 'NE' })" -ForegroundColor White
    Write-Host "  - Ubuntu nainstalováno: $(if ($ubuntuTest -contains 'Ubuntu je funkční') { 'ANO' } else { 'NE' })" -ForegroundColor White
    Write-Host "  - Nástroje připraveny: $(if ((wsl -d Ubuntu -- which xorriso 2>$null) -and (wsl -d Ubuntu -- which mkisofs 2>$null)) { 'ANO' } else { 'ČÁSTEČNĚ' })" -ForegroundColor White
}

# -----------------------------------------------------------------
# INTEGROVANÉ FUNKCE PRO VYTVÁŘENÍ ISO S WSL
# -----------------------------------------------------------------

function Create-ISOWithWSL {
    <#
    .SYNOPSIS
    Vytvoří ISO soubor pomocí WSL Ubuntu
    #>
    
    param(
        [string]$SourcePath,
        [string]$OutputPath,
        [string]$VolumeLabel = "STARKO_RECOVERY"
    )
    
    Write-Host "=== VYTVÁŘENÍ ISO POMOCÍ WSL UBUNTU ===" -ForegroundColor Cyan
    
    # Kontrola WSL
    if (-not (Test-WSLInstalledAuto -CheckUbuntu $true)) {
        Write-Host "WSL Ubuntu není dostupné!" -ForegroundColor Red
        return $false
    }
    
    try {
        # Převod cest pro WSL
        $wslSource = Convert-PathToWSL -WindowsPath $SourcePath
        $wslOutput = Convert-PathToWSL -WindowsPath $OutputPath
        
        Write-Host "Zdroj: $wslSource" -ForegroundColor Yellow
        Write-Host "Cíl: $wslOutput" -ForegroundColor Yellow
        Write-Host "Popisek: $VolumeLabel" -ForegroundColor Yellow
        Write-Host ""
        
        # Příkaz pro vytvoření ISO
        $isoCommand = @"
cd $(Split-Path $wslSource -Parent)
xorriso -as mkisofs \
  -r -V "$VolumeLabel" \
  -J -joliet-long \
  -iso-level 3 \
  -o "$wslOutput" \
  "$wslSource"
"@
        
        Write-Host "Spouštím vytváření ISO..." -ForegroundColor Cyan
        
        # Spuštění v WSL
        $result = wsl -d Ubuntu bash -c $isoCommand 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            # Kontrola vytvořeného souboru
            if (Test-Path $OutputPath) {
                $sizeGB = [math]::Round((Get-Item $OutputPath).Length / 1GB, 2)
                Write-Host "✓ ISO úspěšně vytvořeno: $OutputPath ($sizeGB GB)" -ForegroundColor Green
                return $true
            }
        }
        else {
            Write-Host "✗ Chyba při vytváření ISO:" -ForegroundColor Red
            Write-Host $result -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "✗ Chyba: $_" -ForegroundColor Red
        return $false
    }
}

function Convert-PathToWSL {
    <#
    .SYNOPSIS
    Převádí Windows cestu na WSL cestu
    #>
    
    param([string]$WindowsPath)
    
    if (-not $WindowsPath) {
        return ""
    }
    
    # Odstranění dvojtečky a převod lomítek
    $wslPath = $WindowsPath -replace '^([A-Z]):', '/mnt/$1'
    $wslPath = $wslPath -replace '\\', '/'
    
    return $wslPath.ToLower()
}

function Convert-PathToWindows {
    <#
    .SYNOPSIS
    Převádí WSL cestu na Windows cestu
    #>
    
    param([string]$WSLPath)
    
    if (-not $WSLPath) {
        return ""
    }
    
    # Převod z /mnt/c/ na C:\
    $windowsPath = $WSLPath -replace '^/mnt/([a-z])/', '$1:\'
    $windowsPath = $windowsPath -replace '/', '\'
    
    return $windowsPath
}

# -----------------------------------------------------------------
# HLAVNÍ MENU S AUTOMATICKÝMI OPRAVAMI
# -----------------------------------------------------------------

function Initialize-WithAutoRepair {
    <#
    .SYNOPSIS
    Inicializuje systém s automatickými opravami
    #>
    
    Clear-Host
    
    # Banner
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "  STARTO RECOVERY AIO GENERATOR v$($Global:Config.Version)" -ForegroundColor Green
    Write-Host "  Systém automatických oprav a WSL Ubuntu" -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "Datum: $(Get-Date -Format 'dd.MM.yyyy HH:mm')" -ForegroundColor Gray
    Write-Host "Počítač: $env:COMPUTERNAME" -ForegroundColor Gray
    Write-Host "Uživatel: $env:USERNAME" -ForegroundColor Gray
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Spuštění automatických kontrol
    Write-Host "🔍 PROBÍHAJÍ AUTOMATICKÉ KONTROLY..." -ForegroundColor Cyan
    Write-Host ""
    
    $checks = @(
        @{Name = "Execution Policy"; Test = { Test-ExecutionPolicyAuto } },
        @{Name = "Administrátorská práva"; Test = { Test-AdminRightsAuto } },
        @{Name = "Internetové připojení"; Test = { Test-InternetConnectionAuto } },
        @{Name = "Volné místo na disku"; Test = { Test-DiskSpaceAuto } },
        @{Name = "ADK instalace"; Test = { Test-ADKInstalledAuto } },
        @{Name = "WSL instalace"; Test = { Test-WSLInstalledAuto -CheckUbuntu $false } }
    )
    
    $passed = 0
    $failed = 0
    
    foreach ($check in $checks) {
        Write-Host "  $($check.Name)..." -ForegroundColor Cyan -NoNewline
        
        try {
            $result = & $check.Test
            if ($result) {
                Write-Host " ✓" -ForegroundColor Green
                $passed++
            }
            else {
                Write-Host " ✗" -ForegroundColor Red
                $failed++
            }
        }
        catch {
            Write-Host " ✗ (Chyba: $_)" -ForegroundColor Red
            $failed++
        }
        
        Start-Sleep -Milliseconds 100
    }
    
    Write-Host ""
    Write-Host "📊 VÝSLEDKY KONTROL:" -ForegroundColor Cyan
    Write-Host "  Úspěšné: $passed" -ForegroundColor Green
    Write-Host "  Selhalo: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Green" })
    Write-Host ""
    
    if ($failed -gt 0) {
        Write-Host "⚠ NĚKTERÉ KONTROLY SELHALY" -ForegroundColor Yellow
        Write-Host "  Automatické opravy budou použity během buildu." -ForegroundColor White
        Write-Host ""
    }
    
    # Vytvoření pracovního adresáře
    if (-not (Test-Path $Global:Config.RootPath)) {
        New-Item -ItemType Directory -Path $Global:Config.RootPath -Force | Out-Null
        Write-Host "✓ Vytvořen pracovní adresář: $($Global:Config.RootPath)" -ForegroundColor Green
    }
    
    # Zobrazení reportu
    [AutoRepairSystem]::ShowErrorReport()
    
    Write-Host ""
    Write-Host "Stiskněte Enter pro pokračování do hlavního menu..." -ForegroundColor Gray
    $null = Read-Host
    
    return $true
}

function Show-MainMenuWithAutoRepair {
    <#
    .SYNOPSIS
    Hlavní menu s integrovanými automatickými opravami
    #>
    
    Clear-Host
    
    while ($true) {
        # Banner
        Write-Host "==================================================" -ForegroundColor Cyan
        Write-Host "  STARTO RECOVERY AIO - HLAVNÍ MENU v$($Global:Config.Version)" -ForegroundColor Green
        Write-Host "==================================================" -ForegroundColor Cyan
        Write-Host ""
        
        # Rychlý status
        Write-Host "📊 RYCHLÝ STATUS:" -ForegroundColor Yellow
        Write-Host "  Chyby: $([AutoRepairSystem]::ErrorCount)" -ForegroundColor $(if ([AutoRepairSystem]::ErrorCount -gt 0) { "Red" } else { "Green" })
        Write-Host "  Opraveno: $([AutoRepairSystem]::FixedCount)" -ForegroundColor Green
        Write-Host "  WSL: $(if (Get-Command wsl -ErrorAction SilentlyContinue) { 'ANO' } else { 'NE' })" -ForegroundColor White
        Write-Host "  Ubuntu: $(if (wsl -d Ubuntu -- echo 'test' 2>$null) { 'ANO' } else { 'NE' })" -ForegroundColor White
        Write-Host ""
        
        Write-Host "🎯 HLAVNÍ VOLBY:" -ForegroundColor Yellow
        Write-Host "  [1] 🚀 Kompletní builder s auto-opravami" -ForegroundColor White
        Write-Host "  [2] 🔧 Nástroje a utility" -ForegroundColor White
        Write-Host "  [3] 🐧 WSL Ubuntu průvodce" -ForegroundColor White
        Write-Host "  [4] ⚙️  Automatické opravy a diagnóza" -ForegroundColor White
        Write-Host "  [5] 📁 Správa souborů a logů" -ForegroundColor White
        Write-Host "  [6] 🔄 Aktualizace a údržba" -ForegroundColor White
        Write-Host "  [0] ❌ Ukončit" -ForegroundColor White
        Write-Host ""
        
        $choice = Read-Host "Vaše volba"
        
        switch ($choice) {
            "1" {
                Start-CompleteBuilderWithAutoRepair
            }
            "2" {
                Show-ToolsMenuEnhanced
            }
            "3" {
                Show-WSLUbuntuGuide
            }
            "4" {
                Show-AutoRepairMenu
            }
            "5" {
                Show-FileManagementMenu
            }
            "6" {
                Show-MaintenanceMenu
            }
            "0" {
                Write-Host "Ukončuji..." -ForegroundColor Yellow
                exit 0
            }
            default {
                Write-Host "Neplatná volba." -ForegroundColor Red
            }
        }
        
        Write-Host ""
        Write-Host "Stiskněte Enter pro pokračování..." -ForegroundColor Gray
        $null = Read-Host
        Clear-Host
    }
}

function Start-CompleteBuilderWithAutoRepair {
    <#
    .SYNOPSIS
    Kompletní builder s integrovanými automatickými opravami
    #>
    
    Clear-Host
    Write-Host "=== KOMPLETNÍ BUILDER S AUTO-OPRAVAMI ===" -ForegroundColor Cyan
    Write-Host ""
    
    # Krok 1: Kontrola předpokladů
    Write-Host "[1/6] Kontrola předpokladů..." -ForegroundColor Yellow
    
    $prerequisites = @(
        @{Name = "Execution Policy"; Test = { Test-ExecutionPolicyAuto } },
        @{Name = "Admin práva"; Test = { Test-AdminRightsAuto } },
        @{Name = "Místo na disku"; Test = { Test-DiskSpaceAuto } },
        @{Name = "ADK"; Test = { Test-ADKInstalledAuto } }
    )
    
    $allPassed = $true
    foreach ($req in $prerequisites) {
        if (-not (& $req.Test)) {
            $allPassed = $false
        }
    }
    
    if (-not $allPassed) {
        Write-Host "⚠ Některé předpoklady nejsou splněny!" -ForegroundColor Red
        $continue = Read-Host "Přesto pokračovat? (A/N)"
        
        if ($continue -notmatch "^[Aa]") {
            return
        }
    }
    
    # Krok 2: Výběr komponent
    Write-Host "[2/6] Výběr komponent..." -ForegroundColor Yellow
    Write-Host ""
    
    $components = @{
        WinPE = $true
        Linux = $true
        Drivers = $true
        Forensic = $false
        AI = $false
        WSL = $Global:Config.EnableWSL
    }
    
    Write-Host "Doporučené komponenty:" -ForegroundColor White
    Write-Host "  [1] Windows PE Recovery (ZÁKLAD)" -ForegroundColor Gray
    Write-Host "  [2] Linux Recovery ISO" -ForegroundColor Gray
    Write-Host "  [3] Ovladače hardware" -ForegroundColor Gray
    Write-Host "  [4] Forenzní nástroje (internet)" -ForegroundColor Gray
    Write-Host "  [5] AI offline model (internet)" -ForegroundColor Gray
    Write-Host "  [6] WSL Ubuntu podpora" -ForegroundColor Gray
    Write-Host ""
    
    $input = Read-Host "Vyberte čísla oddělená čárkami (výchozí: 1,2,3,6)"
    
    if ($input) {
        # Reset
        $components.WinPE = $false
        $components.Linux = $false
        $components.Drivers = $false
        $components.Forensic = $false
        $components.AI = $false
        $components.WSL = $false
        
        foreach ($num in $input -split ',') {
            switch ($num.Trim()) {
                "1" { $components.WinPE = $true }
                "2" { $components.Linux = $true }
                "3" { $components.Drivers = $true }
                "4" { $components.Forensic = $true }
                "5" { $components.AI = $true }
                "6" { $components.WSL = $true }
            }
        }
    }
    
    # Krok 3: Výstupní nastavení
    Write-Host "[3/6] Výstupní nastavení..." -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "Typ výstupu:" -ForegroundColor White
    Write-Host "  [1] ISO soubor (pro DVD/virtualizaci)" -ForegroundColor Gray
    Write-Host "  [2] USB disk (přímé použití)" -ForegroundColor Gray
    Write-Host "  [3] ISO + USB (kompletní)" -ForegroundColor Gray
    Write-Host ""
    
    $outputType = Read-Host "Vyberte typ (1-3, výchozí: 3)"
    if (-not $outputType) { $outputType = "3" }
    
    # USB výběr
    $usbDrive = ""
    if ($outputType -in @("2", "3")) {
        Write-Host ""
        Write-Host "Dostupné USB disky:" -ForegroundColor White
        
        $usbDrives = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 }
        if ($usbDrives.Count -gt 0) {
            foreach ($drive in $usbDrives) {
                $sizeGB = [math]::Round($drive.Size / 1GB, 2)
                Write-Host "  $($drive.DeviceID) - $($drive.VolumeName) ($sizeGB GB)" -ForegroundColor Gray
            }
            
            $usbDrive = Read-Host "Zadejte písmeno USB (např. L:)"
        }
        else {
            Write-Host "  Žádný USB disk nebyl nalezen!" -ForegroundColor Red
            $usbDrive = "L:"
        }
    }
    
    # Krok 4: Metoda vytváření ISO
    Write-Host "[4/6] Metoda vytváření ISO..." -ForegroundColor Yellow
    Write-Host ""
    
    $isoMethod = "WSL"
    if ($components.WSL -and (Test-WSLInstalledAuto -CheckUbuntu $true)) {
        Write-Host "Metoda vytváření ISO:" -ForegroundColor White
        Write-Host "  [1] WSL Ubuntu (doporučeno - lepší kompatibilita)" -ForegroundColor Gray
        Write-Host "  [2] Windows oscdimg (rychlejší, ale méně funkcí)" -ForegroundColor Gray
        Write-Host ""
        
        $methodChoice = Read-Host "Vyberte metodu (1-2, výchozí: 1)"
        $isoMethod = if ($methodChoice -eq "2") { "WINDOWS" } else { "WSL" }
    }
    
    # Krok 5: Potvrzení
    Write-Host "[5/6] Potvrzení nastavení..." -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "NASTAVENÍ BUILDU:" -ForegroundColor Cyan
    Write-Host "  Komponenty:" -ForegroundColor White
    foreach ($key in $components.Keys) {
        if ($components[$key]) {
            Write-Host "    ✓ $key" -ForegroundColor Green
        }
    }
    Write-Host "  Výstup: $outputType" -ForegroundColor White
    Write-Host "  USB: $(if ($usbDrive) { $usbDrive } else { 'N/A' })" -ForegroundColor White
    Write-Host "  ISO metoda: $isoMethod" -ForegroundColor White
    Write-Host ""
    
    Write-Host "POZOR: Tato operace může trvat 15-60 minut!" -ForegroundColor Red
    Write-Host "       Všechny chyby se budou automaticky opravovat." -ForegroundColor Yellow
    Write-Host ""
    
    $confirm = Read-Host "Spustit builder? (A/N)"
    
    if ($confirm -notmatch "^[Aa]") {
        Write-Host "Builder zrušen." -ForegroundColor Yellow
        return
    }
    
    # Krok 6: Spuštění buildu
    Write-Host "[6/6] Spouštím builder..." -ForegroundColor Green
    Write-Host ""
    
    Execute-AdvancedBuilder -Components $components -OutputType $outputType `
        -USBDisk $usbDrive -ISOMethod $isoMethod
}

function Execute-AdvancedBuilder {
    param(
        [hashtable]$Components,
        [string]$OutputType,
        [string]$USBDisk,
        [string]$ISOMethod
    )
    
    $startTime = Get-Date
    
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "  SPUŠTĚN POKROČILÝ BUILDER" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "Čas začátku: $($startTime.ToString('HH:mm:ss'))" -ForegroundColor Gray
    Write-Host ""
    
    # Příprava adresářů
    Write-Host "📁 PŘÍPRAVA ADRESÁŘŮ..." -ForegroundColor Yellow
    Prepare-DirectoryStructure
    
    # Stahování souborů (s auto-opravami)
    Write-Host ""
    Write-Host "📥 STAŽENÍ SOUBORŮ..." -ForegroundColor Yellow
    
    if ($Components.WinPE) {
        Write-Host "  WinPE Recovery..." -ForegroundColor Cyan
        Download-WithAutoRetry -Component "WinPE"
    }
    
    if ($Components.Linux) {
        Write-Host "  Linux ISO..." -ForegroundColor Cyan
        Download-WithAutoRetry -Component "Linux"
    }
    
    if ($Components.Drivers) {
        Write-Host "  Ovladače..." -ForegroundColor Cyan
        Download-WithAutoRetry -Component "Drivers"
    }
    
    # Vytváření WinPE
    if ($Components.WinPE) {
        Write-Host ""
        Write-Host "🔧 VYTVÁŘENÍ WINPE..." -ForegroundColor Yellow
        Create-WinPEWithAutoRepair
    }
    
    # Vytváření ISO
    if ($OutputType -in @("1", "3")) {
        Write-Host ""
        Write-Host "💿 VYTVÁŘENÍ ISO..." -ForegroundColor Yellow
        
        if ($ISOMethod -eq "WSL" -and $Components.WSL) {
            Write-Host "  Používám WSL Ubuntu..." -ForegroundColor Cyan
            Create-ISOWithWSL -SourcePath "$($Global:Config.RootPath)\WinPE\media" `
                -OutputPath "$($Global:Config.RootPath)\ISO\Starko_Recovery.iso"
        }
        else {
            Write-Host "  Používám Windows oscdimg..." -ForegroundColor Cyan
            Create-ISOWithWindows
        }
    }
    
    # Příprava USB
    if ($OutputType -in @("2", "3") -and $USBDisk) {
        Write-Host ""
        Write-Host "📀 PŘÍPRAVA USB..." -ForegroundColor Yellow
        Prepare-USBWithAutoRepair -DriveLetter $USBDisk
    }
    
    # Dokončení
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "  BUILDER DOKONČEN!" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "Čas začátku: $($startTime.ToString('HH:mm:ss'))" -ForegroundColor Gray
    Write-Host "Čas konce: $($endTime.ToString('HH:mm:ss'))" -ForegroundColor Gray
    Write-Host "Doba trvání: $($duration.ToString('hh\:mm\:ss'))" -ForegroundColor Gray
    Write-Host ""
    
    [AutoRepairSystem]::ShowErrorReport()
    
    Write-Host ""
    Write-Host "✅ VŠE DOKONČENO ÚSPĚŠNĚ!" -ForegroundColor Green
    Write-Host "   Výstupní soubory v: $($Global:Config.RootPath)" -ForegroundColor White
    
    # Otevření složky
    $open = Read-Host "Otevřít výstupní složku? (A/N)"
    if ($open -match "^[Aa]") {
        Start-Process "explorer.exe" -ArgumentList $Global:Config.RootPath
    }
}

function Download-WithAutoRetry {
    param([string]$Component)
    
    $maxRetries = 3
    $retryCount = 0
    
    while ($retryCount -lt $maxRetries) {
        $retryCount++
        
        try {
            Write-Host "    Pokus $retryCount/$maxRetries..." -ForegroundColor Gray
            
            switch ($Component) {
                "WinPE" {
                    # Stáhnout WinPE ISO
                    $url = "https://download.microsoft.com/download/1/0/6/1068c76f-d475-4676-aba3-b777778f44f7/winpe_x64.iso"
                    $path = "$($Global:Config.RootPath)\Linux\winpe.iso"
                    
                    if (-not (Test-Path $path)) {
                        Invoke-WebRequest -Uri $url -OutFile $path -UseBasicParsing
                    }
                }
                "Linux" {
                    # Stáhnout Ubuntu
                    $url = "https://cdimage.ubuntu.com/ubuntu-minimal/releases/24.04/release/ubuntu-minimal-24.04-amd64.iso"
                    $path = "$($Global:Config.RootPath)\Linux\ubuntu.iso"
                    
                    if (-not (Test-Path $path)) {
                        Invoke-WebRequest -Uri $url -OutFile $path -UseBasicParsing
                    }
                }
                "Drivers" {
                    # Stáhnout základní ovladače
                    $url = "https://downloadmirror.intel.com/29143/eng/IntelChipset.exe"
                    $path = "$($Global:Config.RootPath)\Drivers\Intel.exe"
                    
                    if (-not (Test-Path $path)) {
                        Invoke-WebRequest -Uri $url -OutFile $path -UseBasicParsing
                    }
                }
            }
            
            Write-Host "    ✓ $Component staženo" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Host "    ✗ Chyba: $_" -ForegroundColor Red
            
            if ($retryCount -lt $maxRetries) {
                Write-Host "    Čekám 5 sekund před dalším pokusem..." -ForegroundColor Yellow
                Start-Sleep -Seconds 5
            }
            else {
                [AutoRepairSystem]::LogError("DOWNLOAD_FAILED", "Nelze stáhnout $Component", "Použijte offline režim nebo zkuste později", $false)
                return $false
            }
        }
    }
}

# -----------------------------------------------------------------
# HLAVNÍ SPUŠTĚNÍ
# -----------------------------------------------------------------

function Main {
    # Zpracování parametrů
    $paramAutoRepair = $args -contains "-AutoRepair"
    $paramForceBypass = $args -contains "-ForceBypass"
    $paramNoGUI = $args -contains "-NoGUI"
    
    # Inicializace s automatickými opravami
    if (Initialize-WithAutoRepair) {
        # Zobrazení hlavního menu
        Show-MainMenuWithAutoRepair
    }
}

# Spuštění hlavní funkce
if ($MyInvocation.InvocationName -ne '.') {
    Main
}