# 🎯 STARCORE REORGANIZATION - INTERACTIVE DECISION MATRIX

**Datum:** 2026-08-23  
**Status:** ⏳ ČEKÁM NA TVOJI ODPOVĚĎ  
**Verze:** 1.0  

---

## 📋 INSTRUKCE

Níže jsou klíčová rozhodnutí pro reorganizaci tvého GitHubu. **Vyber jednu možnost** pro každou sekci a odpověz v tomto formátu:

```
[SEKCE-NÁZEV]: VOLBA-X
```

**Příklad:**
```
[STARCORE-ARCHITEKTURA]: VOLBA-A
[ACODE-DUPLICITY]: VOLBA-B
```

---

## 🔴 SEKCE 1: STARCORE ARCHITEKTURA

**Otázka:** Jakou strukturu chceš pro STARCORE ekosystém?

### VOLBA A: 🟢 MONOREPO (Doporučeno)
- ✅ **Výhody:**
  - Jednotná CI/CD
  - Snadnější správa verzí
  - Jednodušší koordinace
  - Lepší testovací pokrytí
  
- ⚠️ **Nevýhody:**
  - Větší repozitář
  - Složitější git workflow
  
- 📊 **Obsah:**
  - Všech 6 STARCORE variant → 1 monorepo
  - Struktura: core/ + mobile/ + workspace/ + ci-cd/ + tools/
  - git subtree integraci
  
**Příklad:**
```
STARCORE/
├── core/
│   ├── orchestrator.py (z hlavního STARCORE)
│   ├── platform/       (z starcore-platform)
│   └── ai-package/     (z v12-AI-Package)
├── mobile/
│   └── termux-android/ (z starcore-android)
├── workspace/
│   ├── rpi5-ai/
│   ├── rpi5-homeassistant/
│   ├── rpi5-catalog/
│   └── rpi5-starkhost/
└── ci-cd/
    └── auto-builder/   (z AUTO-BUILDER-v3.0)
```

---

### VOLBA B: 🟡 WORKSPACE (Rozdělit)
- ✅ **Výhody:**
  - Oddělená repozitáře
  - Granulární kontrola
  - Snazší pro jednotlivé týmy
  
- ⚠️ **Nevýhody:**
  - Komplikovanější CI/CD
  - Nutná koordinace mezi repozitáři
  - Možné duplikace
  
- 📊 **Obsah:**
  ```
  STARCORE (jádro)
  STARCORE-platform (separátní)
  STARCORE-ai (separátní)
  STARCORE-mobile (separátní)
  STARCORE-workspace (separátní)
  ```

---

### VOLBA C: 🟠 HYBRID (Částečný Monorepo)
- Monorepo jen pro core + mobile
- RPi workspace zůstane jako separátní repos (s git submodule)
- AI package integrován do core
- Auto-builder zůstane separátní CI/CD

---

## 🟠 SEKCE 2: STARCORE-PLATFORM (4 OPEN ISSUES)

**Otázka:** Co dělat s `starcore-platform` repozitářem?

### VOLBA A: 🔀 SLOUČIT S HLAVNÍM STARCORE
- Zkontroluj obsah `starcore-platform`
- Merge do `core/platform/` v monorepu
- 4 issues přesunout do hlavního STARCORE
- Archivovat starý repozitář

**Příkaz:**
```bash
git subtree add --prefix=core/platform \
  https://github.com/Fatalerorr69/starcore-platform.git main
```

---

### VOLBA B: 📌 PONECHAT JAKO SEPARÁTNÍ
- `starcore-platform` zůstane samostatný
- Přidat jako git submodule v monorepu
- Řešit 4 issues v něm
- Synchronizace přes submodule update

**Příkaz:**
```bash
git submodule add \
  https://github.com/Fatalerorr69/starcore-platform.git core/platform
```

---

### VOLBA C: ❓ NEJDŘÍV AUDIT
- Před jakýmkoliv rozhodnutím: detailní analýza
- Zjistit, co obsahuje `starcore-platform`
- Porovnat s hlavním STARCORE
- Pak rozhodovat

**Kroky:**
```bash
git clone https://github.com/Fatalerorr69/starcore-platform.git audit
cd audit
git log --oneline -20        # Poslední commity
du -sh .                      # Velikost
find . -name "*.py" | wc -l   # Počet Python souborů
cat README.md                 # Obsah
```

---

## 🟡 SEKCE 3: STARCORE-v12-AI-PACKAGE

**Otázka:** Je STARCORE-v12-AI-Package novou verzí nebo oddělená komponenta?

