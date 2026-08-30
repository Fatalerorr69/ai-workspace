# Zkontroluje stav SSH serveru
$sshService = Get-Service sshd -ErrorAction SilentlyContinue
if ($sshService -and $sshService.Status -eq 'Running') {
    Write-Host "SSH server běží. IP: $(tailscale ip -4)" -ForegroundColor Green
} else {
    Write-Warning "SSH server neběží. Povolte OpenSSH Server v Nastavení > Aplikace > Volitelné funkce."
    Write-Host "Spusťte: Start-Service sshd" -ForegroundColor Yellow
}
