```markdown
# STARCORE AUTO BUILDER – Kompletní sada skriptů

Tato sada obsahuje **čtyři nezávislé automatizované nástroje** pro analýzu, optimalizaci a sjednocování skriptů a konfiguračních souborů v rámci adresářové struktury `/root/starcore`. Každý skript je navržen pro specifický účel a může běžet paralelně s ostatními – využívá vlastní podsložky pro logy, dočasné soubory a výstupy.

---

## Přehled skriptů

| Skript | Verze | Hlavní účel |
|--------|-------|-------------|
| `starcore-auto-builder-v3.0.sh` | 3.0 | **Originální verze** – nepřetržité komplexní skenování celého `/root/starcore` a `/opt`, generování univerzálních skriptů pro všechny kategorie. |
| `starcore-auto-builder-lite-v3.1.sh` | 3.1-lite | **Odlehčená verze** – skenuje pouze `/root/starcore/bin` a přímé `.sh` soubory v `/root/starcore`. Provádí detailní bezpečnostní analýzu. |
| `starcore-auto-builder-final-v3.2.sh` | 3.2-final | **Sjednocovací verze** – načítá výstupy z originální a lite verze, odstraňuje duplicity a vytváří finální knihovnu s master spouštěčem. |
| `starcore-auto-builder-depth-v3.3.sh` | 3.3-depth | **Hloubková verze** – interaktivní skenování uživatelem zvoleného adresáře s omezenou hloubkou (výchozí 2) a filtrem podle přípon. |

---

## Společné vlastnosti všech verzí

- **Preflight kontroly** – před spuštěním ověří oprávnění, dostupné místo, povinné nástroje a případně je automaticky doinstaluje (při nastavení `AUTO_INSTALL_MISSING=1`).
- **Automatické opravy** – doplňuje chybějící shebang, převádí CRLF na LF, nastavuje spustitelný bit.
- **Živý dashboard** – zobrazuje průběh, statistiky (počet souborů, chyby, duplicity, bezpečnostní varování) a obnovuje se každých 10 sekund.
- **Ukládání stavu** – po přerušení pomocí `Ctrl+C` se stav uloží a při dalším spuštění lze pokračovat (resume).
- **Oddělené pracovní adresáře** – každá verze používá vlastní složky v rámci `/root/starcore`:
  - Výstupní skripty: `bin/optimized-{verze}`
  - Logy: `logs/auto-builder-{verze}`
  - Dočasné soubory: `run-{verze}`
  - Reporty: `reports/{verze}`

---

## Detailní popis jednotlivých skriptů

### 1. Originální verze – `starcore-auto-builder-v3.0.sh`

**Účel:**  
Komplexní, nepřetržitý běh pro skenování celého systému (`/root/starcore` a `/opt`). Generuje kategorizované integrační skripty pro fix, diagnostic, backup, ai, monitoring, deploy a other.

**Specifikace:**
- Skenuje rekurzivně všechny soubory s příponami: `.sh`, `.py`, `.js`, `.yaml`, `.json`, `.md`, `.txt`, `.conf`, `.service`, `.cron`.
- Navíc skenuje `/root/*.sh`, `*.md`, `*.txt` do hloubky 1.
- Provádí kontrolu syntaxe a závislostí.
- Detekuje duplicity podle názvu a MD5 hashe.
- Generuje speciální skripty (registry-manager, ai-orchestrator, knowledge-manager).

**Použití:**
```bash
chmod +x starcore-auto-builder-v3.0.sh
sudo ./starcore-auto-builder-v3.0.sh
```

**Přizpůsobení:**  
Můžete upravit proměnné na začátku skriptu:
- `SCAN_DIRS` – seznam adresářů ke skenování.
- `SLEEP_TIME` – pauza mezi cykly.
- `DASHBOARD_REFRESH` – interval obnovy dashboardu.

---

### 2. Lite verze – `starcore-auto-builder-lite-v3.1.sh`

**Účel:**  
Rychlá a cílená analýza pouze klíčových adresářů (`/root/starcore/bin` a přímé `.sh` v `/root/starcore`). Přidává **bezpečnostní analýzu** (detekce `eval`, `exec`, `rm -rf /`, neuzavřených proměnných, chybějícího shebangu).

**Specifikace:**
- Skenuje rekurzivně `/root/starcore/bin` a přímé `.sh` soubory v `/root/starcore`.
- Provádí stejné kontroly jako originál plus detailní bezpečnostní varování.
- Výstup ukládá do `bin/optimized-lite`.
- Generuje kategorie: fix, diagnostic, backup, ai, monitoring, deploy, security, other.

**Použití:**
```bash
chmod +x starcore-auto-builder-lite-v3.1.sh
sudo ./starcore-auto-builder-lite-v3.1.sh
```

**Volitelné proměnné:**
- `AUTO_INSTALL_MISSING=1` – automaticky doinstaluje chybějící nástroje.

---

### 3. Finalizační verze – `starcore-auto-builder-final-v3.2.sh`

**Účel:**  
Sjednocuje výstupy z originální a lite verze. Porovnává všechny `.sh` skripty z adresářů `optimized` a `optimized-lite`, odstraňuje duplicitní soubory (podle MD5) a vytváří finální knihovnu v `optimized-final`. Generuje master spouštěč `starcore-master.sh`, který umožňuje přehledné spouštění všech skriptů.

**Specifikace:**
- Čte zdrojové adresáře definované v poli `SOURCE_DIRS` (výchozí: `optimized` a `optimized-lite`).
- Pokud existuje více verzí stejného souboru s různým obsahem, ponechá je s příponou podle zdroje (např. `script_optimized.sh` a `script_optimized-lite.sh`).
- Generuje report o duplicitách a sloučení.
- Běží v nekonečné smyčce a průběžně aktualizuje finální knihovnu.

**Použití:**
```bash
chmod +x starcore-auto-builder-final-v3.2.sh
sudo ./starcore-auto-builder-final-v3.2.sh
```

**Rozšíření:**  
Pro přidání dalšího zdroje stačí upravit pole `SOURCE_DIRS` na začátku skriptu.

---

### 4. Hloubková verze – `starcore-auto-builder-depth-v3.3.sh`

**Účel:**  
Interaktivní nebo parametrizované skenování **libovolného adresáře** s omezenou hloubkou (výchozí 2) a filtrem podle přípon. Uživatel si volí cílovou cestu, typy souborů a maximální hloubku. Skript provádí detailní analýzu (stejnou jako lite verze) a navíc generuje **metadata report** (velikost, hash, datum modifikace).

**Specifikace:**
- Parametry: `--dir <cesta>`, `--types <přípony>`, `--depth <číslo>`, `--copy` (zkopíruje nalezené soubory do `run-depth/copied_files`).
- Pokud nejsou zadány parametry, skript se interaktivně zeptá.
- Skenuje pouze do zadané hloubky (maxdepth) a pouze soubory s uvedenými příponami.
- Generuje všechny výstupy jako ostatní verze (kategorizované skripty, dashboard, reporty).
- Metadata report obsahuje podrobnosti o každém souboru.

**Použití:**
```bash
chmod +x starcore-auto-builder-depth-v3.3.sh

# Interaktivní režim
./starcore-auto-builder-depth-v3.3.sh

# Režim s parametry
./starcore-auto-builder-depth-v3.3.sh --dir /root/starcore/scripts --types "sh py md" --depth 2 --copy
```

**Příklady:**
- Skenování `/root/starcore/scripts` do hloubky 2 pro soubory `.sh` a `.py`:
  ```bash
  ./starcore-auto-builder-depth-v3.3.sh --dir /root/starcore/scripts --types "sh py" --depth 2
  ```
- Skenování `/etc` pro `.conf` a `.service` do hloubky 1:
  ```bash
  ./starcore-auto-builder-depth-v3.3.sh --dir /etc --types "conf service" --depth 1
  ```

---

## Tipy pro souběžný běh

Všechny čtyři skripty mohou běžet **současně** bez vzájemného ovlivňování, protože používají oddělené pracovní adresáře. To umožňuje:

- Originální verzi nechat skenovat celý systém.
- Lite verzi paralelně analyzovat klíčové adresáře.
- Finalizační verzi průběžně sjednocovat výsledky.
- Depth verzi spouštět ad-hoc pro konkrétní složky.

Při spouštění více skriptů doporučujeme použít `screen` nebo `tmux` pro oddělené terminálové relace.

---

## Závěr

Tato sada skriptů tvoří ucelený nástroj pro automatickou správu, analýzu a optimalizaci skriptů a konfiguračních souborů v rámci STARCORE prostředí. Každá verze je navržena pro specifický scénář a díky modulární struktuře je snadno rozšiřitelná.

V případě potřeby úprav stačí upravit konfigurační proměnné na začátku příslušného skriptu.

---

**STARCORE Enterprise Architect – 2026**
```
