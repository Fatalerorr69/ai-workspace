# 📊 COMPREHENSIVE STARCORE SETUP & REORGANIZATION GUIDE

**Verze:** 3.0 - FULL INTERACTIVE  
**Datum:** 2026-08-23  
**Status:** ⏳ ČEKÁM NA TVOJI ODPOVĚĎ  
**Komplexnost:** Expert Level  

---

## 🎯 MAPA KAPITOL

1. [PHASE 0: SETUP & PŘÍPRAVA](#phase0)
2. [PHASE 1: ARCHITEKTURNÍ ROZHODNUTÍ](#phase1)
3. [PHASE 2: SPRÁVA REPOSITORIÍ](#phase2)
4. [PHASE 3: CI/CD & AUTOMATION](#phase3)
5. [PHASE 4: INTEGRACE & DEPLOYMENT](#phase4)
6. [PHASE 5: PROFIL & BEZPEČNOST](#phase5)

---

## PHASE 0: SETUP & PŘÍPRAVA {#phase0}

### 📍 OTÁZKA 0.1: GitHub Account Setup

**Popis:**
- Kontrola základních nastavení GitHub účtu
- Ověření 2FA, SSH klíčů, PAT (Personal Access Tokens)
- Setup MCP serverů pro Copilot integraci
- Optimalizace GitHub notifikací

**Co se bude dít:**
- Vytvoření/obnova SSH klíčů (github auth ssh)
- Generování Personal Access Token s právy repo + workflow
- Setup GitHub CLI (`gh`) pro automatizaci
- Konfigurace local git (`git config`)

**Dopad na další kroky:** 🔴 KRITICKÉ - bez správného setupu se nic nedá dělat!

---

#### VOLBY:

**A) 🟢 FULL AUTOMATION SETUP (Doporučeno)**
- ✅ Vygenerovat nový SSH key (ED25519)
- ✅ Vygenerovat Personal Access Token (full repo + workflow + admin:org_hook)
- ✅ Instalovat GitHub CLI (`gh`) s autentizací
- ✅ Setup git hooks (pre-commit, pre-push)
- ✅ Konfigurace gpg signing pro commits
- ✅ MCP server integraci (Copilot extensions)

**Příkazy:**
```bash
# SSH Key
ssh-keygen -t ed25519 -C "Fatalerorr69@github.com" -f ~/.ssh/github_ed25519

# GitHub CLI login
gh auth login -h github.com -p ssh -w

# PAT s všemi právy
gh auth refresh -h github.com -s repo,workflow,admin:org_hook,gist

# Git config
git config --global user.name "Jacob Starko"
git config --global user.email "Fatalerorr69@github.com"
git config --global user.signingKey ~/.ssh/github_ed25519
git config --global commit.gpgSign true
git config --global gpg.format ssh

# Instalace GitHub CLI
sudo apt install gh  # Linux
brew install gh      # macOS
```

**Výhody:**
- Automatické operace bez hesla
- Podepsané commity (trust)
- Lepší bezpečnost
- GitHub Actions s auto-auth

**Nevýhody:**
- Mírně složitější setup
- Nutno spravovat SSH klíč
- Heslo do GPG

---

**B) 🟡 BASIC SETUP (Rychlé)**
- ✅ Vygenerovat PAT (personal access token)
- ✅ Konfigurace git s tokenem
- ✅ Základní GitHub CLI
- ❌ Bez SSH keys
- ❌ Bez GPG signing
- ❌ Bez MCP serverů

**Příkazy:**
```bash
# Jen PAT
gh auth login -h github.com

# Git config s PAT
git config --global user.name "Jacob Starko"
git config --global user.email "Fatalerorr69@github.com"

# Instalace GitHub CLI
sudo apt install gh
```

**Výhody:**
- Rychlý setup
- Funguje pro základní operace

**Nevýhody:**
- Bez podpisu commitů
- Méně secure
- Bez automatizace

---

**C) ⚠️ MINIMÁLNÍ SETUP (Jen git)**
- ✅ Jen git s HTTPS
- ✅ Bez GitHub CLI
- ✅ Bez SSH
- ❌ Bez automatizace
- ❌ Ruční zadávání hesla

**Výhody:**
- Nejjednodušší
- Žádné závislosti

**Nevýhody:**
- Pokaždé heslo
- Bez automatizace
- Nejméně secure

---

**D) 🔒 ENTERPRISE SETUP (Maximum Security)**
- ✅ SSH key s passphrase
- ✅ GitHub PAT s krátkou dobou platnosti (7 dní)
- ✅ Hardware security key (Yubikey) - pokud máš
- ✅ GPG signing s HSM
- ✅ MCP server s encryptovanými credencially
- ✅ Audit logging veškerých operací

**Příkazy:**
```bash
# SSH key s passphrase
ssh-keygen -t ed25519 -C "Fatalerorr69@github.com" \
  -f ~/.ssh/github_ed25519 \
  -N "tvoje_passphrase_zde"

# PAT s 7denní expiracií
gh auth refresh -h github.com -s repo,workflow \
  --expiration 7d

# Yubikey integrace (pokud máš)
gpg --card-status
```

**Výhody:**
- Maximum security
- Audit trail
- Compliance ready

**Nevýhody:**
- Složitý setup
- Pokaždé heslo/2FA
- Vyžaduje hardware token

---

**Tvá volba:**
```
[GITHUB-ACCOUNT-SETUP]: A / B / C / D
```

**Poznámka:** Doporučuji **VOLBA A** pro vyvážení bezpečnosti a pohodlí.

---

### 📍 OTÁZKA 0.2: MCP Server Integration

**Popis:**
- Model Context Protocol (MCP) servery pro Copilot
- Umožňují Copilotu číst/psát do souborů, spouštět skripty
- Integrace s GitHub API pro seamless workflow

**Relevantní MCP Servery:**

```
┌─────────────────────────────────────────────────────┐
│ MCP SERVER                  │ FUNKCE               │
├─────────────────────────────────────────────────────┤
│ github-mcp                  │ GitHub API, Issues   │
│ filesystem-mcp              │ Read/Write soubory   │
│ bash-mcp                    │ Spouštění příkazů    │
│ docker-mcp                  │ Docker operace       │
│ git-mcp                     │ Git operations       │
│ environment-mcp             │ Env vars, secrets    │
└─────────────────────────────────────────────────────┘
```

---

**VOLBY:**

**A) 🟢 FULL MCP ECOSYSTEM (Doporučeno)**
- ✅ Instalovat všechny 6 MCP serverů
- ✅ Konfigurovat v Copilot settings
- ✅ Integrovat s GitHub API
- ✅ Setup secret management

**Instalace:**
```bash
# Via npm
npm install -g @modelcontextprotocol/server-github
npm install -g @modelcontextprotocol/server-filesystem
npm install -g @modelcontextprotocol/server-bash
npm install -g @modelcontextprotocol/server-docker
npm install -g @modelcontextprotocol/server-git
npm install -g @modelcontextprotocol/server-environment

# Config soubor ~/.mcp/config.json
{
  "mcpServers": {
    "github": {
      "command": "node",
      "args": ["~/.npm/_npx/*/node_modules/@modelcontextprotocol/server-github/index.js"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}",
        "GITHUB_OWNER": "Fatalerorr69"
      }
    },
    "filesystem": {
      "command": "node",
      "args": ["~/.npm/_npx/*/node_modules/@modelcontextprotocol/server-filesystem/index.js"],
      "env": {
        "FILESYSTEM_ROOT": "/home/user/projects"
      }
    },
    "bash": {
      "command": "node",
      "args": ["~/.npm/_npx/*/node_modules/@modelcontextprotocol/server-bash/index.js"]
    },
    "git": {
      "command": "node",
      "args": ["~/.npm/_npx/*/node_modules/@modelcontextprotocol/server-git/index.js"],
      "env": {
        "GIT_ROOT": "/home/user/projects/STARCORE"
      }
    }
  }
}
```

**Výhody:**
- Copilot ví o všem (files, repos, git)
- Automatizace všech operací
- Context-aware suggestions

**Nevýhody:**
- Více závislostí
- Security risk (token přístup)
- Komplexní konfiguraci

---

**B) 🟡 ESSENTIAL MCP (Vybalancované)**
- ✅ github-mcp (GitHub operace)
- ✅ filesystem-mcp (soubory)
- ✅ git-mcp (git)
- ❌ bash-mcp (bezpečnostní riziko)
- ❌ docker-mcp
- ❌ environment-mcp