### VOLBA A: 🔄 VERZE 12 (Nový release)
- Obsah z v12 → aktualizace hlavního STARCORE na v2.0
- Archivovat starou verzi
- Sloučit AI features do core/ai-package/
- Vytvořit tag `v2.0` v monorepu

---

### VOLBA B: 📦 ODDĚLENÁ KOMPONENTA
- v12 zůstane jako samostatná componenta
- Integrovat jako `core/ai-package/` (read-only mirror)
- Ponechat původní repozitář pro development
- Synchronizace přes git subtree pull

---

### VOLBA C: 🧪 EXPERIMENTÁLNÍ (Archivovat)
- v12 je experimentální verze
- Archivovat jako `archived/STARCORE-v12-AI-Package`
- Pokračovat s hlavním STARCORE
- Případné features extrahovat ručně

---

## 🟡 SEKCE 4: ACODE DEV MASTER DUPLICITY (3 repozitáře)

**Otázka:** Která je PRIMÁRNÍ verze acode dev tools?

### VOLBA A: 🎯 acode-dev-tools JE PRIMÁRNÍ
- Slučovat z: `.acode_dev_master` + `Acode_Dev_Master`
- Přejmenovat na: `acode-tools`
- Archivovat ostatní dva
- Integrovat do `tools/acode-tools/`

**Postup:**
```bash
git clone https://github.com/Fatalerorr69/acode-dev-tools.git
cd acode-dev-tools

# Přidat history z ostatních
git remote add old1 https://github.com/Fatalerorr69/.acode_dev_master
git remote add old2 https://github.com/Fatalerorr69/Acode_Dev_Master
git fetch old1 main
git fetch old2 main

# Merge
git merge old1/main -m "Merge: Consolidate .acode_dev_master"
git merge old2/main -m "Merge: Consolidate Acode_Dev_Master"
git push origin main
```

---

### VOLBA B: 🎯 Acode_Dev_Master JE PRIMÁRNÍ
- Slučovat z: `acode-dev-tools` + `.acode_dev_master`
- Přejmenovat na: `acode-tools`
- Archivovat ostatní
- Integrace do monorepa

---

### VOLBA C: 🤔 NEJDŘÍV KONTROLA
- Audit všech tří verzí
- Porovnat git log
- Zjistit rozdíly
- Pak volit primární

**Příkaz:**
```bash
for repo in acode-dev-tools .acode_dev_master Acode_Dev_Master; do
  git clone https://github.com/Fatalerorr69/$repo.git
  cd $repo
  echo "=== $repo ===" 
  echo "Files: $(find . -type f | wc -l)"
  echo "Commits: $(git log --oneline | wc -l)"
  echo "Latest: $(git log -1 --format=%ai)"
  cd ..
done
```

---

## 🟡 SEKCE 5: CONTAINERS TEMPLATE DUPLICITY (3 repozitáře)

**Otázka:** Jak konsolidovat 3 container varianty?

### VOLBA A: 🌳 SLOUČIT + BRANCHE
- `containers-template` je primární
- Integrovat `containers-pokus` → branch `feature/pokus`
- Integrovat `containers-templatemhv` → branch `variant/mhv`
- Archivovat ostatní
- Integrovat do `infra/containers/`

**Struktura:**
```
infra/containers/
├── main branch (templates-template)
├── feature/pokus branch
├── variant/mhv branch
├── docker-compose.yml
└── templates/
```

---

### VOLBA B: 🌳 BRANCHE PRE VŠECHNY
- Vytvořit nový repozitář `containers`
- Integrace všech 3 jako branche:
  - `main` (template)
  - `pokus` (pokus)
  - `mhv` (templatemhv)
- Archivovat originály

---

### VOLBA C: 📁 PONECHAT SEPARÁTNÍ
- Sloučit jen pokus + template
- MHV zůstane separátní
- Pokud máte speciální use case pro MHV

---

## 🔴 SEKCE 6: UBUNTU SERVERS DUPLICITY (2 repozitáře)

**Otázka:** ubuntu_gameserver vs. ubuntu_server1 - co s nimi?

### VOLBA A: 🗑️ ARCHIVOVAT OBĚ
- Jsou zastaralé
- Bez dokumentace
- Žádný commits dlouho
- **Řešení:** Archivovat jako nepoužívané

---

### VOLBA B: 🔀 SLOUČIT DO JEDNÉ
- Vytvořit `ubuntu-servers` jako sjednocený repozitář
- Sloučit obsah obou
- Archivovat původní
- Integrace do `infra/ubuntu-servers/`

---

