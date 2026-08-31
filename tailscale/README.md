# Tailscale přístup k workspace

Tento adresář obsahuje nástroje pro snadný přístup k vašemu pracovnímu prostředí přes Tailscale.

## Požadavky
- Nainstalovaný Tailscale na PC i Androidu.
- Přihlášení stejným účtem na obou zařízeních.
- Znalost IP adresy PC v Tailnetu (spustit check_tailscale.ps1).

## Rychlý přístup k souborům
1. Spusťte webový server v adresáři `ai-workspace`:
   `.\tailscale\start_http_server.ps1`
2. Na Androidu otevřete prohlížeč a zadejte:
   `http://<IP_ADRESA>:8000`

## SSH přístup
1. Ujistěte se, že na PC běží OpenSSH Server.
2. Z Termuxu se připojte: `ssh <uživatel>@<IP_ADRESA>`

## Automatizace s GitHubem
Workflow `tailscale-oidc.yml` v `.github/workflows/` umožňuje GitHub Actions přistupovat k Tailscale API.
