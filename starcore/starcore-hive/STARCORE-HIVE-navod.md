# STARCORE HIVE v1.0 – Kompletní návod

> Systém autonomních agentů pro mapování, analýzu a správu souborové struktury na serveru fatalab.

---

## Obsah

1. [Co systém dělá](#1-co-systém-dělá)
2. [Architektura](#2-architektura)
3. [Požadavky](#3-požadavky)
4. [Instalace](#4-instalace)
5. [Spuštění](#5-spuštění)
6. [Dashboardy](#6-dashboardy)
7. [Konfigurace agentů](#7-konfigurace-agentů)
8. [Ovládání za běhu](#8-ovládání-za-běhu)
9. [HTTP API reference](#9-http-api-reference)
10. [Databáze – přímé dotazy](#10-databáze--přímé-dotazy)
11. [Řešení problémů](#11-řešení-problémů)
12. [Adresářová struktura](#12-adresářová-struktura)
13. [Migrace ze starých skriptů](#13-migrace-ze-starých-skriptů)

---

## 1. Co systém dělá

STARCORE HIVE je skupina spolupracujících agentů běžících jako systemd služby. Každý agent má přidělenou roli a pracuje z centrální fronty úkolů uložené v SQLite databázi.

**Co agenti dělají:**

- **Indexer** – prochází adresáře, zachycuje nové a změněné soubory, generuje navazující úkoly
- **Analyzer** – extrahuje metadata (velikost, hash MD5, typ, náhled obsahu), detekuje duplikáty
- **Inspector** – kontroluje syntaxi (.sh, .py, .js, .json, .yaml), hledá bezpečnostní vzory (eval, curl\|bash, rm -rf s proměnnou, hardcoded tokeny), ověřuje závislosti
- **Repairer** – automaticky opravuje nalezené problémy (chybějící shebang, CRLF konce řádků, chybějící exec bit); obsahuje circuit breaker – zastaví se po 5 opravách stejného souboru za hodinu
- **Librarian** – slučuje nalezené skripty do kategorizované centrální knihovny v `/root/starcore/bin/optimized/`
- **Watcher** – sleduje změny v adresářích (inotifywait nebo mtime-diff fallback), při detekci změny okamžitě spustí nový scan

Výsledky jsou k dispozici na:
- **Terminálový dashboard** – přehled v terminálu, aktualizuje se každých 10 sekund
- **HTTP dashboard** na `http://SERVER_IP:7979` – plný detail s grafy, přehledem findings a ovládáním

---

## 2. Architektura

```
┌─────────────────────────────────────────────────┐
│               STARCORE HIVE                      │
│                                                  │
│  ┌──────────────┐    ┌───────────────────────┐  │
│  │ orchestrator │───▶│  registry.db (SQLite)  │  │
│  │   .py        │    │  WAL mode              │  │
│  └──────┬───────┘    │  ┌─────────────────┐  │  │
│         │ start/     │  │ files           │  │  │
│         │ watchdog   │  │ findings        │  │  │
│         ▼            │  │ tasks  ◀────────┼──┼──┤
│  ┌──────────────┐    │  │ agents          │  │  │
│  │ agent-worker │    │  │ library         │  │  │
│  │ (indexer-1)  │    │  │ repair_attempts │  │  │
│  ├──────────────┤    │  └─────────────────┘  │  │
│  │ agent-worker │    └───────────────────────┘  │
│  │ (inspector-1)│                               │
│  ├──────────────┤    ┌───────────────────────┐  │
│  │ agent-worker │    │  dashboard_http.py     │  │
│  │ (repairer-1) │    │  port 7979             │  │
│  └──────────────┘    │  JSON API + HTML UI    │  │
│                      └───────────────────────┘  │
└─────────────────────────────────────────────────┘
```

**Tok dat:**

```
Watcher detekuje změnu
    ↓
Indexer vloží soubor do files, vygeneruje:
    → analyze_file (Analyzer)
    → inspect_file (Inspector)
        ↓
Inspector najde problém → vloží repair_file (Repairer)
Repairer opraví → Inspector znovu zkontroluje
Librarian periodicky merguje skripty do bin/optimized/
```

---

## 3. Požadavky

**Povinné:**

| Balíček | Verze | Instalace |
|---|---|---|
| bash | 5.0+ | výchozí na Debian/Ubuntu |
| python3 | 3.8+ | `apt-get install python3` |
| sqlite3 | 3.35+ (pro RETURNING) | `apt-get install sqlite3` |

**Volitelné (doporučené):**

| Balíček | Účel | Instalace |
|---|---|---|
| inotify-tools | Okamžitá detekce změn (Watcher) | `apt-get install inotify-tools` |
| python3-yaml | YAML konfigurace (jinak JSON) | `apt-get install python3-yaml` |

**Ověření:**

```bash
bash --version | head -1
python3 --version
sqlite3 --version
inotifywait --version 2>/dev/null && echo "inotify OK" || echo "inotify chybí"
```

---

## 4. Instalace

### 4.1 Přenos na server

```bash
# Z lokálního počítače
scp starcore-hive-v1.0.zip root@10.0.0.37:/tmp/

# Na serveru (fatalab)
ssh root@10.0.0.37
cd /tmp
unzip starcore-hive-v1.0.zip
cd release
```

### 4.2 Spuštění instalačního skriptu

```bash
# Standardní instalace
bash install.sh

# S vlastní cestou (pokud nechceš /root/starcore/hive)
bash install.sh --hive-dir=/data/starcore/hive

# Dry-run – zobrazí co by se stalo, nic nezapisuje
bash install.sh --dry-run
```

Instalace provede automaticky:

1. Ověření závislostí (bash 5+, python3 3.8+, sqlite3) – při chybě zastaví
2. Vytvoření adresářové struktury v `/root/starcore/hive/`
3. Zkopírování všech souborů
4. Inicializaci databáze (`registry.db`, 7 tabulek, WAL mode)
5. Nastavení oprávnění (hive/ dir 700, registry.db 600)
6. Registraci systemd služeb a povolení autostartu
7. Zápis výchozí konfigurace do `config/agents.json`
8. Ověření – kontrola syntax všech skriptů a počtu tabulek v DB

Příklad výstupu úspěšné instalace:

```
[1/8] Kontrola závislostí
  ✔ Root oprávnění
  ✔ Bash 5.2
  ✔ Python 3.12
  ✔ sqlite3 3.45.1
  ⚠ inotify-tools není k dispozici – Watcher použije mtime fallback

[2/8] Vytvoření adresářové struktury
  ✔ Adresář: /root/starcore/hive
  ✔ Adresář: /root/starcore/hive/lib
  ...

[8/8] Ověření instalace
  ✔ Existuje: /root/starcore/hive/registry.db
  ✔ db.sh syntax OK
  ✔ orchestrator.py syntax OK
  ✔ DB obsahuje 7 tabulek

════════════════════════════════════════════
  ✔ Instalace ÚSPĚŠNĚ dokončena!
```

---

## 5. Spuštění

### 5.1 Přes systemd (doporučeno)

```bash
# Spustit orchestrátor (spravuje agenty automaticky)
systemctl start starcore-orchestrator

# Spustit HTTP dashboard
systemctl start starcore-dashboard

# Zkontrolovat stav
systemctl status starcore-orchestrator starcore-dashboard
```

Po spuštění orchestrátor automaticky:
- Spustí všechny agenty dle `config/agents.json`
- Vloží první `scan_dir` úkoly pro `/root/starcore` a `/opt`
- Spustí watchdog smyčku

### 5.2 Manuálně (bez systemd, pro testování)

```bash
cd /root/starcore/hive

# Terminál 1 – orchestrátor
HIVE_DIR=/root/starcore/hive python3 orchestrator.py

# Terminál 2 – HTTP dashboard
HIVE_DIR=/root/starcore/hive python3 dashboard_http.py

# Terminál 3 – terminálový přehled
HIVE_DIR=/root/starcore/hive bash dashboard_terminal.sh
```

### 5.3 Dry-run mód (Repairer a Librarian jen hlásí, neopravují)

```bash
# Spustit orchestrátor v dry-run – bezpečné pro první ověření
HIVE_DIR=/root/starcore/hive python3 orchestrator.py --dry-run

# Nebo přes systemd s override
systemctl edit starcore-orchestrator
# Přidat do [Service]:
# ExecStart=
# ExecStart=/usr/bin/python3 /root/starcore/hive/orchestrator.py --hive-dir /root/starcore/hive --dry-run
```

### 5.4 Ověření že systém běží

```bash
# Systemd stav
systemctl is-active starcore-orchestrator starcore-dashboard

# Agenti v DB
sqlite3 /root/starcore/hive/registry.db \
  "SELECT agent_id, status, tasks_completed FROM agents;"

# Prvních 5 úkolů ve frontě
sqlite3 /root/starcore/hive/registry.db \
  "SELECT id, type, target_role, status FROM tasks LIMIT 5;"
```

---

## 6. Dashboardy

### 6.1 Terminálový dashboard

Spuštění v tmux nebo screen panelu:

```bash
# V tmux
tmux new-window -n "hive-dash"
HIVE_DIR=/root/starcore/hive bash /root/starcore/hive/dashboard_terminal.sh

# Nebo přímé spuštění
HIVE_DIR=/root/starcore/hive DASHBOARD_REFRESH=10 \
  bash /root/starcore/hive/dashboard_terminal.sh
```

Zobrazuje:

```
╔════════════════════════════════════════════════════════════════╗
║ STARCORE HIVE – Live Dashboard  2026-07-01 12:34:56  DB v1
║ DB: /root/starcore/hive/registry.db  •  HTTP: http://localhost:7979
╠════════════════════════════════════════════════════════════════╣
║ AGENTI
║  indexer-1          idle       hb:3s    done:  47 fail:  0
║  analyzer-1         working    hb:1s    done: 112 fail:  0 [task#234]
║  analyzer-2         idle       hb:8s    done:  98 fail:  1
║  inspector-1        working    hb:2s    done:  89 fail:  0 [task#235]
║  inspector-2        idle       hb:5s    done:  76 fail:  0
║  repairer-1         idle       hb:4s    done:  12 fail:  0
║  librarian-1        idle       hb:15s   done:   3 fail:  0
║  watcher-1          idle       hb:9s    done:   8 fail:  0
╠────────────────────────────────────────────────────────────────╣
║ FRONTA ÚKOLŮ
║  ████████████████████░░░░░░░░░░░░░░░ 312/401 hotovo
║  pending:   89  claimed:  2  done:  312  failed:   0
║  Pending dle role: analyzer:45 inspector:44
╠────────────────────────────────────────────────────────────────╣
║ FINDINGS  (nevyřešených: 23  •  vyřešených: 8)
║  ████████░░░░░░░░░░░░░░░░░░░░░░░░░░░ vyřešeno
║  syntax:  3  security: 14  missing_dep:  5  dup:  1  manual:  0
╠────────────────────────────────────────────────────────────────╣
║ INDEX SOUBORŮ  celkem:401  │  .sh:312  .py:45  .md:28
║ KNIHOVNA  vygenerovaných skriptů: 7
╚════════════════════════════════════════════════════════════════╝
Ctrl+C pro ukončení  •  refresh za 10s  •  detail: http://localhost:7979
```

**Proměnné prostředí pro dashboard:**

```bash
DASHBOARD_REFRESH=10    # interval překreslení v sekundách (výchozí: 10)
HTTP_PORT=7979          # port zobrazený v patičce (výchozí: 7979)
```

### 6.2 HTTP Dashboard

Otevři v prohlížeči nebo z mobilu:

```
http://10.0.0.37:7979
```

Sekce dashboardu:

- **Přehled** – statistiky na první pohled (soubory, úkoly, findings, knihovna), progress bary
- **Agenti** – tabulka všech agentů, stav, heartbeat, statistiky, tlačítko restart
- **Fronta úkolů** – breakdown pending/claimed/done/failed, pending dle role
- **Findings** – souhrn dle typu a závažnosti
- **Index souborů** – počty dle typu, posledních 5 indexovaných
- **Knihovna skriptů** – vygenerované merged skripty (výstup Librariana)
- **Posledních 10 nálezů** – detailní tabulka s cestou, typem, zprávou, časem

Dashboard se automaticky obnovuje každých 15 sekund. Tlačítko **↺** u agenta ho označí jako crashed – orchestrátor ho při příštím watchdog ticku (do 30 sekund) restartuje.

---

## 7. Konfigurace agentů

Konfigurační soubor: `/root/starcore/hive/config/agents.json`

```json
{
  "scan_interval_seconds": 300,
  "watchdog_interval_seconds": 30,
  "claim_release_interval": 60,
  "librarian_interval_seconds": 1800,
  "claim_timeout_seconds": 300,
  "agent_stale_seconds": 60,
  "scan_dirs": [
    "/root/starcore",
    "/opt"
  ],
  "agents": [
    { "role": "indexer",   "count": 1 },
    { "role": "analyzer",  "count": 2 },
    { "role": "inspector", "count": 2 },
    { "role": "repairer",  "count": 1 },
    { "role": "librarian", "count": 1 },
    { "role": "watcher",   "count": 1 }
  ]
}
```

**Popis parametrů:**

| Parametr | Výchozí | Popis |
|---|---|---|
| `scan_interval_seconds` | 300 | Jak často orchestrátor vloží nové scan_dir úkoly (sekundy) |
| `watchdog_interval_seconds` | 30 | Jak často kontroluje živost agentů |
| `claim_release_interval` | 60 | Jak často uvolňuje osiřelé claimed úkoly |
| `librarian_interval_seconds` | 1800 | Jak často spustí merge do knihovny |
| `claim_timeout_seconds` | 300 | Po kolika sekundách je claimed úkol považován za osiřelý |
| `agent_stale_seconds` | 60 | Po kolika sekundách bez heartbeatu je agent "crashed" |
| `scan_dirs` | viz výše | Adresáře ke skenování (seznam) |
| `agents[].count` | viz výše | Počet instancí každé role |

**Přidání skenovaného adresáře:**

```json
"scan_dirs": ["/root/starcore", "/opt", "/home/starko"]
```

**Zvýšení počtu Inspector agentů (pro rychlejší analýzu):**

```json
{ "role": "inspector", "count": 4 }
```

Po změně konfigurace:

```bash
systemctl restart starcore-orchestrator
```

---

## 8. Ovládání za běhu

### 8.1 Základní příkazy

```bash
# Stav všech HIVE služeb
systemctl status starcore-orchestrator starcore-dashboard

# Zastavit vše
systemctl stop starcore-orchestrator starcore-dashboard

# Restartovat orchestrátor (+ všechny agenty)
systemctl restart starcore-orchestrator

# Logy orchestrátoru (live)
journalctl -u starcore-orchestrator -f

# Logy konkrétního agenta
journalctl -u starcore-agent@inspector-1 -f

# Logy HTTP dashboardu
journalctl -u starcore-dashboard -f
```

### 8.2 Škálování agentů za běhu

```bash
# Přidat druhého Repaireru
systemctl start starcore-agent@repairer-2

# Přidat třetího Inspectora
systemctl start starcore-agent@inspector-3

# Zastavit konkrétního agenta
systemctl stop starcore-agent@analyzer-2

# Zobrazit všechny běžící agenty
systemctl list-units 'starcore-agent@*'
```

### 8.3 Manuální spuštění úkolu

```bash
# Okamžitý rescan konkrétního adresáře přes DB
sqlite3 /root/starcore/hive/registry.db \
  "INSERT INTO tasks (type, target_role, payload_json, priority)
   VALUES ('scan_dir', 'indexer', '{\"path\":\"/root/starcore\"}', 1);"

# Přes HTTP API (z jakéhokoliv zařízení v síti)
curl -X POST http://10.0.0.37:7979/api/task/add \
  -H "Content-Type: application/json" \
  -d '{"path": "/root/starcore"}'
```

### 8.4 Restart konkrétního agenta

```bash
# Přes systemd
systemctl restart starcore-agent@inspector-1

# Přes HTTP API (označí agenta jako crashed, orchestrátor ho do 30s restartuje)
curl -X POST http://10.0.0.37:7979/api/agent/restart \
  -H "Content-Type: application/json" \
  -d '{"agent_id": "inspector-1"}'
```

### 8.5 Zobrazení findings

```bash
# Souhrn dle typu
sqlite3 /root/starcore/hive/registry.db \
  "SELECT finding_type, severity, COUNT(*) as cnt
   FROM findings WHERE resolved_at IS NULL
   GROUP BY finding_type, severity ORDER BY cnt DESC;"

# Bezpečnostní varování (nezvyřešená)
sqlite3 /root/starcore/hive/registry.db \
  "SELECT file_path, message FROM findings
   WHERE finding_type='security_warning' AND resolved_at IS NULL
   ORDER BY detected_at DESC LIMIT 20;"

# Syntax chyby čekající na opravu
sqlite3 /root/starcore/hive/registry.db \
  "SELECT f.file_path, f.message
   FROM findings f
   WHERE f.finding_type='syntax_error' AND f.resolved_at IS NULL;"
```

### 8.6 Čištění

```bash
# Odstranit zastaralé "done" úkoly starší než 7 dní
sqlite3 /root/starcore/hive/registry.db \
  "DELETE FROM tasks
   WHERE status='done'
     AND completed_at < strftime('%s','now','-7 days');"

# Záloha databáze
sqlite3 /root/starcore/hive/registry.db \
  ".backup /root/starcore/reports/registry-backup-$(date +%Y%m%d).db"

# Komprimace DB (po hromadném mazání)
sqlite3 /root/starcore/hive/registry.db "VACUUM;"
```

---

## 9. HTTP API reference

Všechny GET endpointy vrací JSON. Base URL: `http://10.0.0.37:7979`

### GET `/`
Hlavní HTML dashboard s auto-refresh 15s.

### GET `/api/status`
Kompletní snapshot stavu systému v jednom volání.

```bash
curl http://10.0.0.37:7979/api/status | python3 -m json.tool
```

Odpověď obsahuje: `timestamp`, `agents`, `tasks` (souhrn), `pending_by_role`, `findings_summary_list`, `findings_total_unresolved`, `findings_total_resolved`, `files`, `recent_files`, `library`, `recent_findings`.

### GET `/api/agents`
Seznam všech registrovaných agentů.

```json
[
  {
    "agent_id": "inspector-1",
    "role": "inspector",
    "pid": 1234,
    "status": "working",
    "last_heartbeat": 1751234567,
    "tasks_completed": 89,
    "tasks_failed": 0,
    "current_task_id": 235
  }
]
```

### GET `/api/tasks`
Souhrn fronty + seznam posledních failed úkolů.

### GET `/api/findings`
Všechna nevyřešená findings (max 200, seřazena od nejnovějšího).

```bash
# Filtrování na clientu (jq)
curl -s http://10.0.0.37:7979/api/findings | \
  python3 -c "import sys,json; [print(f['file_path'],f['finding_type']) \
  for f in json.load(sys.stdin) if f['severity']=='error']"
```

### GET `/api/files`
Posledních 50 indexovaných souborů (seřazeno dle `last_seen`).

### GET `/api/library`
Katalog vygenerovaných skriptů z Librariana.

### POST `/api/task/add`
Přidá scan_dir úkol pro Indexera.

```bash
curl -X POST http://10.0.0.37:7979/api/task/add \
  -H "Content-Type: application/json" \
  -d '{"path": "/home/starko"}'
```

### POST `/api/agent/restart`
Označí agenta jako crashed – orchestrátor ho restartuje do 30 sekund.

```bash
curl -X POST http://10.0.0.37:7979/api/agent/restart \
  -H "Content-Type: application/json" \
  -d '{"agent_id": "repairer-1"}'
```

---

## 10. Databáze – přímé dotazy

Databáze: `/root/starcore/hive/registry.db`

```bash
# Otevřít interaktivní shell
sqlite3 /root/starcore/hive/registry.db
```

### Nejčastější dotazy

```sql
-- Kolik souborů je indexovaných dle typu?
SELECT file_type, COUNT(*) FROM files
WHERE status='active' GROUP BY file_type ORDER BY COUNT(*) DESC;

-- Duplicitní soubory (stejný obsah, jiná cesta)
SELECT f1.path, f2.path, f1.hash_md5
FROM files f1 JOIN files f2
  ON f1.hash_md5 = f2.hash_md5 AND f1.path < f2.path
WHERE f1.status='active' AND f2.status='active'
LIMIT 20;

-- Top 10 souborů s nejvíce findings
SELECT file_path, COUNT(*) as cnt
FROM findings WHERE resolved_at IS NULL
GROUP BY file_path ORDER BY cnt DESC LIMIT 10;

-- Stav fronty úkolů
SELECT status, COUNT(*), target_role FROM tasks
GROUP BY status, target_role ORDER BY status, target_role;

-- Agenti s posledním heartbeatem
SELECT agent_id, status,
  datetime(last_heartbeat,'unixepoch','localtime') as last_hb,
  tasks_completed, tasks_failed
FROM agents ORDER BY role;

-- Skripty v knihovně
SELECT script_path, category, version,
  datetime(updated_at,'unixepoch','localtime') as updated
FROM library ORDER BY updated DESC;

-- Soubory, které Repairer opakovaně opravoval (circuit breaker kandidáti)
SELECT file_path, COUNT(*) as attempts
FROM repair_attempts
WHERE attempted_at > strftime('%s','now','-1 hour')
GROUP BY file_path ORDER BY attempts DESC;
```

---

## 11. Řešení problémů

### Agenti se nespouštějí

```bash
# Zkontrolovat logy orchestrátoru
journalctl -u starcore-orchestrator -n 50

# Ověřit, že schema.sql existuje
ls -la /root/starcore/hive/schema.sql

# Ověřit DB
sqlite3 /root/starcore/hive/registry.db ".tables"

# Spustit agenta ručně pro debug
HIVE_DIR=/root/starcore/hive \
DB_PATH=/root/starcore/hive/registry.db \
SCAN_DIRS=/root/starcore \
ALLOWED_REPAIR_ROOTS=/root/starcore \
bash /root/starcore/hive/agents/agent-worker.sh indexer indexer-debug
```

### "database is locked" chyby v logu

Znamená vysokou souběžnou zátěž. Řešení:

```bash
# Snížit počet paralelních agentů v agents.json
# např. inspector count: 4 → 2

# Nebo zvýšit busy_timeout (v db.sh, výchozí 5000ms)
grep "timeout" /root/starcore/hive/lib/db.sh
```

### Fronta se plní a agenti nestíhají

```bash
# Zkontrolovat pending dle role
sqlite3 /root/starcore/hive/registry.db \
  "SELECT target_role, COUNT(*) FROM tasks WHERE status='pending'
   GROUP BY target_role;"

# Přidat agenty pro přetíženou roli
systemctl start starcore-agent@analyzer-3
systemctl start starcore-agent@inspector-3
```

### Repairer opravuje stejný soubor dokola

Circuit breaker se aktivuje po 5 opravách za hodinu a vytvoří finding `needs_manual_review`. Zkontroluj ručně:

```bash
sqlite3 /root/starcore/hive/registry.db \
  "SELECT file_path, outcome, datetime(attempted_at,'unixepoch','localtime')
   FROM repair_attempts ORDER BY attempted_at DESC LIMIT 20;"

# Podívej se na findings pro ten soubor
sqlite3 /root/starcore/hive/registry.db \
  "SELECT * FROM findings WHERE file_path LIKE '%problematic_file%';"
```

### Watcher nedetekuje změny okamžitě

Bez `inotifywait` Watcher používá mtime-diff fallback s 30s spánkem. Instalace:

```bash
apt-get install -y inotify-tools
systemctl restart starcore-agent@watcher-1
```

### HTTP dashboard není dostupný

```bash
# Zkontrolovat stav service
systemctl status starcore-dashboard

# Zkontrolovat, zda port 7979 naslouchá
ss -tlnp | grep 7979

# Zkontrolovat firewall
iptables -L INPUT -n | grep 7979
# nebo
ufw status | grep 7979

# Otevřít port pokud je uzavřený
ufw allow 7979/tcp
```

### Starý agent se nezaregistroval v DB po restartu

```bash
# Ručně smazat starý záznam
sqlite3 /root/starcore/hive/registry.db \
  "DELETE FROM agents WHERE agent_id='indexer-1';"

# Restartovat agenta
systemctl restart starcore-agent@indexer-1
```

---

## 12. Adresářová struktura

```
/root/starcore/
├── hive/                           ← kořen HIVE systému
│   ├── registry.db                 ← SQLite databáze (WAL, 600 perms)
│   ├── schema.sql                  ← DB schema (idempotentní)
│   ├── orchestrator.py             ← Správce agentů + fronta
│   ├── dashboard_http.py           ← HTTP server port 7979
│   ├── dashboard_terminal.sh       ← Terminálový přehled
│   ├── lib/
│   │   ├── db.sh                   ← SQLite wrapper (claim, heartbeat...)
│   │   └── common.sh               ← Analytické funkce
│   ├── agents/
│   │   └── agent-worker.sh         ← Generický worker všech 6 rolí
│   ├── config/
│   │   └── agents.json             ← Konfigurace rolí a intervalů
│   └── logs/
│       ├── orchestrator/           ← Logy orchestrátoru
│       ├── indexer/indexer-1.log
│       ├── analyzer/
│       ├── inspector/
│       ├── repairer/
│       ├── librarian/
│       └── watcher/
├── bin/
│   └── optimized/                  ← Výstup Librariana (merged skripty)
│       ├── starcore-fix-all.sh
│       ├── starcore-backup-all.sh
│       └── ...
├── reports/                        ← Reporty a zálohy DB
└── archive/
    └── legacy-builder/             ← Archivované staré skripty (migrace)
        ├── starcore-auto-builder-v3_0.sh
        └── ...

/etc/systemd/system/
├── starcore-orchestrator.service
├── starcore-dashboard.service
└── starcore-agent@.service         ← Template unit
```

---

## 13. Migrace ze starých skriptů

Orchestrátor automaticky migruje staré soubory při prvním spuštění:

- `bin/optimized/.builder_state` → `archive/legacy-builder/`
- `starcore-auto-builder-v3_0.sh` → `archive/legacy-builder/`
- `starcore-auto-builder-lite.sh` → `archive/legacy-builder/`
- `starcore-auto-builder-final.sh` → `archive/legacy-builder/`
- `starcore-auto-builder-deep.sh` → `archive/legacy-builder/`

Soubory se pouze **přesunou** (ne smažou), takže je lze v případě potřeby obnovit:

```bash
ls /root/starcore/archive/legacy-builder/

# Obnovit konkrétní soubor
mv /root/starcore/archive/legacy-builder/starcore-auto-builder-v3_0.sh \
   /root/starcore/
```

Migraci lze spustit i samostatně bez spuštění agentů:

```bash
python3 /root/starcore/hive/orchestrator.py --migrate-only
```

---

## Rychlý přehled příkazů

```bash
# ── Start / Stop ───────────────────────────────────────────
systemctl start   starcore-orchestrator starcore-dashboard
systemctl stop    starcore-orchestrator starcore-dashboard
systemctl restart starcore-orchestrator

# ── Stav ───────────────────────────────────────────────────
systemctl status starcore-orchestrator starcore-dashboard
systemctl list-units 'starcore-agent@*'

# ── Dashboardy ─────────────────────────────────────────────
HIVE_DIR=/root/starcore/hive bash /root/starcore/hive/dashboard_terminal.sh
# HTTP: http://10.0.0.37:7979

# ── Logy ───────────────────────────────────────────────────
journalctl -u starcore-orchestrator -f
journalctl -u starcore-agent@inspector-1 -f

# ── Škálování ──────────────────────────────────────────────
systemctl start starcore-agent@inspector-3
systemctl stop  starcore-agent@analyzer-2

# ── Manuální scan ──────────────────────────────────────────
curl -X POST http://10.0.0.37:7979/api/task/add \
  -H "Content-Type: application/json" -d '{"path":"/root/starcore"}'

# ── DB quick stats ─────────────────────────────────────────
sqlite3 /root/starcore/hive/registry.db \
  "SELECT 'files' as t, COUNT(*) FROM files WHERE status='active'
   UNION SELECT 'findings', COUNT(*) FROM findings WHERE resolved_at IS NULL
   UNION SELECT 'pending', COUNT(*) FROM tasks WHERE status='pending';"

# ── Záloha DB ──────────────────────────────────────────────
sqlite3 /root/starcore/hive/registry.db \
  ".backup /root/starcore/reports/registry-$(date +%Y%m%d).db"
```