**Instalace:**
```bash
npm install -g @modelcontextprotocol/server-github \
  @modelcontextprotocol/server-filesystem \
  @modelcontextprotocol/server-git
```

**Výhody:**
- Poměr bezpečnost/funkcionalita
- Postačuje pro vývoj

**Nevýhody:**
- Bez bash automatizace
- Bez Docker integraci

---

**C) ⚠️ MINIMAL MCP (Jen GitHub)**
- ✅ github-mcp (GitHub API)
- ❌ Nic dalšího

**Výhody:**
- Malé riziko
- Jednoduchý setup

**Nevýhody:**
- Bez file operací
- Bez git integrace
- Méně automatizace

---

**D) 🔒 SELF-HOSTED MCP (Maximum Control)**
- ✅ Vlastní MCP server instance
- ✅ Encryptované kredenciale
- ✅ Audit logging
- ✅ Custom permissions

**Setup:**
```bash
git clone https://github.com/modelcontextprotocol/mcp
cd mcp
npm install
npm run build

# Spustit vlastní server
node server.js --config config.production.json
```

**Výhody:**
- Plná kontrola
- Audit trail
- Encryptace na disku

**Nevýhody:**
- Vyžaduje server
- Náročnější maintenance

---

**Tvá volba:**
```
[MCP-SERVERS]: A / B / C / D
```

