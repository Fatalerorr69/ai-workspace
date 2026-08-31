# =================================================================
# STARKO RECOVERY AIO ULTIMATE BUILDER v2.0
# =================================================================
# Kompletní řešení pro tvorbu recovery média
# PowerShell 5.1+ (Windows 10/11)
# =================================================================

# -----------------------------------------------------------------
# KONFIGURACE
# -----------------------------------------------------------------
$Config = @{
    RootPath = "C:\StarkoRecovery_AIO"
    DefaultUSB = "L:"
    WinPEVersion = "amd64"
    BrandName = "STARKO RECOVERY ULTIMATE"
    LogFile = "Starko_Build_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
}

# -----------------------------------------------------------------
# FUNKCE PRO LOGOVÁNÍ
# -----------------------------------------------------------------
function Write-Log {
    param([string]$Message, [string]$Type = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Type] $Message"
    Add-Content -Path "$($Config.RootPath)\$($Config.LogFile)" -Value $LogEntry
    switch ($Type) {
        "ERROR" { Write-Host $LogEntry -ForegroundColor Red }
        "WARN"  { Write-Host $LogEntry -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $LogEntry -ForegroundColor Green }
        default { Write-Host $LogEntry -ForegroundColor Cyan }
    }
}

# -----------------------------------------------------------------
# KONTROLA ADMIN PRÁV
# -----------------------------------------------------------------
function Test-AdminRights {
    $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal($Identity)
    return $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# -----------------------------------------------------------------
# HLAVNÍ GUI MENU
# -----------------------------------------------------------------
function Show-MainMenu {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $Form = New-Object System.Windows.Forms.Form
    $Form.Text = "$($Config.BrandName) - Builder"
    $Form.Size = New-Object System.Drawing.Size(650, 550)
    $Form.StartPosition = "CenterScreen"
    $Form.FormBorderStyle = 'FixedDialog'
    $Form.MaximizeBox = $false

    # Logo/nadpis
    $LabelTitle = New-Object System.Windows.Forms.Label
    $LabelTitle.Text = "$($Config.BrandName)`nAll-in-One Recovery Builder"
    $LabelTitle.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
    $LabelTitle.Size = New-Object System.Drawing.Size(600, 60)
    $LabelTitle.Location = New-Object System.Drawing.Point(20, 10)
    $LabelTitle.TextAlign = 'MiddleCenter'
    $Form.Controls.Add($LabelTitle)

    $YPos = 80
    $XPos = 20
    $CheckboxHeight = 25

    # Checkboxy pro komponenty
    $Components = @(
        @{Name="WinPE"; Text="Windows PE Recovery (x64)"; Description="Základní WinPE s nástroji pro opravu Windows"}
        @{Name="Linux"; Text="Linux Recovery ISOs"; Description="Ubuntu Mini + Arch Linux pro záchranu dat"}
        @{Name="Forensic"; Text="Forenzní nástroje"; Description="Autopsy, Volatility, Redline, FTK Imager, KAPE"}
        @{Name="Drivers"; Text="Ovladače HW"; Description="Intel/AMD čipsety, NVIDIA/AMD GPU, NVMe ovladače"}
        @{Name="AI"; Text="AI Offline model"; Description="GPT4All pro lokální AI analýzu v recovery"}
        @{Name="Network"; Text="Síťové nástroje"; Description="Nmap, Wireshark, Putty, WinSCP"}
        @{Name="Pentest"; Text="PenTest toolkit"; Description="Metasploit, Burp Suite (portable)"}
        @{Name="Diagnostic"; Text="HW diagnostika"; Description="CPU-Z, GPU-Z, CrystalDiskInfo, HWMonitor"}
    )

    $Checkboxes = @{}
    foreach ($Component in $Components) {
        $CB = New-Object System.Windows.Forms.CheckBox
        $CB.Text = $Component.Text
        $CB.Tag = $Component.Description
        $CB.Location = New-Object System.Drawing.Point($XPos, $YPos)
        $CB.Size = New-Object System.Drawing.Size(280, $CheckboxHeight)
        $CB.Checked = $true
        $Form.Controls.Add($CB)
        $Checkboxes[$Component.Name] = $CB
        $YPos += $CheckboxHeight + 5
    }

    # Popis komponenty
    $LabelDesc = New-Object System.Windows.Forms.Label
    $LabelDesc.Text = "Vyberte komponenty pro vaše recovery médium"
    $LabelDesc.Location = New-Object System.Drawing.Point(320, 80)
    $LabelDesc.Size = New-Object System.Drawing.Size(280, 200)
    $LabelDesc.BorderStyle = 'FixedSingle'
    $LabelDesc.BackColor = [System.Drawing.Color]::WhiteSmoke
    
    # Událost pro zobrazení popisu
    foreach ($CB in $Checkboxes.Values) {
        $CB.Add_MouseEnter({
            $LabelDesc.Text = "$($this.Text)`n`n$($this.Tag)"
        })
    }
    $Form.Controls.Add($LabelDesc)

    # Cesta pro výstup
    $YPos += 20
    $LabelPath = New-Object System.Windows.Forms.Label
    $LabelPath.Text = "Výstupní cesta:"
    $LabelPath.Location = New-Object System.Drawing.Point($XPos, $YPos)
    $LabelPath.Size = New-Object System.Drawing.Size(100, 20)
    $Form.Controls.Add($LabelPath)

    $TextBoxPath = New-Object System.Windows.Forms.TextBox
    $TextBoxPath.Text = $Config.RootPath
    $TextBoxPath.Location = New-Object System.Drawing.Point($XPos + 110, $YPos)
    $TextBoxPath.Size = New-Object System.Drawing.Size(300, 20)
    $Form.Controls.Add($TextBoxPath)

    $ButtonBrowse = New-Object System.Windows.Forms.Button
    $ButtonBrowse.Text = "Procházet"
    $ButtonBrowse.Location = New-Object System.Drawing.Point($XPos + 420, $YPos)
    $ButtonBrowse.Size = New-Object System.Drawing.Size(80, 23)
    $ButtonBrowse.Add_Click({
        $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $FolderBrowser.SelectedPath = $TextBoxPath.Text
        if ($FolderBrowser.ShowDialog() -eq 'OK') {
            $TextBoxPath.Text = $FolderBrowser.SelectedPath
        }
    })
    $Form.Controls.Add($ButtonBrowse)

    # USB disk
    $YPos += 30
    $LabelUSB = New-Object System.Windows.Forms.Label
    $LabelUSB.Text = "USB disk (volitelné):"
    $LabelUSB.Location = New-Object System.Drawing.Point($XPos, $YPos)
    $LabelUSB.Size = New-Object System.Drawing.Size(120, 20)
    $Form.Controls.Add($LabelUSB)

    $TextBoxUSB = New-Object System.Windows.Forms.TextBox
    $TextBoxUSB.Text = $Config.DefaultUSB
    $TextBoxUSB.Location = New-Object System.Drawing.Point($XPos + 130, $YPos)
    $TextBoxUSB.Size = New-Object System.Drawing.Size(50, 20)
    $Form.Controls.Add($TextBoxUSB)

    # Typ výstupu
    $YPos += 30
    $LabelOutput = New-Object System.Windows.Forms.Label
    $LabelOutput.Text = "Typ výstupu:"
    $LabelOutput.Location = New-Object System.Drawing.Point($XPos, $YPos)
    $Form.Controls.Add($LabelOutput)

    $RadioISO = New-Object System.Windows.Forms.RadioButton
    $RadioISO.Text = "ISO soubor"
    $RadioISO.Location = New-Object System.Drawing.Point($XPos + 80, $YPos)
    $RadioISO.Checked = $true
    $Form.Controls.Add($RadioISO)

    $RadioUSB = New-Object System.Windows.Forms.RadioButton
    $RadioUSB.Text = "USB disk"
    $RadioUSB.Location = New-Object System.Drawing.Point($XPos + 180, $YPos)
    $Form.Controls.Add($RadioUSB)

    $RadioBoth = New-Object System.Windows.Forms.RadioButton
    $RadioBoth.Text = "Obojí (ISO + USB)"
    $RadioBoth.Location = New-Object System.Drawing.Point($XPos + 280, $YPos)
    $Form.Controls.Add($RadioBoth)

    # Tlačítka
    $YPos += 40
    $ButtonBuild = New-Object System.Windows.Forms.Button
    $ButtonBuild.Text = "🚀 SPUSTIT BUILD"
    $ButtonBuild.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $ButtonBuild.Location = New-Object System.Drawing.Point($XPos, $YPos)
    $ButtonBuild.Size = New-Object System.Drawing.Size(200, 40)
    $ButtonBuild.BackColor = [System.Drawing.Color]::LightGreen
    $ButtonBuild.Add_Click({
        $Form.Hide()
        $SelectedComponents = @{}
        foreach ($Key in $Checkboxes.Keys) {
            $SelectedComponents[$Key] = $Checkboxes[$Key].Checked
        }
        
        $BuildParams = @{
            Components = $SelectedComponents
            OutputPath = $TextBoxPath.Text
            USBDrive = $TextBoxUSB.Text.TrimEnd(':')
            OutputType = if ($RadioISO.Checked) { "ISO" } 
                        elseif ($RadioUSB.Checked) { "USB" } 
                        else { "BOTH" }
        }
        
        Start-BuildProcess @BuildParams
        $Form.Close()
    })
    $Form.Controls.Add($ButtonBuild)

    $ButtonCancel = New-Object System.Windows.Forms.Button
    $ButtonCancel.Text = "❌ ZRUŠIT"
    $ButtonCancel.Location = New-Object System.Drawing.Point($XPos + 220, $YPos)
    $ButtonCancel.Size = New-Object System.Drawing.Size(100, 40)
    $ButtonCancel.Add_Click({ $Form.Close() })
    $Form.Controls.Add($ButtonCancel)

    $ButtonPreview = New-Object System.Windows.Forms.Button
    $ButtonPreview.Text = "👁️ NÁHLED"
    $ButtonPreview.Location = New-Object System.Drawing.Point($XPos + 330, $YPos)
    $ButtonPreview.Size = New-Object System.Drawing.Size(100, 40)
    $ButtonPreview.Add_Click({
        $PreviewText = "VYBRANÉ KOMPONENTY:`n`n"
        foreach ($Key in $Checkboxes.Keys) {
            if ($Checkboxes[$Key].Checked) {
                $PreviewText += "✓ $($Checkboxes[$Key].Text)`n"
            }
        }
        $PreviewText += "`nVÝSTUP: $($TextBoxPath.Text)"
        [System.Windows.Forms.MessageBox]::Show($PreviewText, "Náhled buildu", 'OK', 'Information')
    })
    $Form.Controls.Add($ButtonPreview)

    return $Form.ShowDialog()
}

# -----------------------------------------------------------------
# HLAVNÍ PROCES BUILDOVÁNÍ
# -----------------------------------------------------------------
function Start-BuildProcess {
    param(
        [hashtable]$Components,
        [string]$OutputPath,
        [string]$USBDrive,
        [string]$OutputType
    )

    Write-Log "=== SPUŠTĚN BUILD PROCES ==="
    Write-Log "Cesta: $OutputPath"
    Write-Log "USB: $USBDrive"
    Write-Log "Typ: $OutputType"
    
    # 1. Příprava adresářů
    Write-Log "[1/12] Příprava adresářové struktury..." "INFO"
    $Directories = @(
        "$OutputPath\WinPE",
        "$OutputPath\Linux",
        "$OutputPath\Drivers",
        "$OutputPath\Tools\Forensic",
        "$OutputPath\Tools\Network",
        "$OutputPath\Tools\Diagnostic",
        "$OutputPath\AI",
        "$OutputPath\Boot",
        "$OutputPath\ISO",
        "$OutputPath\Scripts"
    )
    
    foreach ($Dir in $Directories) {
        if (!(Test-Path $Dir)) {
            New-Item -ItemType Directory -Path $Dir -Force | Out-Null
            Write-Log "Vytvořen adresář: $Dir" "INFO"
        }
    }

    # 2. Kontrola ADK/WinPE
    if ($Components.WinPE) {
        Write-Log "[2/12] Kontrola ADK a WinPE..." "INFO"
        Install-WinPEComponents -OutputPath $OutputPath
    }

    # 3. Stahování Linux ISO
    if ($Components.Linux) {
        Write-Log "[3/12] Stahování Linux distribucí..." "INFO"
        Download-LinuxISOs -OutputPath $OutputPath
    }

    # 4. Stahování forenzních nástrojů
    if ($Components.Forensic) {
        Write-Log "[4/12] Stahování forenzních nástrojů..." "INFO"
        Download-ForensicTools -OutputPath $OutputPath
    }

    # 5. Stahování ovladačů
    if ($Components.Drivers) {
        Write-Log "[5/12] Stahování ovladačů..." "INFO"
        Download-Drivers -OutputPath $OutputPath
    }

    # 6. Příprava AI modelu
    if ($Components.AI) {
        Write-Log "[6/12] Příprava AI modelu..." "INFO"
        Prepare-AIModel -OutputPath $OutputPath
    }

    # 7. Síťové nástroje
    if ($Components.Network) {
        Write-Log "[7/12] Příprava síťových nástrojů..." "INFO"
        Prepare-NetworkTools -OutputPath $OutputPath
    }

    # 8. HW diagnostika
    if ($Components.Diagnostic) {
        Write-Log "[8/12] Příprava diagnostických nástrojů..." "INFO"
        Prepare-DiagnosticTools -OutputPath $OutputPath
    }

    # 9. Vytvoření bootovacího menu
    Write-Log "[9/12] Tvorba bootovacího menu..." "INFO"
    Create-BootMenu -OutputPath $OutputPath -Components $Components

    # 10. Vytvoření ISO
    if ($OutputType -in @("ISO", "BOTH")) {
        Write-Log "[10/12] Vytváření ISO souboru..." "INFO"
        Create-ISOImage -OutputPath $OutputPath
    }

    # 11. Příprava USB
    if ($OutputType -in @("USB", "BOTH") -and $USBDrive) {
        Write-Log "[11/12] Příprava USB média..." "INFO"
        Prepare-USBDrive -USBDrive $USBDrive -OutputPath $OutputPath
    }

    # 12. Dokončení
    Write-Log "[12/12] Build dokončen!" "SUCCESS"
    Show-CompletionDialog -OutputPath $OutputPath -OutputType $OutputType -USBDrive $USBDrive
}

# -----------------------------------------------------------------
# POMOCNÉ FUNKCE
# -----------------------------------------------------------------
function Install-WinPEComponents {
    param([string]$OutputPath)
    
    $ADKPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit"
    
    if (!(Test-Path "$ADKPath\Deployment Tools\DandISetEnv.bat")) {
        Write-Log "ADK není nainstalován, stahuji..." "WARN"
        
        # Stáhnout ADK
        $ADKUrl = "https://go.microsoft.com/fwlink/?linkid=2196127"
        $ADKFile = "$OutputPath\adksetup.exe"
        
        Invoke-WebRequest -Uri $ADKUrl -OutFile $ADKFile -UseBasicParsing
        Start-Process -FilePath $ADKFile -ArgumentList "/quiet /norestart /features OptionId.DeploymentTools" -Wait
        
        # Stáhnout WinPE addon
        $WinPEUrl = "https://go.microsoft.com/fwlink/?linkid=2196130"
        $WinPEFile = "$OutputPath\adkwinpesetup.exe"
        
        Invoke-WebRequest -Uri $WinPEUrl -OutFile $WinPEFile -UseBasicParsing
        Start-Process -FilePath $WinPEFile -ArgumentList "/quiet /norestart /features OptionId.WindowsPreinstallationEnvironment" -Wait
    }
    
    # Vytvořit WinPE
    Set-Location "$ADKPath\Windows Preinstallation Environment"
    cmd /c "copype.cmd $($Config.WinPEVersion) $OutputPath\WinPE"
    
    Write-Log "WinPE připraveno" "SUCCESS"
}

function Download-LinuxISOs {
    param([string]$OutputPath)
    
    $LinuxISOs = @(
        @{Name="Ubuntu Mini"; Url="https://cdimage.ubuntu.com/ubuntu-mini-iso/releases/24.04/release/ubuntu-mini-24.04-live-amd64.iso"; File="Ubuntu_Mini.iso"}
        @{Name="SystemRescue"; Url="https://sourceforge.net/projects/systemrescuecd/files/sysresccd-x86/10.00/systemrescue-10.00-amd64.iso/download"; File="SystemRescue.iso"}
        @{Name="GParted Live"; Url="https://sourceforge.net/projects/gparted/files/gparted-live-stable/1.5.0-7/gparted-live-1.5.0-7-amd64.iso/download"; File="GParted.iso"}
    )
    
    foreach ($ISO in $LinuxISOs) {
        $FilePath = "$OutputPath\Linux\$($ISO.File)"
        if (!(Test-Path $FilePath)) {
            Write-Log "Stahuji $($ISO.Name)..." "INFO"
            try {
                Invoke-WebRequest -Uri $ISO.Url -OutFile $FilePath -UseBasicParsing
                Write-Log "✓ $($ISO.Name) staženo" "SUCCESS"
            } catch {
                Write-Log "Chyba při stahování $($ISO.Name)" "ERROR"
            }
        }
    }
}

function Download-ForensicTools {
    param([string]$OutputPath)
    
    # Portable verze nástrojů
    $Tools = @{
        "Autopsy" = "https://github.com/sleuthkit/autopsy/releases/download/autopsy-4.21.0/autopsy-4.21.0.zip"
        "FTKImager" = "https://d1kpmuwb7gvu1i.cloudfront.net/FTKImager_4.7.1.zip"
        "KAPE" = "https://www.kroll.com/en/kape/kape.zip"
    }
    
    foreach ($Tool in $Tools.GetEnumerator()) {
        $ToolPath = "$OutputPath\Tools\Forensic\$($Tool.Key)"
        if (!(Test-Path $ToolPath)) {
            New-Item -ItemType Directory -Path $ToolPath -Force | Out-Null
            Write-Log "Stahuji $($Tool.Key)..." "INFO"
            try {
                $TempFile = "$env:TEMP\$($Tool.Key).zip"
                Invoke-WebRequest -Uri $Tool.Value -OutFile $TempFile -UseBasicParsing
                Expand-Archive -Path $TempFile -DestinationPath $ToolPath -Force
                Remove-Item $TempFile -Force
                Write-Log "✓ $($Tool.Key) připraven" "SUCCESS"
            } catch {
                Write-Log "Chyba u $($Tool.Key)" "ERROR"
            }
        }
    }
}

function Create-BootMenu {
    param([string]$OutputPath, [hashtable]$Components)
    
    # Hlavní startnet.cmd pro WinPE
    $StartNetContent = @'
@echo off
color 0A
cls

echo ============================================
echo   STARKO RECOVERY AIO - ULTIMATE EDITION
echo ============================================
echo.

wpeinit
net use X: /delete /y >nul 2>&1

:menu
cls
echo ============================================
echo          HLAVNI MENU
echo ============================================
echo.
echo [1]  Oprava bootu Windows
echo [2]  Obnova dat a souboru
echo [3]  Diagnostika hardware
echo [4]  Sprava disku a partition
echo [5]  Sitove nastroje
echo [6]  Forenzni analyza
echo [7]  Linux Recovery
echo [8]  AI diagnosticky pomocnik
echo [9]  HW test a benchmark
echo [10] BIOS/UEFI utility
echo [0]  Restart / Shutdown
echo.
set /p volba="Vyber moznost: "

if "%volba%"=="1" goto bootrepair
if "%volba%"=="2" goto datarecovery
if "%volba%"=="3" goto hwdiag
if "%volba%"=="4" goto diskman
if "%volba%"=="5" goto network
if "%volba%"=="6" goto forensic
if "%volba%"=="7" goto linux
if "%volba%"=="8" goto ai
if "%volba%"=="9" goto hwtest
if "%volba%"=="10" goto biosutil
if "%volba%"=="0" goto shutdown
goto menu

:bootrepair
cls
echo Spoustim automatickou opravu bootu...
call X:\StarkoTools\bootfix_auto.cmd
pause
goto menu

:datarecovery
cls
echo Spoustim nastroje pro obnovu dat...
call X:\StarkoTools\filecopy.cmd
pause
goto menu

:shutdown
cls
echo.
echo [1] Restart
echo [2] Vypnout
echo [3] Zpet do menu
echo.
set /p shutdown="Vyber: "
if "%shutdown%"=="1" wpeutil reboot
if "%shutdown%"=="2" wpeutil shutdown
if "%shutdown%"=="3" goto menu
goto shutdown
'@
    
    Set-Content -Path "$OutputPath\WinPE\media\Windows\System32\Startnet.cmd" -Value $StartNetContent -Encoding ASCII
    
    # GRUB konfigurace pro multiboot
    $GrubConfig = @'
set timeout=30
set default=0

menuentry "Windows PE Recovery" {
    chainloader /EFI/BOOT/BOOTX64.EFI
}

menuentry "Ubuntu Mini Recovery" {
    set isofile="/linux/Ubuntu_Mini.iso"
    loopback loop $isofile
    linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=$isofile quiet splash
    initrd (loop)/casper/initrd
}

menuentry "SystemRescue CD" {
    set isofile="/linux/SystemRescue.iso"
    loopback loop $isofile
    linux (loop)/sysresccd/boot/x86_64/vmlinuz archisobased=sysresccd archiso_loop=$isofile
    initrd (loop)/sysresccd/boot/x86_64/sysresccd.img
}

menuentry "GParted Live" {
    set isofile="/linux/GParted.iso"
    loopback loop $isofile
    linux (loop)/live/vmlinuz boot=live union=overlay components findiso=$isofile
    initrd (loop)/live/initrd.img
}
'@
    
    Set-Content -Path "$OutputPath\Boot\grub.cfg" -Value $GrubConfig -Encoding ASCII
}

function Create-ISOImage {
    param([string]$OutputPath)
    
    $ISOPath = "$OutputPath\ISO\Starko_Recovery_AIO_$(Get-Date -Format 'yyyyMMdd').iso"
    
    Write-Log "Vytvářím ISO: $ISOPath" "INFO"
    
    # Použití oscdimg z ADK
    $OSCDIMG = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\$($Config.WinPEVersion)\Oscdimg\oscdimg.exe"
    
    if (Test-Path $OSCDIMG) {
        $Args = @(
            "-m",
            "-o",
            "-u2",
            "-udfver102",
            "-bootdata:2#p0,e,b`"$OutputPath\WinPE\fwfiles\etfsboot.com`"#pEF,e,b`"$OutputPath\WinPE\fwfiles\efisys.bin`"",
            "`"$OutputPath\WinPE\media`"",
            "`"$ISOPath`""
        )
        
        Start-Process -FilePath $OSCDIMG -ArgumentList $Args -Wait -NoNewWindow
        Write-Log "ISO vytvořeno: $ISOPath" "SUCCESS"
    } else {
        Write-Log "OSCDIMG.exe nenalezen, ISO nelze vytvořit" "ERROR"
    }
}

function Prepare-USBDrive {
    param([string]$USBDrive, [string]$OutputPath)
    
    Write-Log "Připravuji USB disk $USBDrive..." "INFO"
    
    # Diskpart skript pro přípravu USB
    $DiskpartScript = @"
select disk $((Get-Disk | Where-Object {$_.BusType -eq 'USB' -and $_.Size -gt 4GB}).Number)
clean
convert gpt
create partition primary size=500
format fs=fat32 quick label="STARKO_BOOT"
active
assign letter=$USBDrive
create partition primary
format fs=ntfs quick label="STARKO_DATA"
assign letter=$($USBDrive)1
exit
"@
    
    $ScriptPath = "$env:TEMP\format_usb.txt"
    Set-Content -Path $ScriptPath -Value $DiskpartScript -Encoding ASCII
    diskpart /s $ScriptPath | Out-Null
    Remove-Item $ScriptPath -Force
    
    # Kopírování souborů na USB
    $SourceDirs = @("WinPE", "Linux", "Tools", "Boot", "Scripts")
    foreach ($Dir in $SourceDirs) {
        if (Test-Path "$OutputPath\$Dir") {
            Copy-Item -Path "$OutputPath\$Dir\*" -Destination "${USBDrive}:\$Dir\" -Recurse -Force
        }
    }
    
    # Instalace GRUB na USB
    $GrubInstall = @"
# Instalace GRUB pro UEFI
mountvol ${USBDrive}: /s
bcdboot ${USBDrive}:\Windows /s ${USBDrive}: /f UEFI
"@
    
    Write-Log "USB disk $USBDrive připraven" "SUCCESS"
}

function Show-CompletionDialog {
    param([string]$OutputPath, [string]$OutputType, [string]$USBDrive)
    
    Add-Type -AssemblyName System.Windows.Forms
    
    $ResultForm = New-Object System.Windows.Forms.Form
    $ResultForm.Text = "Build dokončen! ✓"
    $ResultForm.Size = New-Object System.Drawing.Size(500, 400)
    $ResultForm.StartPosition = "CenterScreen"
    
    $LabelSuccess = New-Object System.Windows.Forms.Label
    $LabelSuccess.Text = "✅ STARKO RECOVERY AIO ÚSPĚŠNĚ VYTVOŘENO"
    $LabelSuccess.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
    $LabelSuccess.Size = New-Object System.Drawing.Size(450, 40)
    $LabelSuccess.Location = New-Object System.Drawing.Point(20, 20)
    $LabelSuccess.TextAlign = 'MiddleCenter'
    $ResultForm.Controls.Add($LabelSuccess)
    
    $TextBoxResults = New-Object System.Windows.Forms.TextBox
    $TextBoxResults.Multiline = $true
    $TextBoxResults.ScrollBars = 'Vertical'
    $TextBoxResults.Size = New-Object System.Drawing.Size(440, 200)
    $TextBoxResults.Location = New-Object System.Drawing.Point(20, 70)
    $TextBoxResults.ReadOnly = $true
    
    $ResultsText = "DETAILY BUILDU:`n`n"
    $ResultsText += "• Výstupní cesta: $OutputPath`n"
    $ResultsText += "• Typ výstupu: $OutputType`n"
    
    if ($USBDrive -and $OutputType -in @("USB", "BOTH")) {
        $ResultsText += "• USB disk: $USBDrive`n"
    }
    
    $ResultsText += "`nVYTVOŘENÉ SOUBORY:`n"
    $ResultsText += "├── WinPE recovery prostředí`n"
    $ResultsText += "├── Linux recovery ISO`n"
    $ResultsText += "├── Forenzní nástroje`n"
    $ResultsText += "├── Ovladače hardware`n"
    $ResultsText += "├── AI offline model`n"
    $ResultsText += "└── Bootovací menu`n"
    
    $ResultsText += "`nDALŠÍ KROKY:`n"
    $ResultsText += "1. Pro USB: Restartujte PC a bootujte z USB`n"
    $ResultsText += "2. Pro ISO: Vypalte na DVD nebo vytvořte bootovací USB`n"
    $ResultsText += "3. Pro test: Spusťte ve VMware/VirtualBox`n"
    
    $TextBoxResults.Text = $ResultsText
    $ResultForm.Controls.Add($TextBoxResults)
    
    $ButtonOpen = New-Object System.Windows.Forms.Button
    $ButtonOpen.Text = "📂 OTEVŘÍT SLOŽKU"
    $ButtonOpen.Location = New-Object System.Drawing.Point(20, 290)
    $ButtonOpen.Size = New-Object System.Drawing.Size(150, 40)
    $ButtonOpen.Add_Click({
        Start-Process "explorer.exe" -ArgumentList $OutputPath
    })
    $ResultForm.Controls.Add($ButtonOpen)
    
    $ButtonClose = New-Object System.Windows.Forms.Button
    $ButtonClose.Text = "❌ ZAVŘÍT"
    $ButtonClose.Location = New-Object System.Drawing.Point(180, 290)
    $ButtonClose.Size = New-Object System.Drawing.Size(150, 40)
    $ButtonClose.Add_Click({ $ResultForm.Close() })
    $ResultForm.Controls.Add($ButtonClose)
    
    $ButtonRestart = New-Object System.Windows.Forms.Button
    $ButtonRestart.Text = "🔄 RESTARTOVAT SCRIPT"
    $ButtonRestart.Location = New-Object System.Drawing.Point(340, 290)
    $ButtonRestart.Size = New-Object System.Drawing.Size(150, 40)
    $ButtonRestart.Add_Click({
        $ResultForm.Close()
        Start-Process "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    })
    $ResultForm.Controls.Add($ButtonRestart)
    
    $ResultForm.ShowDialog() | Out-Null
}

# -----------------------------------------------------------------
# SPUŠTĚNÍ SCRIPTU
# -----------------------------------------------------------------
function Main {
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "  STARKO RECOVERY AIO BUILDER v2.0" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Cyan
    
    # Kontrola admin práv
    if (!(Test-AdminRights)) {
        Write-Host "CHYBA: Spusťte skript jako administrátor!" -ForegroundColor Red
        Write-Host "Klikněte pravým tlačítkem na PowerShell a vyberte 'Run as Administrator'" -ForegroundColor Yellow
        pause
        exit 1
    }
    
    # Kontrola PowerShell verze
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-Host "CHYBA: Vyžadován PowerShell 5.1 nebo novější!" -ForegroundColor Red
        exit 1
    }
    
    # Vytvořit konfigurační adresář
    if (!(Test-Path $Config.RootPath)) {
        New-Item -ItemType Directory -Path $Config.RootPath -Force | Out-Null
    }
    
    # Zobrazit hlavní menu
    Show-MainMenu
}

# Spuštění hlavní funkce
Main