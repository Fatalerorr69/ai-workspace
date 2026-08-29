# =========================================================
# Starko.SystemToolsProExtreme – FULL SYSTEM + ANDROID GUI
# =========================================================

# ------------------------------
# 1) PATH a profil
# ------------------------------
function Set-StarkoEnvironment {
    $paths = @(
        "$env:ProgramFiles\PowerShell\7",
        "$env:ProgramFiles\Git\bin",
        "$env:ProgramFiles\dotnet",
        "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps"
    )
    foreach ($p in $paths) {
        if ($env:PATH -notlike "*$p*") { [System.Environment]::SetEnvironmentVariable("PATH","$env:PATH;$p","User") }
    }
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
}

# ------------------------------
# 2) System Update & Modules
# ------------------------------
function Update-System {
    Write-Host "[i] Spouštím kompletní update systému…" -ForegroundColor Green
    Set-StarkoEnvironment
    winget upgrade --all --silent --accept-source-agreements --accept-package-agreements
    Write-Host "[OK] Update dokončen."
}

# ------------------------------
# 3) SysReport
# ------------------------------
function SysReport {
    Write-Host "[i] Generuji systémový report…" -ForegroundColor Cyan
    $report = [PSCustomObject]@{
        Date = Get-Date
        Hostname = $env:COMPUTERNAME
        User = $env:USERNAME
        OS = (Get-CimInstance Win32_OperatingSystem).Caption
        Version = (Get-CimInstance Win32_OperatingSystem).Version
        PSVersion = $PSVersionTable.PSVersion
        ExecutionPolicy = Get-ExecutionPolicy
        Modules = (Get-InstalledModule | Select-Object Name, Version)
        WSL = (wsl -l -v)
        AndroidDevices = (& adb devices) -join ", "
    }
    $report | ConvertTo-Json -Depth 5 | Out-File "$env:USERPROFILE\Desktop\SysReport.json"
    $report | Format-List
    Write-Host "[OK] Report uložen na plochu."
}

# ------------------------------
# 4) Android Toolkit GUI
# ------------------------------
function Android-Toolkit {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Starko Android Toolkit"
    $form.Size = New-Object System.Drawing.Size(700,500)
    $form.StartPosition = "CenterScreen"

    # Log box
    $logBox = New-Object System.Windows.Forms.TextBox
    $logBox.Multiline=$true; $logBox.ScrollBars="Vertical"; $logBox.Size=(New-Object System.Drawing.Size(660,300))
    $logBox.Location=(New-Object System.Drawing.Point(10,180)); $logBox.ReadOnly=$true
    $form.Controls.Add($logBox)
    function Log($text){ $logBox.AppendText("$text`r`n"); $logBox.Refresh() }

    # Tlačítka
    $btnDetect = New-Object System.Windows.Forms.Button
    $btnDetect.Location=(New-Object System.Drawing.Point(10,10)); $btnDetect.Size=(New-Object System.Drawing.Size(320,40))
    $btnDetect.Text="Detekce Android zařízení"
    $btnDetect.Add_Click({ Log "Detekce zařízení…"; Log (& adb devices) })
    $form.Controls.Add($btnDetect)

    $btnInstallAPK = New-Object System.Windows.Forms.Button
    $btnInstallAPK.Location=(New-Object System.Drawing.Point(350,10)); $btnInstallAPK.Size=(New-Object System.Drawing.Size(320,40))
    $btnInstallAPK.Text="Instalace APK"
    $btnInstallAPK.Add_Click({
        $apk = (New-Object System.Windows.Forms.OpenFileDialog)
        $apk.Filter="APK files|*.apk"
        if($apk.ShowDialog() -eq "OK") { Log "Instaluji $($apk.FileName)…"; adb install -r $apk.FileName | ForEach-Object { Log $_ } }
    })
    $form.Controls.Add($btnInstallAPK)

    $btnLogcat = New-Object System.Windows.Forms.Button
    $btnLogcat.Location=(New-Object System.Drawing.Point(10,60)); $btnLogcat.Size=(New-Object System.Drawing.Size(320,40))
    $btnLogcat.Text="Live Logcat"
    $btnLogcat.Add_Click({ Start-Process "powershell" -ArgumentList "adb logcat" })
    $form.Controls.Add($btnLogcat)

    $btnRootCheck = New-Object System.Windows.Forms.Button
    $btnRootCheck.Location=(New-Object System.Drawing.Point(350,60)); $btnRootCheck.Size=(New-Object System.Drawing.Size(320,40))
    $btnRootCheck.Text="Root/Magisk Check"
    $btnRootCheck.Add_Click({ Log "Kontrola rootu…"; Log ((adb shell su -c 'id') 2>&1) })
    $form.Controls.Add($btnRootCheck)

    $btnOTA = New-Object System.Windows.Forms.Button
    $btnOTA.Location=(New-Object System.Drawing.Point(10,110)); $btnOTA.Size=(New-Object System.Drawing.Size(660,40))
    $btnOTA.Text="OTA Upgrade zařízení"
    $btnOTA.Add_Click({ Log "Simuluji OTA upgrade (stub)…" })
    $form.Controls.Add($btnOTA)

    $form.Topmost=$true
    [void]$form.ShowDialog()
}

# ------------------------------
# 5) CLI Starko
# ------------------------------
function starko {
    param([string]$Command)
    switch ($Command) {
        "update" { Update-System }
        "report" { SysReport }
        "android" { Android-Toolkit }
        default { Write-Host "starko CLI – příkazy: update, report, android" }
    }
}

# ------------------------------
# 6) Automatický start GUI
# ------------------------------
function Launch-GUI { Android-Toolkit }

# ------------------------------
# 7) Export funkcí
# ------------------------------
Export-ModuleMember -Function Update-System,SysReport,Android-Toolkit,starko,Launch-GUI