**Doporučení:** **VOLBA B** - vyvážené řešení.

---

### 📍 OTÁZKA 0.3: API Keys & Secrets Management

**Popis:**
- Správa GitHub API klíčů, tokenů, SSH klíčů
- Bezpečné ukládání (ne v kódu!)
- Rotation strategie
- Audit logging

**Relevantní API klíče:**

```
┌────────────────────────────────────────────────────────┐
│ API KEY              │ ÚČEL                            │
├────────────────────────────────────────────────────────┤
│ GITHUB_TOKEN         │ GitHub API + Actions            │
│ GITHUB_SSH_KEY       │ SSH autentizace                 │
│ GPG_PRIVATE_KEY      │ Podpis commitů                  │
│ DOCKER_TOKEN         │ Docker registry                 │
│ TERMUX_SSH_KEY       │ Termux remote access            │
│ RPI_SSH_KEY          │ Raspberry Pi access             │
│ REGISTRY_TOKEN       │ Docker/npm registry token       │
│ DEPLOY_KEY           │ Deployment automation           │
└────────────────────────────────────────────────────────┘
```

---

**VOLBY:**

**A) 🟢 GITHUB SECRETS + ENCRYPTED .ENV (Doporučeno)**
- ✅ GitHub Secrets pro GitHub Actions
- ✅ `.env.encrypted` pro local dev (git-crypt)
- ✅ `.env.example` s dummy values v repozitáři
- ✅ Rotation každý 90 dní
- ✅ Audit logging v GitHub

**Setup:**
```bash
# 1. Vytvořit .env.local (ignorován v .gitignore)
cat > .env.local << EOF
GITHUB_TOKEN=ghp_xxxxxxxxxxxx
GITHUB_SSH_KEY=$(cat ~/.ssh/github_ed25519)
TERMUX_SSH_KEY=$(cat ~/.ssh/termux_rsa)
RPI_SSH_KEY=$(cat ~/.ssh/rpi_rsa)
DOCKER_TOKEN=dckr_xxxxxxxxxxxx
EOF

# 2. Neignorovat v .gitignore
echo ".env.local" >> .gitignore

# 3. .env.example (dummy values)
cat > .env.example << EOF
GITHUB_TOKEN=ghp_xxx...
GITHUB_SSH_KEY=-----BEGIN OPENSSH PRIVATE KEY-----
TERMUX_SSH_KEY=-----BEGIN OPENSSH PRIVATE KEY-----
RPI_SSH_KEY=-----BEGIN OPENSSH PRIVATE KEY-----
DOCKER_TOKEN=dckr_xxx...
EOF

# 4. GitHub Secrets (přes CLI)
gh secret set GITHUB_TOKEN -b "$(cat ~/.ssh/github_ed25519)"
gh secret set TERMUX_SSH_KEY -b "$(cat ~/.ssh/termux_rsa)"
gh secret set RPI_SSH_KEY -b "$(cat ~/.ssh/rpi_rsa)"
gh secret set DOCKER_TOKEN -b "tvoj_docker_token"

# 5. Zobrazit všechny secrets
gh secret list
```

**Výhody:**
- Tradiční přístup
- GitHub nativní
- Audit trail

**Nevýhody:**
- Secrets viditelné v Actions
- Nelze lokálně encryptovat
- Ruční rotation

---

**B) 🟡 1PASSWORD / LASTPASS INTEGRATION**
- ✅ Všechny secrets v 1Password
- ✅ GitHub Actions integraci
- ✅ Automatická rotation
- ✅ Team sharing

**Setup:**
```bash
# 1Password CLI
brew install 1password-cli
op account add

# Create vault
op vault create --name "STARCORE"

# Create item
op item create --category login \
  --title "GitHub Token" \
  --url https://github.com/settings/tokens \
  --username Fatalerorr69 \
  --password "$(gh auth token)"

# GitHub Actions integraci
# .github/workflows/secure-ops.yml
- uses: 1Password/load-secrets-action@v1
  with:
    export-env: true
    secrets: "op://STARCORE/GitHub Token/password"
```

**Výhody:**
- Enterprise-grade
- Automatická rotation
- Team sharing
- Audit log

**Nevýhody:**
- Placené (1Password)
- Dodatečná komplexnost
- Vendor lock-in

---

**C) 🔒 VAULT / HASHICORP SETUP**
- ✅ Vlastní secret server
- ✅ Dynamické credentials
- ✅ Enkryptace end-to-end
- ✅ Audit logging
- ✅ Multi-region failover

