$ErrorActionPreference='Stop'
$Base=Split-Path -Parent $MyInvocation.MyCommand.Path
$Ps1=Join-Path $Base 'STARCORE_36.20E_TERMUX_AUTOCONNECT.ps1'
$Icon=Join-Path $Base 'STARCORE_Termux.ico'
$Desktop=[Environment]::GetFolderPath('Desktop')
$Lnk=Join-Path $Desktop 'STARCORE 36.20E - CONNECT TERMUX.lnk'
$Wsh=New-Object -ComObject WScript.Shell
$S=$Wsh.CreateShortcut($Lnk)
$S.TargetPath='powershell.exe'
$S.Arguments='-NoLogo -NoProfile -ExecutionPolicy Bypass -NoExit -File "'+$Ps1+'"'
$S.WorkingDirectory=$Base
if(Test-Path $Icon){$S.IconLocation=$Icon}
$S.Description='STARCORE 36.20E - automatically discover and connect to verified Termux over SSH'
$S.Save()
Write-Host ''
Write-Host 'ICON CREATED:' -ForegroundColor Green
Write-Host $Lnk
Write-Host ''
Write-Host 'Double-click the icon to discover and connect to Termux.'
Write-Host 'PowerShell stays open on success or failure.'
Read-Host 'ENTER to close setup'