### VOLBA C: 🧩 ZACHOVAT OBOJE
- Jsou relevantní pro různé use cases
- gameserver ≠ server1
- Ponechat jako separátní v `infra/`

**Potřeba:** Popis co dělá každý

---

## 🔴 SEKCE 7: FORKY - KEEP OR DELETE? (5 projektů)

**Otázka:** Co s 5 forky bez jasného účelu?

**Forky:**
- OctopusCLI (fork Octopus Deploy)
- ripe-atlas-cousteau (fork RIPE ATLAS)
- Sui (fork Android SuperUser)
- tsx (fork TypeScript Execute)
- VBBuildManager (fork VB6 Build Tool)

### VOLBA A: 🗑️ SMAZAT VŠECHNY
- Nejsou aktivně vyvíjeny
- Nejsou updatovány z upstream
- Zbytečný prostor
- Čistit GitHub

**Příkaz:**
```bash
for fork in OctopusCLI ripe-atlas-cousteau Sui tsx VBBuildManager; do
  gh repo delete Fatalerorr69/$fork --yes
done
```

---

### VOLBA B: 📦 ARCHIVOVAT
- Zachovat jako reference
- Archivovat (nelze editovat)
- Poskytnout v `git archive` formátu pro budoucí reference

**Příkaz:**
```bash
for fork in OctopusCLI ripe-atlas-cousteau Sui tsx VBBuildManager; do
  git clone https://github.com/Fatalerorr69/$fork.git
  cd $fork
  git archive --format tar.gz --output ../$fork.tar.gz main
  cd ..
done
```

---

### VOLBA C: 📁 PŘESUNOUT DO /FORKS/
- Vytvořit GitHub organizaci `Fatalerorr69-Forks`
- Přesunout tam všechny 5 forků
- Čištění hlavního účtu

---

## 🔴 SEKCE 8: NEAKTIVNÍ PROJEKTY (19 repozitářů)

**Otázka:** Archivovat všechny zastaralé projekty hromadně?

### SEZNAM:
```
1. AI-PROJECT-ANALYZER
2. GenesisCraft
3. Genesis_Aetema
4. MD_installer
5. MINIMAL-NAS-WEB-EDITION
6. PROJEKT-GENESIS-2026
7. platform
8. Starko-Ultimate-Recovery-USB
9. SuperNastroj
10. twisteros_supermanager
11. ubuntu_gameserver (pokud není zvolena B v sekci 6)
12. ubuntu_server1 (pokud není zvolena B v sekci 6)
13. Ultimate-Raspberry-Pi-5-All-in-One-Installer
14. ultra
15. universal-ai-codespace
16. uwp
17. Ollama (?)
18. Skripty (?)
19. nymeakiosk-ultimate-system (?)
```

### VOLBA A: ✅ ARCHIVOVAT VŠE
- Archivovat všech 19
- Jednoduchý cleanup
- Kdykoliv později můžeš unarchivovat

**Skript:**
```bash
ARCHIVE_LIST=(
  "AI-PROJECT-ANALYZER"
  "GenesisCraft"
  "Genesis_Aetema"
  "MD_installer"
  "MINIMAL-NAS-WEB-EDITION"
  "PROJEKT-GENESIS-2026"
  "platform"
  "Starko-Ultimate-Recovery-USB"
  "SuperNastroj"
  "twisteros_supermanager"
  "Ultimate-Raspberry-Pi-5-All-in-One-Installer"
  "ultra"
  "universal-ai-codespace"
  "uwp"
)

for repo in "${ARCHIVE_LIST[@]}"; do
  gh repo archive Fatalerorr69/"$repo" --yes
done
```

---

### VOLBA B: 🧹 AUDIT + SELEKTIVNÍ
- Nejdřív zkontrolovat každý
- Zachovat ty, které mají potenciál
- Archivovat jen opravdu zastaralé
- Více času, ale přesnější

**Audit skript:**
```bash
for repo in AI-PROJECT-ANALYZER GenesisCraft Genesis_Aetema ...; do
  echo "=== Auditing $repo ==="
  git clone --depth 1 https://github.com/Fatalerorr69/$repo.git
  cd $repo
  echo "Last commit: $(git log -1 --format=%ai)"
  echo "Total commits: $(git log --oneline | wc -l)"
  echo "Files: $(find . -type f | wc -l)"
  cd ..
  rm -rf $repo
done
```

---

### VOLBA C: 🗑️ SMAZAT + GIT ARCHIVE
- Zálohovat git archive (`.tar.gz`)
- Smazat repozitáře
- Archiv pro budoucnost
- Nejčistší řešení

---

