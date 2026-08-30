# Průvodce pro propojení GitHubu s Tailscale
Write-Host "=== Propojení GitHubu s Tailscale ===" -ForegroundColor Magenta
Write-Host ""

Write-Host "1) Pro přihlašování uživatelů přes GitHub (SSO):" -ForegroundColor Cyan
Write-Host "   - Jděte do Tailscale admin konzole: https://login.tailscale.com/admin/settings/users"
Write-Host "   - V části 'User & device settings' -> 'Identity provider' vyberte GitHub."
Write-Host "   - Postupujte dle pokynů pro OAuth aplikaci."
Write-Host ""

Write-Host "2) Pro GitHub Actions (OIDC klient):" -ForegroundColor Cyan
Write-Host "   - Máte OIDC klienta: T29tHmSAwL11CNTRL-k9JnWP9GKD11CNTRL"
Write-Host "   - V GitHub repozitáři přidejte secrets:"
Write-Host "       TAILSCALE_CLIENT_ID = T29tHmSAwL11CNTRL-k9JnWP9GKD11CNTRL"
Write-Host "       TAILSCALE_CLIENT_SECRET = <váš_client_secret>"
Write-Host "   - Secrets přidáte v Settings -> Secrets and variables -> Actions."
Write-Host ""
Write-Host "Vzorový workflow je v souboru github_oidc_workflow.yml" -ForegroundColor Yellow