**Setup:**
```bash
# Instalace Vault
wget https://releases.hashicorp.com/vault/1.15.0/vault_1.15.0_linux_amd64.zip
unzip vault_*.zip
sudo mv vault /usr/local/bin/

# Inicializace
vault server -dev

# Vytvoření secret
vault kv put secret/starcore \
  github_token="ghp_xxx" \
  docker_token="dckr_xxx"

# GitHub Actions integraci
# .github/workflows/vault-auth.yml
- uses: hashicorp/vault-action@v2
  with:
    url: https://vault.example.com
    method: jwt
    path: jwt
    role: starcore
    secrets: |
      secret/data/starcore github_token | GITHUB_TOKEN;
      secret/data/starcore docker_token | DOCKER_TOKEN
```

**Výhody:**
- Maximum kontrolu
- Dynamické secrets
- Audit audit audit
- Self-hosted

**Nevýhody:**
- Vyžaduje server
- Složitá správa
- DevOps knowledge needed

---

**D) ⚠️ PLAIN .ENV (NEJHORŠÍ - NEDĚLÁŠ TO!)**
- ❌ Secrets v .env v gitu
- ❌ Plaintext v repozitáři
- ❌ Žádné šifrování
- ❌ Žádný audit

**Nevýhody:**
- Bezpečnostní horror
- Compliance violation
- Možnost hacku
- **NEDĚLÁŠ NIKDY!**

---

**Tvá volba:**
```
[SECRETS-MANAGEMENT]: A / B / C
```

**Doporučení:** **VOLBA A** pro osobní projekt, **VOLBA B/C** pro tým/produkci.

---

### 📍 OTÁZKA 0.4: SSH Keys Setup

**Popis:**
- Vygenerování SSH klíčů pro různé cíle
- GitHub, Termux, RPi, server
- Správa a bezpečnost

**Klíče které budeme potřebovat:**

```
┌────────────────────────────────────────────────────────┐
│ CÍЛЬ                 │ KEY TYPE     │ NÁZEV            │
├────────────────────────────────────────────────────────┤
│ GitHub               │ ED25519      │ github_ed25519   │
│ Termux Android       │ RSA 4096     │ termux_rsa       │
│ Raspberry Pi         │ RSA 4096     │ rpi_rsa          │
│ Deployment server    │ ED25519      │ deploy_ed25519   │
│ Backups              │ RSA 4096     │ backup_rsa       │
└────────────────────────────────────────────────────────┘
```

---

**VOLBY:**

**A) 🟢 MULTIPLE KEYS (Bezpečnostní best practice)**
- ✅ Oddělený klíč pro každý cíl
- ✅ Automatická rotace (každý rok)
- ✅ SSH agent configuration
- ✅ Backup encryptovaný

**Setup:**
```bash
#!/bin/bash
# Script: setup_ssh_keys.sh

# 1. GitHub
ssh-keygen -t ed25519 -C "GitHub Fatalerorr69" \
  -f ~/.ssh/github_ed25519 -N "passphrase"

# 2. Termux
ssh-keygen -t rsa -b 4096 -C "Termux" \
  -f ~/.ssh/termux_rsa -N "passphrase"

# 3. Raspberry Pi
ssh-keygen -t rsa -b 4096 -C "RPi" \
  -f ~/.ssh/rpi_rsa -N "passphrase"

# 4. Deployment
ssh-keygen -t ed25519 -C "Deployment" \
  -f ~/.ssh/deploy_ed25519 -N "passphrase"

# 5. Backup (encrypted)
ssh-keygen -t rsa -b 4096 -C "Backup" \
  -f ~/.ssh/backup_rsa -N "strong_passphrase"

# 6. SSH Config
cat > ~/.ssh/config << 'SSHCONFIG'
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/github_ed25519
  AddKeysToAgent yes

Host termux
  HostName termux.local
  User u0_a0
  IdentityFile ~/.ssh/termux_rsa
  AddKeysToAgent yes

Host rpi
  HostName raspberrypi.local
  User pi
  IdentityFile ~/.ssh/rpi_rsa
  AddKeysToAgent yes

Host deploy
  HostName deploy.example.com
  User deploy
  IdentityFile ~/.ssh/deploy_ed25519
  AddKeysToAgent yes
SSHCONFIG

# 7. SSH Agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/github_ed25519
ssh-add ~/.ssh/termux_rsa
ssh-add ~/.ssh/rpi_rsa
ssh-add ~/.ssh/deploy_ed25519

# 8. Backup
gpg -c ~/.ssh/github_ed25519
gpg -c ~/.ssh/termux_rsa
gpg -c ~/.ssh/rpi_rsa
gpg -c ~/.ssh/deploy_ed25519
# Uložit .gpg soubory bezpečně (USB, cloud, etc.)

# 9. Add public keys ke službám
echo "GitHub:"
cat ~/.ssh/github_ed25519.pub

echo "Termux:"
cat ~/.ssh/termux_rsa.pub

echo "RPi:"
cat ~/.ssh/rpi_rsa.pub
```

