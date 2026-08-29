function New-StarcoreOSInstaller {
    [CmdletBinding()]
    param(
        [array]$Projects,
        [string]$Root = "E:\Git"
    )

    $installerDir = Join-Path $Root "starcore_installer"
    New-Item -ItemType Directory -Force -Path $installerDir | Out-Null

    # Windows installer script
    $winInstaller = Join-Path $installerDir "install_starcore_windows.ps1"
    @"
Write-Host 'Installing Starcore OS Workspace...'
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
New-Item -ItemType Directory -Force -Path 'C:\Starcore' | Out-Null
"@ | Set-Content $winInstaller -Encoding UTF8

    # Termux installer script
    $termuxInstaller = Join-Path $installerDir "install_starcore_termux.sh"
    @"
#!/data/data/com.termux/files/usr/bin/bash
set -e
mkdir -p \$HOME/starcore
cd \$HOME/starcore
echo 'Starcore OS Termux installer ready.'
"@ | Set-Content $termuxInstaller -Encoding UTF8

    # Linux installer script
    $linuxInstaller = Join-Path $installerDir "install_starcore_linux.sh"
    @"
#!/bin/bash
set -e
sudo mkdir -p /opt/starcore
echo 'Starcore OS Linux installer ready.'
"@ | Set-Content $linuxInstaller -Encoding UTF8

    return $installerDir
}

Export-ModuleMember -Function New-StarcoreOSInstaller
