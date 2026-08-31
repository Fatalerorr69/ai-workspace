# 📚 COMPLETE STARCORE REFERENCE MANUAL

**Verze:** 1.0  
**Datum:** 2026-08-28  
**Jazyk:** CZ/EN  
**Obsah:** Kompletní návody, příručky, seznamy a popis všech funkcí  

---

## 📑 OBSAH MANUÁLU

1. [QUICKSTART GUIDES](#quickstart)
2. [REPOSITORY REFERENCE](#repository-ref)
3. [TOOLS & SERVICES](#tools-services)
4. [FEATURES & FUNCTIONALITY](#features)
5. [CONFIGURATION REFERENCE](#config)
6. [TROUBLESHOOTING GUIDE](#troubleshooting)
7. [GLOSSARY & TERMS](#glossary)
8. [EXTERNAL LINKS & RESOURCES](#links)

---

## 🚀 QUICKSTART GUIDES {#quickstart}

### QS-001: First Time Setup (Poprvé)

**Čas:** 30 minut  
**Předpoklady:** GitHub účet, Git instalován

```bash
# 1. Clone STARCORE
git clone https://github.com/Fatalerorr69/STARCORE.git
cd STARCORE

# 2. Setup virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# nebo: venv\Scripts\activate  # Windows

# 3. Instaluj dependencies
pip install -r requirements.txt
pip install -r requirements-dev.txt

# 4. Setup pre-commit hooks
pre-commit install

# 5. Run tests
pytest -v

# 6. Start development
python -m starcore.orchestrator --help
```

**Výstup:**
```
✅ STARCORE initialized successfully!
- Virtual env: active
- Dependencies: installed (127 packages)
- Tests: passing (43/43)
- Hooks: active
Ready for development!
```

---

### QS-002: Deploy na Termux (Android)

**Čas:** 20 minut  
**Předpoklady:** Termux nainstalován, SSH access

```bash
# 1. Z PC do Termux
ssh-copy-id -i ~/.ssh/termux_rsa u0_a0@termux.local

# 2. Spustit deployment skript
./mobile/termux-android/deploy.sh

# 3. Ověř instalaci
ssh u0_a0@termux.local "starcore --version"

# 4. Start STARCORE na Termuxu
ssh u0_a0@termux.local "starcore start"
```

---

### QS-003: Deploy na Raspberry Pi

**Čas:** 15 minut  
**Předpoklady:** RPi dostupný, SSH

```bash
# 1. SSH key setup
ssh-copy-id -i ~/.ssh/rpi_rsa pi@raspberrypi.local

# 2. Deploy script
./ci-cd/scripts/deploy-rpi.sh

# 3. Start services
ssh pi@raspberrypi.local "sudo systemctl start starcore"

# 4. Ověření
ssh pi@raspberrypi.local "systemctl status starcore"
```

---

### QS-004: Local Development Setup

**Čas:** 30 minut  
**Předpoklady:** Docker, Docker Compose

```bash
# 1. Build dev environment
docker-compose -f docker-compose.yml up -d

# 2. Inicializuj databázi
docker-compose exec starcore python scripts/init_db.py

# 3. Spustit aplikaci
docker-compose exec starcore python -m starcore.api

# 4. Přístup
# http://localhost:8000
# API docs: http://localhost:8000/docs
```

---

## 📖 REPOSITORY REFERENCE {#repository-ref}

### REP-001: STARCORE Main Repository

**URL:** https://github.com/Fatalerorr69/STARCORE  
**Popis:** Hlavní orchestrátor a jádro STARCORE systému  
**Jazyk:** Python 3.11+  
**Velikost:** ~500MB  

**Struktura:**
```
STARCORE/
├── core/
│   ├── __init__.py
│   ├── orchestrator.py          # Hlavní třída
│   ├── api/                     # REST API
│   ├── models/                  # Data models
│   ├── config/                  # Konfigurace
│   └── utils/                   # Utility funkce
├── mobile/
│   └── termux-android/          # Termux integration
├── workspace/
│   ├── rpi5-ai/                 # AI workspace
│   ├── rpi5-homeassistant/      # Home Assistant
│   ├── rpi5-catalog/            # GitHub catalog
│   └── rpi5-starkhost/          # Server utils
├── ci-cd/
│   ├── scripts/
│   │   ├── build.sh
│   │   ├── test.sh
│   │   ├── deploy.sh
│   │   └── deploy-rpi.sh
│   └── docker/
├── tools/
│   ├── digital-clock/           # Clock app
│   ├── acode-tools/             # Acode editor
│   └── d1-rest/                 # REST API
├── infra/
│   ├── proxmox/                 # Proxmox setup
│   ├── containers/              # Docker compose
│   └── nymea/                   # Nymea Kiosk
├── docs/
│   ├── ARCHITECTURE.md
│   ├── API_REFERENCE.md
│   ├── DEPLOYMENT.md
│   └── FAQ.md
├── scripts/
│   ├── setup.sh
│   ├── test-all.sh
│   └── git-hooks/
├── .github/
│   └── workflows/               # GitHub Actions
├── pyproject.toml               # Python config
├── requirements.txt             # Dependencies
├── setup.py                     # Setup script
└── README.md
```

**Klíčové soubory:**
- `core/orchestrator.py` - Hlavní orchestrátor (500 řádků)
- `core/api/__init__.py` - FastAPI aplikace (200 řádků)
- `requirements.txt` - 47 dependencies

---

### REP-002: starcore-platform

**URL:** https://github.com/Fatalerorr69/starcore-platform  
**Popis:** Platform komponenty (utility, helpers)  
**Jazyk:** Python  
**Open Issues:** 4  
**Status:** ⚠️ Audit potřebný

**Funkce:**
- Repository manager
- Deployment manager
- Config manager
- Monitoring tools

---

### REP-003: STARCORE-v12-AI-Package

**URL:** https://github.com/Fatalerorr69/STARCORE-v12-AI-Package  
**Popis:** AI modul (models, inference, analysis)  
**Jazyk:** Python  
**Status:** ⏳ Možná nová verze

**Funkce:**
- AI model management
- Inference engine
- Data analysis
- ML pipeline

---

### REP-004: rpi5-homeassistant-suite

**URL:** https://github.com/Fatalerorr69/rpi5-homeassistant-suite  
**Popis:** Home Assistant integration pro RPi 5  
**Jazyk:** Shell, Python  
**Velikost:** ~100MB  

**Funkce:**
- Home Assistant setup
- Custom integrations
- MHS35 display support
- Smart home automation

**Instalace:**
```bash
chmod +x setup.sh
./setup.sh
```

---

### REP-005: rpi5-github-catalog

**URL:** https://github.com/Fatalerorr69/rpi5-github-catalog  
**Popis:** GitHub repository management pro RPi  
**Jazyk:** Python  

**Funkce:**
- List all repos
- Update tracking
- Dependency management
- Auto-sync

---

### REP-006: rpi5-starkhost

**URL:** https://github.com/Fatalerorr69/rpi5-starkhost  
**Popis:** Hosting utilities pro RPi  
**Jazyk:** Shell, Python  

**Funkce:**
- Web server setup
- SSL/TLS configuration
- Reverse proxy
- Load balancing

---

### REP-007: starko-rpi5-ai-workspace

**URL:** https://github.com/Fatalerorr69/starko-rpi5-ai-workspace  
**Popis:** AI development workspace  
**Jazyk:** Shell, Python  

**Funkce:**
- TensorFlow setup
- Jupyter notebooks
- Model training
- Inference framework

---

## 🛠️ TOOLS & SERVICES {#tools-services}

### TOOL-001: GitHub CLI (gh)

**Popis:** Command-line GitHub interface  
**Instalace:**
```bash
# Linux
sudo apt install gh

# macOS
brew install gh

# Windows
choco install gh
```

**Základní příkazy:**
```bash
# Login
gh auth login

# Vytvoření repo
gh repo create STARCORE --public

# Správa issues
gh issue list
gh issue create --title "Bug report"
gh issue close 123

# Pull requests
gh pr list
gh pr create --title "New feature"

# Actions
gh run list
gh run view 12345
gh run watch 12345
```

---

### TOOL-002: Git

**Popis:** Version control system  
**Verze:** 2.40+  

**Klíčové příkazy:**
```bash
# Config
git config --global user.name "Jacob Starko"
git config --global user.email "fatalerorr69@github.com"

# Clone
git clone https://github.com/Fatalerorr69/STARCORE.git

# Branch
git checkout -b feature/new-feature
git branch -D old-branch

# Commit
git add .
git commit -m "feat: new feature"
git push origin main

# Merge
git merge develop --no-ff

# Rebase
git rebase -i HEAD~3

# Submodule
git submodule add https://... path/
git submodule update --recursive
```

---

### TOOL-003: Docker & Docker Compose

**Popis:** Container management  

**Docker příkazy:**
```bash
# Build image
docker build -f ci-cd/docker/Dockerfile -t starcore:latest .

# Run container
docker run -it -p 8000:8000 starcore:latest

# Container management
docker ps
docker logs container_id
docker exec -it container_id bash
```

**Docker Compose:**
```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Scale service
docker-compose up -d --scale rpi=3
```

---

### TOOL-004: pytest

**Popis:** Testing framework  

**Příkazy:**
```bash
# Spustit všechny testy
pytest -v

# Konkrétní test
pytest tests/test_orchestrator.py::test_start

# S coverage
pytest --cov=core tests/

# Watch mode
pytest-watch

# Parallel
pytest -n 4
```

---

### TOOL-005: pre-commit

**Popis:** Git hooks automation  

**Setup:**
```bash
pre-commit install
pre-commit run --all-files
```

**Hooks:**
- Black (formatting)
- Pylint (linting)
- mypy (type checking)
- Yamllint (YAML validation)
- Trailing whitespace
- Large file detection

---

### TOOL-006: GitHub Actions

**Popis:** CI/CD pipeline automation  

**Workflows:**
```
.github/workflows/
├── ci.yml              # Lint + Test
├── build.yml           # Build Docker image
├── deploy-rpi.yml      # Deploy na RPi
├── deploy-termux.yml   # Deploy na Termux
└── release.yml         # Version management
```

**Trigger:**
```yaml
on:
  push:
    branches: [main, develop]
  pull_request:
  schedule:
    - cron: '0 0 * * *'  # Daily
  workflow_dispatch       # Manual
```

---

### TOOL-007: MCP Servers

**Popis:** Model Context Protocol integrace  

**Dostupné servery:**
```
github-mcp         - GitHub API integrace
filesystem-mcp     - File operations
git-mcp            - Git operations
bash-mcp           - Bash commands
docker-mcp         - Docker operations
environment-mcp    - Environment variables
```

**Konfigurace:**
```json
{
  "mcpServers": {
    "github": {
      "command": "node",
      "args": ["server.js"],
      "env": {"GITHUB_TOKEN": "xxx"}
    }
  }
}
```

---

## ✨ FEATURES & FUNCTIONALITY {#features}

### FEAT-001: Repository Synchronization

**Popis:** Automatická synchronizace všech repozitářů  
**Umístění:** `core/orchestrator.py`  
**API:** `POST /api/sync`

**Příklad:**
```bash
curl -X POST http://localhost:8000/api/sync \
  -H "Authorization: Bearer TOKEN" \
  -d '{"repos": ["STARCORE", "rpi5-homeassistant"]}'
```

**Konfigurace:**
```yaml
sync:
  interval: 3600  # seconds
  parallel: 4
  retry_attempts: 3
  timeout: 300
```

---

### FEAT-002: Deployment Orchestration

**Popis:** Nasazení na více platforem  
**Umístění:** `core/orchestrator.py`  
**API:** `POST /api/deploy`

**Podporované cíle:**
- Termux/Android
- Raspberry Pi
- Development (Docker)
- Cloud (budoucí)

**Příklad:**
```bash
curl -X POST http://localhost:8000/api/deploy \
  -d '{"target": "rpi", "version": "2.0.0"}'
```

---

### FEAT-003: AI Analysis Engine

**Popis:** AI-powered code analysis  
**Umístění:** `core/ai-package/`  
**Modely:** TensorFlow, scikit-learn

**Funkce:**
- Code quality analysis
- Performance prediction
- Anomaly detection
- Recommendation engine

**Příklad:**
```python
from core.ai_package import Analyzer

analyzer = Analyzer()
results = analyzer.analyze_repo("STARCORE")
print(results.summary)
```

---

### FEAT-004: Home Assistant Integration

**Popis:** Smart home automation  
**Umístění:** `workspace/rpi5-homeassistant/`  

**Integrované komponenty:**
- Lights
- Climate
- Security
- Media

**Setup:**
```bash
cd workspace/rpi5-homeassistant
./deploy.sh
# Přístup: http://raspberrypi.local:8123
```

---

### FEAT-005: GitHub Catalog Management

**Popis:** Správa GitHub repozitářů  
**Umístění:** `workspace/rpi5-github-catalog/`  

**Funkce:**
- List repositories
- Track updates
- Manage dependencies
- Auto-sync

**API:**
```bash
GET  /api/repos              # List all
GET  /api/repos/{id}         # Get detail
POST /api/repos              # Create new
PUT  /api/repos/{id}         # Update
DELETE /api/repos/{id}       # Delete
```

---

### FEAT-006: Monitoring & Alerting

**Popis:** Real-time monitoring  
**Umístění:** `core/monitoring/`  

**Metriky:**
- CPU, Memory, Disk
- Network traffic
- Build status
- Deployment status

**Alerts:**
- Slack notifications
- Email alerts
- GitHub issues
- Custom webhooks

---

### FEAT-007: API Documentation

**Popis:** Auto-generated API docs  
**Umístění:** `/docs` (Swagger UI)  
**Port:** 8000

**Přístup:**
```
http://localhost:8000/docs
http://localhost:8000/redoc
```

---

## ⚙️ CONFIGURATION REFERENCE {#config}

### CFG-001: Environment Variables

**Soubor:** `.env` (nebo `.env.local`)

```bash
# GitHub
GITHUB_TOKEN=ghp_xxxxxxxxxxxx
GITHUB_OWNER=Fatalerorr69

# API
API_HOST=0.0.0.0
API_PORT=8000
API_WORKERS=4

# Database
DB_TYPE=sqlite
DB_PATH=./data/starcore.db

# AI/ML
AI_MODEL_PATH=./models/
AI_GPU_ENABLED=false

# RPi
RPI_ENABLED=true
RPI_HOSTNAME=raspberrypi.local
RPI_USER=pi

# Termux
TERMUX_ENABLED=true
TERMUX_HOSTNAME=termux.local
TERMUX_USER=u0_a0

# Logging
LOG_LEVEL=INFO
LOG_FORMAT=json

# Security
SECRET_KEY=your-secret-key-here
JWT_EXPIRATION=3600

# Monitoring
SENTRY_DSN=https://...
SLACK_WEBHOOK=https://hooks.slack.com/...
```

---

### CFG-002: Application Config (config.yaml)

```yaml
app:
  name: STARCORE
  version: 2.0.0
  debug: false
  env: production

api:
  host: 0.0.0.0
  port: 8000
  workers: 4
  timeout: 30
  max_connections: 100

database:
  type: sqlite
  path: ./data/starcore.db
  pool_size: 10
  echo: false

ai:
  enabled: true
  model_path: ./models/
  gpu_enabled: false
  batch_size: 32
  num_workers: 4

rpi:
  enabled: true
  hostname: raspberrypi.local
  port: 22
  user: pi
  timeout: 30

termux:
  enabled: true
  hostname: termux.local
  port: 8022
  user: u0_a0
  timeout: 30

logging:
  level: INFO
  format: json
  file: ./logs/starcore.log
  max_size: 10485760  # 10MB
  backup_count: 5

security:
  secret_key: ${SECRET_KEY}
  jwt_expiration: 3600
  cors_origins:
    - "*"
  require_https: true
  rate_limit: 1000
```

---

### CFG-003: Docker Compose Services

```yaml
version: '3.8'

services:
  starcore:
    build:
      context: .
      dockerfile: ci-cd/docker/Dockerfile
    ports:
      - "8000:8000"
    environment:
      - DEBUG=false
      - GITHUB_TOKEN=${GITHUB_TOKEN}
    volumes:
      - ./data:/app/data
      - ./logs:/app/logs
    depends_on:
      - db
      - redis

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: starcore
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  postgres_data:
```

---

### CFG-004: GitHub Actions Secrets

**Kde nastavit:** Settings → Secrets and variables → Actions

```
GITHUB_TOKEN              - GitHub API token
GITHUB_SSH_KEY            - SSH private key
TERMUX_SSH_KEY            - Termux SSH key
RPI_SSH_KEY               - RPi SSH key
RPI_HOST                  - RPi hostname/IP
RPI_USER                  - RPi username
DOCKER_TOKEN              - Docker registry token
SLACK_WEBHOOK             - Slack notification webhook
SENTRY_DSN                - Error tracking DSN
```

---

## 🔧 TROUBLESHOOTING GUIDE {#troubleshooting}

### TRB-001: Import errors

**Problém:** `ModuleNotFoundError: No module named 'starcore'`

**Řešení:**
```bash
# 1. Ensure virtual environment is active
source venv/bin/activate

# 2. Reinstall dependencies
pip install -e .

# 3. Add to PYTHONPATH
export PYTHONPATH="${PYTHONPATH}:$(pwd)"

# 4. Verify installation
python -c "import starcore; print(starcore.__version__)"
```

---

### TRB-002: Git merge conflicts

**Problém:** Konflikt při merge po git subtree

**Řešení:**
```bash
# 1. Identify conflicts
git status

# 2. Resolve conflicts manually
vim conflicting_file.py

# 3. Mark as resolved
git add conflicting_file.py

# 4. Complete merge
git commit -m "Merge: resolve conflicts"
```

---

### TRB-003: Docker build fails

**Problém:** `docker build` selhá

**Řešení:**
```bash
# 1. Clear cache
docker system prune -a

# 2. Build with verbose output
docker build --progress=plain .

# 3. Check Dockerfile
docker run --rm -it python:3.11 bash

# 4. Build minimal image
docker build -f Dockerfile.minimal -t starcore:slim .
```

---

### TRB-004: SSH connection timeout

**Problém:** SSH do Termux/RPi timeout

**Řešení:**
```bash
# 1. Check connectivity
ping termux.local
ping raspberrypi.local

# 2. Test SSH
ssh -v pi@raspberrypi.local

# 3. Check SSH config
cat ~/.ssh/config

# 4. Add SSH key
ssh-add ~/.ssh/rpi_rsa

# 5. Increase timeout
ssh -o ConnectTimeout=60 pi@raspberrypi.local
```

---

### TRB-005: CI/CD pipeline fails

**Problém:** GitHub Actions workflow failure

**Řešení:**
```bash
# 1. Check logs
gh run view <run-id> --log

# 2. Re-run failed jobs
gh run rerun <run-id>

# 3. Debug locally
act -j test

# 4. Check secrets
gh secret list

# 5. Update workflow
vim .github/workflows/ci.yml
git push
```

---

### TRB-006: Database connection error

**Problém:** `sqlite3.OperationalError: unable to open database file`

**Řešení:**
```bash
# 1. Create database directory
mkdir -p data
chmod 755 data

# 2. Initialize database
python scripts/init_db.py

# 3. Check file permissions
ls -la data/starcore.db

# 4. Reset database
rm -f data/starcore.db
python scripts/init_db.py

# 5. Verify connection
python -c "from core.db import init_db; init_db()"
```

---

### TRB-007: Memory/Performance issues

**Problém:** STARCORE spomaluje, vysoká paměť

**Řešení:**
```bash
# 1. Monitor resources
htop
docker stats

# 2. Profile code
python -m cProfile -s cumtime -m starcore.orchestrator

# 3. Memory profiling
pip install memory-profiler
python -m memory_profiler main.py

# 4. Optimize imports
python -X importtime -c "import starcore"

# 5. Reduce verbosity
export LOG_LEVEL=WARNING
```

---

## 📖 GLOSSARY & TERMS {#glossary}

| Term | Definice | Příklad |
|------|----------|---------|
| **MCP** | Model Context Protocol | `github-mcp` pro GitHub API |
| **Monorepo** | Jeden repozitář s více projekty | STARCORE s core/ + mobile/ |
| **git subtree** | Vložení repozitáře do podadresáře | `git subtree add --prefix=...` |
| **git submodule** | Odkaz na externí repozitář | `git submodule add ...` |
| **CI/CD** | Continuous Integration/Deployment | GitHub Actions workflows |
| **Docker** | Container runtime | `docker run starcore:latest` |
| **SSH** | Secure Shell | SSH key na RPi/Termux |
| **GPG** | GNU Privacy Guard | Podepisování commitů |
| **PAT** | Personal Access Token | GitHub API autentizace |
| **Webhook** | HTTP callback | GitHub → Slack notification |
| **Orchestration** | Koordinace služeb | STARCORE orchestrator |
| **Deployment** | Nasazení do produkce | Deploy na RPi/Termux |
| **Hotline** | Nástroj pro testování | Debugging v kontextu |

---

## 🔗 EXTERNAL LINKS & RESOURCES {#links}

### Official Documentation
- **GitHub Docs:** https://docs.github.com
- **Git Documentation:** https://git-scm.com/doc
- **Python Docs:** https://docs.python.org/3.11
- **Docker Docs:** https://docs.docker.com

### Tools & Services
- **GitHub CLI:** https://cli.github.com
- **Visual Studio Code:** https://code.visualstudio.com
- **Docker Desktop:** https://www.docker.com/products/docker-desktop
- **GitHub Copilot:** https://github.com/features/copilot

### Frameworks & Libraries
- **FastAPI:** https://fastapi.tiangolo.com
- **Pydantic:** https://docs.pydantic.dev
- **pytest:** https://docs.pytest.org
- **TensorFlow:** https://www.tensorflow.org

### Communities
- **GitHub Community:** https://github.community
- **Stack Overflow:** https://stackoverflow.com/questions/tagged/github
- **Reddit r/github:** https://www.reddit.com/r/github
- **GitHub Discussions:** https://github.com/Fatalerorr69/STARCORE/discussions

### Related Projects
- **Home Assistant:** https://www.home-assistant.io
- **Raspberry Pi:** https://www.raspberrypi.org
- **Termux:** https://termux.dev
- **Nymea:** https://nymea.io

---

## 📞 SUPPORT & HELP

### How to Get Help

1. **Search Documentation:** Zkus najít odpověď v tomhle manuálu
2. **Check Troubleshooting:** Podívej se na TRB-* sekce
3. **GitHub Issues:** https://github.com/Fatalerorr69/STARCORE/issues
4. **GitHub Discussions:** https://github.com/Fatalerorr69/STARCORE/discussions
5. **Stack Overflow:** Tag: `starcore`, `github`, `deployment`

### Reporting Bugs

**Format:**
```markdown
## Bug Report
- **Description:** Popis problému
- **Steps to Reproduce:** Jak replikovat
- **Expected Behavior:** Co by mělo být
- **Actual Behavior:** Co se stalo
- **Environment:** OS, Python version, etc.
- **Logs:** Stack trace, error messages
```

---

**Verze:** 1.0  
**Poslední aktualizace:** 2026-08-28  
**Další review:** 2026-09-15  

