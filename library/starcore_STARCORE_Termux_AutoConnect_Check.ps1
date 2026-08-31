Write-Host "=== STARCORE Termux AutoConnect CHECK ==="

Write-Host "`n[1] Tailscale status:"
tailscale status

Write-Host "`n[2] Find Android device:"
tailscale status | Select-String "android" -Context 0,1

Write-Host "`n[3] Test SSH port 8022:"
Test-NetConnection -ComputerName 100.88.198.109 -Port 8022

Write-Host "`n[4] Check autoconnect script path:"
$path = "E:\GIT\STARCORE-ANDROID\STARCORE_Termux_AutoConnect_v3\STARCORE_Termux_AutoConnect_v3.ps1"
Write-Host "Path: $path"
Write-Host ("Exists: {0}" -f (Test-Path $path))

Write-Host "`n[5] ExecutionPolicy:"
Get-ExecutionPolicy -List

Write-Host "`n[6] Parse script:"
try {
    [System.Management.Automation.PSParser]::Tokenize(
        (Get-Content $path -Raw),
        [ref]$null
    ) | Out-Null
    Write-Host "NO PARSE ERRORS"
} catch {
    Write-Host "PARSE ERROR:"
    Write-Host $_
}

Write-Host "`n=== CHECK DONE ==="