**Výhody:**
- Security isolation
- Rotace po klíčích
- SSH agent integration
- Encrypted backup

**Nevýhody:**
- Více klíčů ke správě
- Složitější setup
- Passphrases k pamatování

---

**B) 🟡 SINGLE UNIVERSAL KEY**
- ✅ Jeden klíč pro všechno
- ✅ Jednodušší správa
- ✅ Jedna passphrase

**Setup:**
```bash
ssh-keygen -t ed25519 -C "Fatalerorr69 Universal" \
  -f ~/.ssh/id_ed25519 -N "passphrase"

# SSH config
cat > ~/.ssh/config << 'SSHCONFIG'
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519

Host termux
  HostName termux.local
  IdentityFile ~/.ssh/id_ed25519

Host rpi
  HostName raspberrypi.local
  IdentityFile ~/.ssh/id_ed25519
SSHCONFIG
```

**Výhody:**
- Jednoduchý
- Jedna passphrase
- Méně klíčů

**Nevýhody:**
- Slabší izolace
- Kdyby se odhalí klíč - všechny služby kompromitovány
- Těžší rotace

---

**C) ⚠️ BEZ PASSPHRASE (NEJHORŠÍ)**
- ✅ Bezpassphrase klíč
- ❌ Žádná ochrana
- ❌ Kdokoliv kdo ma FS access se dostane ke všem službám

**Nevýhody:**
- Kritické bezpečnostní riziko
- Jestli server bude hacknout → všechny služby pryč
- **NIKDY TO NEDĚLEJ!**

---

**Tvá volba:**
```
[SSH-KEYS]: A / B
```

**Doporučení:** **VOLBA A** - multiple keys s passphrases.

---

### 📍 OTÁZKA 0.5: Git Configuration

**Popis:**
- Global + Local git config
- Author info, signing, hooks
- .gitignore, .gitattributes

**Co se nastavuje:**

```
┌─────────────────────────────────────────────┐
│ SETTING              │ POPIS                │
├─────────────────────────────────────────────┤
│ user.name            │ Tvoje jméno         │
│ user.email           │ Tvoj email          │
│ commit.gpgSign       │ Podepisovat commity │
│ user.signingKey      │ GPG key ID          │
│ pull.rebase          │ Rebase na pull      │
│ core.autocrlf        │ Normalizace CRLF    │
│ core.ignorecase      │ Case sensitivity    │
│ init.defaultBranch   │ Default branch      │
└─────────────────────────────────────────────┘
```

---

**VOLBY:**

**A) 🟢 FULL PRODUCTION CONFIG (Doporučeno)**
- ✅ GPG signed commits
- ✅ Git hooks (pre-commit, pre-push)
- ✅ Enforce branch naming
- ✅ Enforce commit message format
- ✅ Auto-rebase na pull
- ✅ LFS pro velké soubory

**Setup:**
```bash
#!/bin/bash
# setup_git_config.sh

# Global config
git config --global user.name "Jacob Starko"
git config --global user.email "Fatalerorr69@github.com"
git config --global user.signingKey ~/.ssh/github_ed25519
git config --global commit.gpgSign true
git config --global gpg.format ssh
git config --global pull.rebase true
git config --global rebase.autoStash true
git config --global core.autocrlf input
git config --global core.ignorecase false
git config --global init.defaultBranch main
git config --global fetch.prune true
git config --global push.default current

# Local config pro STARCORE
cd ~/projects/STARCORE
git config --local user.signingKey ~/.ssh/github_ed25519
git config --local commit.gpgSign true

# Git Hooks (pre-commit)
pip install pre-commit
cat > .pre-commit-config.yaml << 'PRECOMMIT'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict
      - id: no-commit-to-branch
        args: [--branch, main]

  - repo: https://github.com/psf/black
    rev: 23.7.0
    hooks:
      - id: black

  - repo: https://github.com/PyCQA/pylint
    rev: pylint-2.17.5
    hooks:
      - id: pylint

  - repo: https://github.com/adrienverge/yamllint
    rev: v1.32.0
    hooks:
      - id: yamllint
PRECOMMIT

pre-commit install
pre-commit install --hook-type pre-push

# Git attributes
cat > .gitattributes << 'GITATTR'
# Auto convert CRLF to LF
* text=auto

# Python
*.py text eol=lf
*.pyw text eol=lf

# Shell
*.sh text eol=lf

# Windows batch
*.bat text eol=crlf
*.cmd text eol=crlf

# Large files
*.tar.gz binary
*.zip binary
*.tar binary
*.db binary
*.sqlite binary

# LFS
*.pth filter=lfs diff=lfs merge=lfs -text
*.h5 filter=lfs diff=lfs merge=lfs -text
GITATTR

# .gitignore
cat > .gitignore << 'GITIGNORE'
# Environment
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# Python
__pycache__/
*.py[cod]
*$py.class
.pytest_cache/
.coverage
htmlcov/

# Dependencies
venv/
env/
node_modules/
dist/
build/

# Secrets
*.pem
*.key
*.crt
*.p12
!.ssh/*.pub

# Generated
*.log
*.pid
GITIGNORE

git add .
git commit -m "chore: Setup git config, hooks, and attributes"
git push origin main
```

