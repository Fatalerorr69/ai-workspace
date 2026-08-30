# Prompt – Extrakce dokumentace pro automatizaci

**Cíl:** Načíst všechny relevantní dokumenty z repozitáře `ai-workspace` a z externích zdrojů (Tailscale, GitHub Actions) a uložit je jako **strukturovaný přehled** v souboru `ai-workspace/docs/index.json`.

---

## 1. Zdrojové dokumenty (prohledej rekurzivně)

- Všechny `README.md`, `PROJECT_DEFINITION.md`, `PROJECT_ANALYSIS.md` (již opravené).
- Všechny `.github/workflows/*.yml` – extrahuj názvy, triggery, secrets, kroky.
- Všechny `tailscale/*.ps1`, `tailscale/*.md` – extrahuj konfigurační parametry, API klíče (maskované).
- `library/*.ps1`, `library/*.py`, `library/*.js` – extrahuj funkce, proměnné, závislosti.

## 2. Externí dokumentace (stáhni a zpracuj)

- Tailscale API reference: https://tailscale.com/api
- Tailscale ACL syntax: https://tailscale.com/kb/1337/acl-syntax
- GitHub Actions secrets: https://docs.github.com/en/actions/security-guides/encrypted-secrets
- GitHub branch protection: https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches

## 3. Výstupní formát – `ai-workspace/docs/index.json`

```json
{
  "meta": {
    "generated": "YYYY-MM-DDTHH:MM:SSZ",
    "source": "ai-workspace monorepo + externí dokumentace"
  },
  "config": {
    "tailscale": {
      "api_endpoint": "https://api.tailscale.com/api/v2",
      "auth_method": "OIDC + API key",
      "secrets_required": ["TAILSCALE_API_KEY", "TAILSCALE_CLIENT_SECRET"],
      "acl_policy": "tailscale_acl_policy.hujson (soubor v templates/)",
      "dns_config": "tailscale_dns_config.json (soubor v templates/)"
    },
    "github_actions": {
      "workflows": [
        {
          "name": "Security Scan",
          "file": ".github/workflows/security.yml",
          "triggers": ["schedule", "workflow_dispatch", "pull_request"],
          "jobs": ["gitleaks", "dependency-review"],
          "secrets_used": ["GITHUB_TOKEN"]
        }
        // ... další workflow
      ]
    },
    "scripts": {
      "location": "ai-workspace/scripts/",
      "list": [
        {
          "name": "run_migration_v2.ps1",
          "purpose": "Migrace repozitářů do monorepa",
          "dependencies": ["git-filter-repo", "GITHUB_TOKEN"],
          "usage": ".\run_migration_v2.ps1 -Version v2 -MonorepoUrl ..."
        }
        // ... další skripty
      ]
    }
  }
}
