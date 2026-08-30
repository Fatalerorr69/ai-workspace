# Zkontroluje Tailscale a vypíše IP adresu
if (-not (Get-Command tailscale -ErrorAction SilentlyContinue)) {
    Write-Warning "Tailscale není nainstalován. Nainstalujte z https://tailscale.com/download"
    exit 1
}
$status = tailscale status
Write-Host $status
$ip = tailscale ip -4
Write-Host "`nVaše Tailscale IPv4 adresa: $ip" -ForegroundColor Green
Write-Host "Použijte tuto IP pro přístup z jiných zařízení." -ForegroundColor Yellow