**Výhody:**
- Signed commits (verifiable)
- Automatické quality checks
- Branch protection
- Standardizovaný workflow

**Nevýhody:**
- Složitější setup
- Pre-commit hooks zpomalují commit
- Vyžaduje GPG/SSH signing

---

**B) 🟡 BASIC CONFIG**
- ✅ Základní user info
- ✅ Bez GPG signing
- ✅ Bez hooks
- ✅ Bez LFS

**Setup:**
```bash
git config --global user.name "Jacob Starko"
git config --global user.email "Fatalerorr69@github.com"
git config --global pull.rebase true
```

**Výhody:**
- Rychlý setup
- Minimální overhead

**Nevýhody:**
- Bez quality assurance
- Bez security (unsigned commits)
- Bez branch protection

---

**C) ⚠️ DEFAULT CONFIG**
- ❌ Jen systémové default
- ❌ Bez customizace
- ❌ Hrozí problémů

**Tvá volba:**
```
[GIT-CONFIG]: A / B
```

**Doporučení:** **VOLBA A** - production-ready setup.

---

## PHASE 1: ARCHITEKTURNÍ ROZHODNUTÍ {#phase1}

### 🏗️ OTÁZKA 1.1: STARCORE ARCHITEKTURA

**Dlouhé vysvětlení:**

STARCORE tvůj projekt se skládá z 6 oddělených repozitářů:
1. **STARCORE** (hlavní jádro)
2. **starcore-platform** (4 open issues)
3. **STARCORE-v12-AI-Package** (AI modul)
4. **STARCORE-AUTO-BUILDER-v3.0** (build system)
5. **starcore-android** (Termux wrapper)
6. **Starcore_hive** (neaktivní)

Plus **4 separátní RPi repozitáře** - rpi5-homeassistant, rpi5-catalog, rpi5-starkhost, starko-rpi5-ai-workspace

**Otázka:** Jak je organizovat? 

---

**VOLBY:**

**A) 🟢 MONOREPO - Vše v jednom (DOPORUČENO)**

```
STARCORE/  (single repository)
├── core/
│   ├── orchestrator.py (z STARCORE)
│   ├── platform/ (z starcore-platform)
│   └── ai-package/ (z v12-AI-Package)
├── mobile/
│   └── termux-android/ (z starcore-android)
├── workspace/
│   ├── rpi5-ai/
│   ├── rpi5-homeassistant/
│   ├── rpi5-catalog/
│   └── rpi5-starkhost/
├── ci-cd/
│   └── auto-builder/ (z AUTO-BUILDER-v3.0)
├── tools/
├── docs/
└── .github/workflows/
```

**Příkazy (git subtree):**
```bash
git clone https://github.com/Fatalerorr69/STARCORE.git starcore-mono
cd starcore-mono
mkdir -p core mobile workspace ci-cd tools docs

# Integrovat submoduly
git subtree add --prefix=core/platform \
  https://github.com/Fatalerorr69/starcore-platform.git main

git subtree add --prefix=core/ai-package \
  https://github.com/Fatalerorr69/STARCORE-v12-AI-Package.git main

# ... ostatní
```

**Výhody:**
- ✅ Jednotný git log (vidíš všechny změny)
- ✅ Jednotný CI/CD pipeline
- ✅ Jednodušší dependency management
- ✅ Lepší atomic transactions
- ✅ Snadnější cross-module changes

**Nevýhody:**
- ❌ Větší repozitář (~ 500MB)
- ❌ Pomalejší clone
- ❌ Komplikovanější git workflow
- ❌ Více merge conflicts
- ❌ Těžší pro oddělené týmy

**Dopad:**
- 📊 Build time: +30% (ale lepší caching)
- 🔄 Deployment: -50% (jednodušší orchestrace)
- 👥 Team coordination: Lepší viditelnost
- 💾 Storage: +100MB (z důvodu redundance history)

**Timeline:** 2-3 dny na integraci + testování

---

**B) 🟡 WORKSPACE - Oddělené repozitáře**

```
STARCORE (jádro)
├── core/
├── mobile/
└── ci-cd/

STARCORE-platform (separátní) - linkovaný jako git submodule
STARCORE-ai-engine (separátní) - linkovaný jako git submodule
STARCORE-rpi-workspace (separátní) - linkovaný jako git submodule
STARCORE-deployment (separátní) - linkovaný jako git submodule
```

