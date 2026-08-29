# STARCORE 36.20E - TERMUX AUTO CONNECT v2
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
$Base = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogDir = Join-Path $Base 'logs'
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$Stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$Log = Join-Path $LogDir ("autoconnect_{0}.log" -f $Stamp)
function Log([string]$Text) { $Text | Tee-Object -FilePath $Log -Append | Write-Host }
function Test-Tcp8022([string]$IP) { try { $r=Test-NetConnection -ComputerName $IP -Port 8022 -WarningAction SilentlyContinue; return [bool]$r.TcpTestSucceeded } catch { return $false } }
function Invoke-TermuxProbe([string]$IP) {
  try {
    $args=@('-p','8022','-o','BatchMode=yes','-o','ConnectTimeout=5','-o','ConnectionAttempts=1','-o','StrictHostKeyChecking=accept-new',("u0_a344@{0}" -f $IP),'printf "STARCORE_TERMUX_OK=YES\nUSER=%s\nHOME=%s\n" "$(whoami)" "$HOME"')
    $out=& ssh.exe @args 2>&1
    return [pscustomobject]@{ExitCode=$LASTEXITCODE;Text=($out -join "`n")}
  } catch { return [pscustomobject]@{ExitCode=999;Text=$_.Exception.Message} }
}
Clear-Host
Log '=============================================================='
Log 'STARCORE 36.20E - TERMUX AUTO CONNECT v2'
Log '=============================================================='
Log (("START: {0}" -f (Get-Date -Format o)))
Log ''
$ssh=Get-Command ssh.exe -ErrorAction SilentlyContinue
if(-not $ssh){ Log 'ERROR: Windows OpenSSH Client (ssh.exe) not found.'; Read-Host 'ENTER to close'; exit 1 }
Log (("SSH: {0}" -f $ssh.Source))
$candidates=New-Object System.Collections.Generic.List[string]
$ts=Get-Command tailscale.exe -ErrorAction SilentlyContinue
$status=@()
if($ts){
  Log 'TAILSCALE: CLI detected'
  $status=@(tailscale.exe status 2>&1)
  foreach($line in $status){ foreach($m in [regex]::Matches([string]$line,'(?<![\d.])100\.(?:6[4-9]|[7-9]\d|1[01]\d)\.\d{1,3}\.\d{1,3}(?![\d.])')){ $ip=$m.Value; if(-not $candidates.Contains($ip)){[void]$candidates.Add($ip)} } }
  foreach($line in $status){ if([string]$line -match '(?i)android|termux|a536b|starcore'){ foreach($m in [regex]::Matches([string]$line,'(?<![\d.])100\.(?:6[4-9]|[7-9]\d|1[01]\d)\.\d{1,3}\.\d{1,3}(?![\d.])')){ $ip=$m.Value; if($candidates.Contains($ip)){[void]$candidates.Remove($ip);[void]$candidates.Insert(0,$ip)} } } }
} else { Log 'TAILSCALE: CLI not found.'; Log 'Using known candidate only; no endpoint is trusted without Termux verification.' }
if(-not $candidates.Contains('100.88.198.109')){[void]$candidates.Add('100.88.198.109')}
Log ''; Log 'CANDIDATE ENDPOINTS:'; foreach($ip in $candidates){Log (("  {0}:8022" -f $ip))}; Log ''
$found=$null
foreach($ip in $candidates){
  Log (("TEST {0}:8022" -f $ip))
  if(-not (Test-Tcp8022 $ip)){Log '  TCP=closed/unreachable';continue}
  Log '  TCP=open'
  $probe=Invoke-TermuxProbe $ip
  Log (("  SSH_EXIT={0}" -f $probe.ExitCode)); Log (("  SSH_OUTPUT={0}" -f $probe.Text))
  if($probe.ExitCode -eq 0 -and $probe.Text -match 'STARCORE_TERMUX_OK=YES' -and $probe.Text -match 'USER=u0_a344'){$found=$ip;break}
  Log '  NOT_VERIFIED_AS_TERMUX'
}
if(-not $found){Log '';Log 'TERMUX_ENDPOINT_NOT_FOUND';Log 'No interactive session was opened to an unverified endpoint.';Log (("LOG: {0}" -f $Log));Log '';Read-Host 'ENTER to close';exit 2}
Log '';Log (("TERMUX VERIFIED: u0_a344@{0}:8022" -f $found));Log 'Opening interactive SSH session...';Log "Type 'exit' inside Termux when finished.";Log ''
& ssh.exe -p 8022 -o ServerAliveInterval=15 -o ServerAliveCountMax=3 -o ConnectTimeout=10 -o ConnectionAttempts=1 -o StrictHostKeyChecking=accept-new (("u0_a344@{0}" -f $found))
$rc=$LASTEXITCODE
Log '';Log (("SSH_SESSION_EXIT_CODE={0}" -f $rc));Log 'SSH session ended. This launcher window remains open.';Log (("LOG: {0}" -f $Log));Read-Host 'ENTER to close'
