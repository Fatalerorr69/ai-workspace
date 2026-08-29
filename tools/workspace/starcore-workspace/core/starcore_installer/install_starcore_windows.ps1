Write-Host 'Installing Starcore OS Workspace...'
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
New-Item -ItemType Directory -Force -Path 'C:\Starcore' | Out-Null