**Setup:**
```bash
git clone https://github.com/Fatalerorr69/STARCORE.git
cd STARCORE

# Přidat submoduly
git submodule add https://github.com/Fatalerorr69/starcore-platform.git platform
git submodule add https://github.com/Fatalerorr69/STARCORE-v12-AI-Package.git ai-engine
git submodule add https://github.com/Fatalerorr69/rpi5-homeassistant-suite.git rpi-workspace/ha
# ...

git submodule update --recursive --remote
```

**Výhody:**
- ✅ Oddělené repozitáře (malé clony)
- ✅ Paralelní vývoj bez konfliktů
- ✅ Granulární verzioning
- ✅ Team izolace

**Nevýhody:**
- ❌ Komplexní git workflow
- ❌ Ztěžené CI/CD orchestrace
- ❌ Povinná koordinace
- ❌ Složitější testing cross-modules
- ❌ Vyšší maintenance

**Dopad:**
- 📊 Build time: Individuální (ale delší orchestrace)
- 🔄 Deployment: +100% (musím koordinovat)
- 👥 Team: Lepší izolace, horší viditelnost
- 💾 Storage: -300MB (jen referenční submoduly)

**Timeline:** 1-2 dny + komplexnější maintenance

---

**C) 🟠 HYBRID - Částečné sloučení**

```
STARCORE (monorepo - core + mobile + workspace)
├── core/ (STARCORE + starcore-platform sloučené)
├── mobile/ (starcore-android)
├── workspace/ (rpi5-* zaintegrované)
└── ci-cd/ (auto-builder)

STARCORE-platform-legacy (archivované) - jen reference
STARCORE-v12-variants (separátní) - pro A/B testing
```

**Setup:**
```bash
# Sloučit core + platform
git clone https://github.com/Fatalerorr69/STARCORE.git
cd STARCORE
git subtree add --prefix=core/platform \
  https://github.com/Fatalerorr69/starcore-platform.git main

# Ostatní jako submodule (pokud se často mění)
git submodule add https://github.com/Fatalerorr69/STARCORE-v12-AI-Package.git variants/v12
```

**Výhody:**
- ✅ Balans mezi komplexností a kontrolou
- ✅ Core + Platform dohromady (tight coupling)
- ✅ Flexibility pro varianty

**Nevýhody:**
- ❌ Kompromis = nejhorší z obou světů?
- ❌ Složitější rozhodování co kam patří

---

**D) ☁️ MULTI-REPO ORCHESTRATION (Cloud-native)**

```
Central Orchestrator (não je v gitu - běží v GitHub Actions)
├── Pulls STARCORE
├── Pulls starcore-platform
├── Pulls STARCORE-v12-AI-Package
├── Pulls rpi5-homeassistant
└── Orchestruje CI/CD pro všechny

Každý repozitář je **независний**, orchestrátor koordinuje.
```

**Setup (GitHub Actions):**
```yaml
name: Multi-Repo Orchestration

on:
  workflow_dispatch

jobs:
  orchestrate:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout all repos
        run: |
          for repo in STARCORE starcore-platform STARCORE-v12-AI-Package; do
            git clone --depth 1 https://github.com/Fatalerorr69/$repo.git
          done
      
      - name: Run unified tests
        run: |
          cd STARCORE
          python -m pytest
          cd ../starcore-platform
          python -m pytest
          # ... všechny
      
      - name: Deploy if all pass
        if: success()
        run: |
          # Deploy všechno
```

**Výhody:**
- ✅ Maximální flexibility
- ✅ Rozprostřená CI/CD
- ✅ Paralelní testing
- ✅ Modulární

**Nevýhody:**
- ❌ Nejkomplexnější na údržbu
- ❌ Synchronizace je bolest
- ❌ Debugging je těžký
- ❌ GitOps horror

---

**Tvá volba:**
```
[STARCORE-ARCHITEKTURA]: A / B / C / D
```

**DOPORUČENÍ:** 
- 🟢 **VOLBA A (Monorepo)** - pokud pracuješ sám/malý tým
- 🟡 **VOLBA B (Workspace)** - pokud máš separátní týmy na modulech
- 🟠 **VOLBA C (Hybrid)** - pokud chceš best-of-both-worlds
- ☁️ **VOLBA D** - pokud to bude cloud-native (Kubernetes)

**Můj tip:** Začni s **A** (monorepo) - později se to dá změnit na B!

---

### 🏗️ OTÁZKA 1.2: STARCORE-PLATFORM (4 Open Issues)

**Vysvětlení:**

`starcore-platform` má **4 open issues**, což je problém. Musíš vědět:
- Co je v tom repozitáři?
- Jaké jsou ty 4 issues?
- Je to duplikáta STARCORE?
- Má speciální obsah?

**Možné scénáře:**
1. `starcore-platform` = abstrakční vrstva pro STARCORE
2. `starcore-platform` = starší verze (zastaralá)
3. `starcore-platform` = oddělená komponenta (platform-as-a-service)
4. `starcore-platform` = experiment

---

