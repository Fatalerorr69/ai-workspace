# ======================================================
# PowerShell GUI Launcher – Upgrade, Tools & Utilities
# ======================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Hlavní okno
$form = New-Object System.Windows.Forms.Form
$form.Text = "PowerShell Control Center"
$form.Size = New-Object System.Drawing.Size(500,400)
$form.StartPosition = "CenterScreen"

# --- Text box pro logy
$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.ScrollBars = "Vertical"
$logBox.Size = New-Object System.Drawing.Size(460,150)
$logBox.Location = New-Object System.Drawing.Point(10,220)
$logBox.ReadOnly = $true
$form.Controls.Add($logBox)

# --- Funkce pro logování
function Log($text){
    $logBox.AppendText("$text`r`n")
    $logBox.Refresh()
}

# --- Tlačítka
$btnUpdate = New-Object System.Windows.Forms.Button
$btnUpdate.Location = New-Object System.Drawing.Point(10,10)
$btnUpdate.Size = New-Object System.Drawing.Size(200,40)
$btnUpdate.Text = "Update System + Modules"
$btnUpdate.Add_Click({
    Log "Spouštím Update-System..."
    try {
        Update-System
        Log "Aktualizace dokončena."
    } catch {
        Log "Chyba: $_"
    }
})
$form.Controls.Add($btnUpdate)

$btnReport = New-Object System.Windows.Forms.Button
$btnReport.Location = New-Object System.Drawing.Point(250,10)
$btnReport.Size = New-Object System.Drawing.Size(200,40)
$btnReport.Text = "Generate System Report"
$btnReport.Add_Click({
    Log "Generuji SysReport..."
    try {
        SysReport
        Log "Report uložen na ploše."
    } catch {
        Log "Chyba: $_"
    }
})
$form.Controls.Add($btnReport)

$btnClean = New-Object System.Windows.Forms.Button
$btnClean.Location = New-Object System.Drawing.Point(10,60)
$btnClean.Size = New-Object System.Drawing.Size(200,40)
$btnClean.Text = "Clean Temp / Cache"
$btnClean.Add_Click({
    Log "Čistím dočasné soubory..."
    try {
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
        Log "Čištění dokončeno."
    } catch {
        Log "Chyba: $_"
    }
})
$form.Controls.Add($btnClean)

$btnTools = New-Object System.Windows.Forms.Button
$btnTools.Location = New-Object System.Drawing.Point(250,60)
$btnTools.Size = New-Object System.Drawing.Size(200,40)
$btnTools.Text = "Launch Tools"
$btnTools.Add_Click({
    Log "Spouštím moduly a utilitky..."
    try {
        Import-Module PSFzf
        Import-Module BurntToast
        Import-Module Posh-Git
        Import-Module oh-my-posh
        Log "Moduly spuštěny."
    } catch {
        Log "Chyba: $_"
    }
})
$form.Controls.Add($btnTools)

# --- Další tlačítka lze přidat zde (vlastní utility)

# --- Zobrazení GUI
$form.Topmost = $true
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()