## 🟢 SEKCE 9: SPECIÁLNÍ PROJEKTY (3 otazníky)

**Otázka:** Co s těmito 3 projekty?

### PROJEKT 1: Ollama (PowerShell wrapper)

- [ ] **A) Integrovat do `tools/ollama/`** - je to utility
- [ ] **B) Archivovat** - pokud není používaný
- [ ] **C) Ponechat separátní** - pokud má speciální obsah

---

### PROJEKT 2: Skripty (Shell - chaotický)

- [ ] **A) Reorganizovat a integrovat** - rozdělit do relevantních složek
- [ ] **B) Vyčistit a konsolidovat** - v `tools/scripts/`
- [ ] **C) Archivovat** - pokud jsou zastaralé

**Postup pro A:**
```bash
# Projít skript po skriptu a přesunout:
tools/
├── proxmox/scripts/
├── containers/scripts/
├── rpi/scripts/
├── acode/scripts/
└── general/scripts/
```

---

### PROJEKT 3: nymeakiosk-ultimate-system (1 issue)

- [ ] **A) Integrovat do `infra/nymea/`** - má dokumentaci
- [ ] **B) Ponechat separátní** - pokud je aktivně vyvíjen
- [ ] **C) Archivovat** - pokud není potřebný

---

## 🟢 SEKCE 10: CI/CD STRATEGIE

**Otázka:** Jaký CI/CD chceš implementovat?

### VOLBA A: 🚀 FULL CI/CD (Doporučeno)
- GitHub Actions pro všechno
- Lint + Test + Build + Deploy
- Automatické release taggery
- Auto-deployment na změny
- Slack notifications
- Code coverage reports

**Workflow:**
```
push → lint → test → build → deploy-dev → manual-deploy-prod
```

---

### VOLBA B: 🎯 MINIMÁLNÍ CI/CD
- Jen lint + test
- Manuální deployment
- Žádné automatizace
- Menší complexity

---

### VOLBA C: 📊 HYBRID
- Lint + Test automatické
- Build manuální
- Deploy manuální
- Optimalizace pro rychlost

---

## 🟢 SEKCE 11: DEPLOYMENT CÍLE

**Otázka:** Kterými platformami chceš automaticky deployovat?

- [ ] **Termux/Android** - Automatický sync + deploy
- [ ] **Raspberry Pi** - Automatický deployment
- [ ] **Development** - Local docker-compose
- [ ] **Cloud** - Budoucí plán
- [ ] **Žádné auto-deployment** - Jen manuální

---

## 📊 SHRNUTÍ ODPOVĚDÍ

**Prosím vyplň odpovědi v tomto formátu:**

```
[STARCORE-ARCHITEKTURA]: VOLBA-X
[STARCORE-PLATFORM]: VOLBA-X
[STARCORE-V12-AI-PACKAGE]: VOLBA-X
[ACODE-DUPLICITY]: VOLBA-X
[CONTAINERS-DUPLICITY]: VOLBA-X
[UBUNTU-SERVERS]: VOLBA-X
[FORKY]: VOLBA-X
[NEAKTIVNI-PROJEKTY]: VOLBA-X
[OLLAMA]: VOLBA-X
[SKRIPTY]: VOLBA-X
[NYMEAKIOSK]: VOLBA-X
[CICD-STRATEGIE]: VOLBA-X
[DEPLOYMENT-CILE]: [TERMUX, RPI, DEV, ...]
```

---

## 🎯 PŘÍKLAD ODPOVĚDI

```
[STARCORE-ARCHITEKTURA]: VOLBA-A
[STARCORE-PLATFORM]: VOLBA-A
[STARCORE-V12-AI-PACKAGE]: VOLBA-A
[ACODE-DUPLICITY]: VOLBA-A
[CONTAINERS-DUPLICITY]: VOLBA-A
[UBUNTU-SERVERS]: VOLBA-A
[FORKY]: VOLBA-A
[NEAKTIVNI-PROJEKTY]: VOLBA-A
[OLLAMA]: VOLBA-A
[SKRIPTY]: VOLBA-A
[NYMEAKIOSK]: VOLBA-A
[CICD-STRATEGIE]: VOLBA-A
[DEPLOYMENT-CILE]: [TERMUX, RPI, DEV]
```

---

**Jakmile vyplníš všechny odpovědi, vytvoříš:**

1. ✅ Implementation Guide (konkrétní skripty)
2. ✅ Migração Plan (detailní kroky)
3. ✅ Test Strategy (co testovat)
4. ✅ Rollback Plan (co když se pokazí)

**Připraven si? 🚀**

