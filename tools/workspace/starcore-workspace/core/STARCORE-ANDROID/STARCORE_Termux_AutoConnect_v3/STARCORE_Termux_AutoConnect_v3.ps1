[CmdletBinding()]
param(
    [string]$AndroidName = "zazen-a53-fatal",
    [string]$AndroidUser = "u0_a344",
    [int]$Port = 8022
)

Write-Host "=== STARCORE Termux AutoConnect v3 ==="

$ts = tailscale status | Select-String $AndroidName -Context 0,1
$ip = ($ts.Context.PostContext | Select-String "100." | ForEach-Object { $_.ToString().Trim().Split()[0] })

if (-not $ip) {
    Write-Host "Android Tailscale IP not found for '$AndroidName'."
    Read-Host "ENTER to close"
    exit
}

Write-Host "Android IP detected: $ip"

Write-Host "Testing SSH on $ip:$Port..."
$test = Test-NetConnection -ComputerName $ip -Port $Port -WarningAction SilentlyContinue

if (-not $test.TcpTestSucceeded) {
    Write-Host "SSH unreachable on $ip:$Port"
    Write-Host "Start SSH on Android Termux: sshd -D -p $Port"
    Read-Host "ENTER to close"
    exit
}

Write-Host "SSH reachable. Opening session..."

$sshCmd = "ssh -p $Port $AndroidUser@$ip 'bash ~/run_starcore_v11.sh; bash'"
Write-Host "Running: $sshCmd"
& $sshCmd

Write-Host "Session closed."
Read-Host "ENTER to close"