**VOLBY:**

**A) 🔀 SLOUČIT S HLAVNÍM STARCORE**

"Vezmu obsah z `starcore-platform` a sloučím ho do `core/platform/` v monorepu."

**Postup:**
```bash
# 1. Zkontroluj obsah
git clone https://github.com/Fatalerorr69/starcore-platform.git
cd starcore-platform
ls -la                          # Co je tam?
git log --oneline -20          # Poslední commits
wc -l $(find . -name "*.py")   # Kolik kódu?
cat README.md                   # Co dělá?

# 2. Zjisti issues
gh issue list --repo Fatalerorr69/starcore-platform

# 3. Sloučit do monorepa
cd ~/starcore-monorepo
git subtree add --prefix=core/platform \
  https://github.com/Fatalerorr69/starcore-platform.git main

# 4. Migruj issues
# V GitHub UI: Transfer issues z starcore-platform do STARCORE
# Settings → Transfer issues → STARCORE

# 5. Archive
gh repo archive Fatalerorr69/starcore-platform --yes
```

**Výhody:**
- ✅ Jednoduchý workflow
- ✅ Vyřešené issues vidím v jednom místě
- ✅ Jedna CI/CD

**Nevýhody:**
- ❌ Pokud se platform ještě vyvíjí - ztížíš to
- ❌ Pokud issues jsou komplexní - confusion

**Dopad:**
- ⏱️ Čas: 2-4 hodiny
- 👥 Issues: 4 issues se přesunou do STARCORE
- 🔄 CI/CD: Sjednotí se

---

**B) 📌 PONECHAT JAKO SEPARÁTNÍ (GIT SUBMODULE)**

"Zachovám `starcore-platform` jako separátní repozitář a linkuju ho jako git submodule."

**Postup:**
```bash
cd ~/STARCORE
git submodule add https://github.com/Fatalerorr69/starcore-platform.git core/platform
git submodule update --recursive

# V .gitmodules se vytvoří odkaz
cat .gitmodules
[submodule "core/platform"]
  path = core/platform
  url = https://github.com/Fatalerorr69/starcore-platform.git
```

**Výhody:**
- ✅ `starcore-platform` se vyvíjí nezávisle
- ✅ Issues zůstávají v původním repozitáři
- ✅ Granulární verzioning

**Nevýhody:**
- ❌ Složitější git workflow (submodule update)
- ❌ Separátní CI/CD pro platform
- ❌ Cross-module testing je obtížnější

**Dopad:**
- ⏱️ Čas: 30 minut
- 👥 Issues: Zůstávají v starcore-platform
- 🔄 CI/CD: Oddělené
- 🔧 Maintenance: Vyšší (submodule sync)

---

**C) ❓ AUDIT NEJDŘÍV**

"Mám zkontrolovat obsah `starcore-platform` a pak rozhodovat."

**Audit skript:**
```bash
#!/bin/bash
# audit_starcore_platform.sh

REPO="starcore-platform"
echo "=== AUDITING $REPO ==="

# Clone
git clone --depth 1 https://github.com/Fatalerorr69/$REPO.git audit_$REPO
cd audit_$REPO

# Analýza
echo "📊 STATISTIKY:"
echo "Files: $(find . -type f | wc -l)"
echo "Directories: $(find . -type d | wc -l)"
echo "Python files: $(find . -name "*.py" | wc -l)"
echo "Lines of code: $(find . -name "*.py" -exec wc -l {} + | tail -1)"
echo "Total size: $(du -sh . | cut -f1)"

echo "📝 GIT LOG (poslední 10 commitů):"
git log --oneline -10

echo "🔧 LAST COMMIT DATE:"
git log -1 --format=%ai

echo "📋 OPEN ISSUES:"
cd ..
gh issue list --repo Fatalerorr69/$REPO

echo "📄 README:"
cat audit_$REPO/README.md || echo "Žádné README"

echo "🔍 STRUKTURA:"
tree audit_$REPO -L 2 -I '__pycache__|.git' || find audit_$REPO -type d -maxdepth 2

echo "🔗 DEPENDENCIES:"
cat audit_$REPO/requirements.txt 2>/dev/null || echo "Žádný requirements.txt"

# Cleanup
cd ..
rm -rf audit_$REPO
```

**Spuštění:**
```bash
chmod +x audit_starcore_platform.sh
./audit_starcore_platform.sh > audit_report.md
```

**Výhody:**
- ✅ Jistý audit
- ✅ Informed decision
- ✅ Žádné překvapení později

**Nevýhody:**
- ❌ Trvá déle
- ❌ Vyžaduje ručí analýzu

---

**Tvá volba:**
```
[STARCORE-PLATFORM]: A / B / C
```

**DOPORUČENÍ:** 
- 🟢 **VOLBA C (Audit)** nejdřív - pak A nebo B

---

*(Pokračuji v dalších otázkách níž...)*

