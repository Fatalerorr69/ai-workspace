# Hluboká analýza: starcore-platform

## Základní informace
- **Cílová cesta:** $targetPath
- **Detekované technologie:** Python, Shell
- **Počet skriptů:** 553

## Popis z README
# STARCORE Platform

**AI-Powered Infrastructure Operating Platform**

![Version](https://img.shields.io/badge/version-0.1.0-blue)
![License](https://img.shields.io/badge/license-Apache--2.0-green)
![Status](https://img.shields.io/badge/status-active--development-orange)

---

## Overview

STARCORE Platform is an infrastructure orchestration platform for homelabs and self-hosted environments, currently focused on **Proxmox VE** and **Docker**.

It lets you describe infrastructure declaratively in YAML "blueprints" and have STARCORE plan and execute the required provider actions, sequentially or, when resources declare dependencies, in parallel.

This README reflects the **actual current state of the codebase**, not the long-term vision. The long-term vision is documented separately in `docs/ses/`.

---

## What Works Today

| Component | Status | Description |
|---|---|---|
| Provider SDK | Done | BaseProvider interface, registry, exceptions |
| API Authentication | Done | X-API-Key header required on all endpoints except / and /health; returns 503 if server has no key configured |
| Docker Provider | Done | Real implementation via docker-py: connect, health, list, create/start/stop/remove containers |
| Proxmox Provider | Done | Real implementation via proxmoxer: connect, health, list, start/stop/shutdown VMs and LXC containers, clone VM or LXC from template |
| Blueprint Engine | Done | Load YAML, plan, execute. Sequential (BlueprintExecutor) or parallel graph execution (Scheduler + TaskGraph) via depends_on |
| CLI | Done | starcore blueprint plan/run [--parallel], starcore health, starcore doctor [--fast], starcore audit |
| Core API | Done | FastAPI: providers, blueprint plan/run, run history |
| Persistence | Done | SQLite (via SQLAlchemy) stores blueprint run history and task results |
| Config | Done | .env-based settings via pydantic-settings; STARCORE_LOG_JSON for structured JSON logging |
| Observability | Done | GET /metrics — Prometheus text format, authenticated; structured loguru logging (STARCORE_LOG_JSON) |
| Environment Detection | Done | starcore audit/doctor/diagnose and GET /diagnostics report runtime_environment (proxmox-host / container / local), OS platform (incl. WSL), cloud provider (AWS/GCP/Azure, diagnose only), and calling-client platform (browser/mobile/CLI, GET /diagnostics only) |
| Security | Done | Bandit SAST + gitleaks secret scanning on every PR and nightly; pip-audit dependency vulnerability scan |
| Alembic Migrations | Done | migrations/ tracks schema via `alembic upgrade head`; create_all() runs only once, on a genuinely fresh/untracked database, and is stamped at head immediately after -- an existing database whose recorded revision doesn't match head fails startup instead |
| Plugin System | Done | Plugins in plugins/<name>/ expose register(context) to add custom providers (context.registry) and subscribe to blueprint execution events (context.events); discoverable via 'starcore plugins' and GET /plugins. **Not sandboxed** -- see `docs/plugins.md` |
| Diagnostics | Done | `starcore diagnose` CLI and `GET /diagnostics` API report config, database, migrations, and Docker/Proxmox provider health including node CPU/RAM/disk, storage, and orphaned resource detection |
| Web Dashboard | Done (read-only) | Static HTML/JS at GET /ui, calls the existing API (providers, runs, diagnostics) via fetch() with an X-API-Key stored in localStorage. No build step |
| Proxmox Snapshots | Done | 'starcore snapshot create/list/delete/rollback' and POST /resources/action manage VM/LXC snapshots directly; delete and rollback show a dry-run diff of what will change and prompt for confirmation unless --yes is passed |
| Proxmox Template Aliases | Done | Blueprints can use 'config: {template: "ubuntu-24.04"}' instead of a raw template_vmid; resolved automatically before plan/run via Proxmox's template list, with a clear error if the name is missing or ambiguous |
| Resource Lifecycle Actions | Done | 'starcore resource action <provider> <action> <resource>' and POST /resources/action run a single action (start/stop/shutdown/destroy for Proxmox, start/stop/remove for Docker) against one resource, independent of any blueprint |
| Proxmox Environment Discovery | Done | 'starcore proxmox discover' and GET /proxmox/discover catalog node capacity, storage, available VM/LXC templates, and network bridges, used to tailor deployments before they run |
| AI Blueprint Generation | Done (requires API key/endpoint) | 'starcore ai generate "<description>"' and POST /ai/generate-blueprint translate natural language into a validated blueprint YAML via a pluggable provider: Anthropic (STARCORE_ANTHROPIC_API_KEY) or any OpenAI-compatible /v1/chat/completions server — Ollama, LM Studio, vLLM, LocalAI, OpenAI itself (STARCORE_AI_PROVIDER=openai-compatible, STARCORE_AI_BASE_URL, STARCORE_AI_MODEL) |
| Request Correlation | Done | Every HTTP response carries X-Request-ID (caller-supplied or generated); bound to every log line emitted while handling that request |
| Tests | 805 collected (current regression baseline) | ruff, pyright, pytest (100% coverage floor, incl. Hypothesis property tests), pre-commit, CI on every PR |

## Production Limitations

Not exhaustive — see `SECURITY.md` and `docs/security.md` for the full
security-relevant list. The headline ones: no per-user identity or RBAC
(single shared API key, by design, for single-operator/small-team homelab
deployments — see ADR-012), plugins are not sandboxed (ADR-011), and
provider API calls within a `--parallel` wave are not rate-limited
(ADR-013 — no concurrency limit has been needed yet at homelab scale, but
it's a documented, deliberately revisitable decision, not an oversight).

## Roadmap / Vision (Not Started)

Longer-term direction, described in more detail in `docs/ses/`. Nothing
in this section exists yet.

| Component | Notes |
|---|---|
| Installer Studio | Not started |
| Dashboard (Web UI) | Not started — distinct from the read-only dashboard above |
| AI Brain | Not started |
| Marketplace | Not started |

---

## Quick Start

```bash
uv sync --extra dev
cp .env.example .env
uv run starcore blueprint plan packages/blueprints/examples/basic.yaml
uv run starcore blueprint run packages/blueprints/examples/basic.yaml
```

Run the API:

```bash
uv run uvicorn core.main:app --reload
```

## Example Blueprint

```yaml
name: demo
resources:
  - name: db
    provider: docker
    kind: container
    config:
      image: postgres:17
  - name: web-vm
    provider: proxmox
    kind: vm
    config:
      node: fatalab
      template_vmid: 9000
    depends_on:
      - db
```

Run it in parallel-aware mode: `starcore blueprint run <path> --parallel`

---

## Repository Structure

```
apps/cli/              CLI entry point (Typer)
packages/core/          FastAPI app, config, database, persistence models
packages/blueprints/    Blueprint models, loader, planner, executor
packages/orchestrator/  Task, TaskGraph, Scheduler
packages/provider_sdk/  BaseProvider, registry, exceptions
packages/providers/     Docker and Proxmox implementations
packages/ai/            Pluggable AI blueprint generation (Anthropic, OpenAI-compatible)
scripts/                Standalone doctor/health scripts (no CLI dependency)
tests/                  pytest test suite
docs/ses/               Long-term engineering specification and vision docs
```

---

## Docker Deployment

```bash
cp .env.example .env
docker compose up -d --build api
```

The `api` service builds this repo, runs Alembic migrations, and starts the FastAPI server on port 8000. SQLite data persists in the `starcore-data` volume. Postgres, Redis, and NATS services are also defined in `docker-compose.yml` for future use but are not yet wired into the application.

---

## Development

```bash
uv sync --extra dev
uv run ruff check .
uv run pyright
uv run pytest -q
uv run pre-commit run --all-files
```

CI runs the same checks on every pull request.

**Database schema:** a brand-new database is created and tracked
automatically on first run (nothing to do). If you already have a
database from a previous version and a new migration has been added since
(`migrations/versions/`), run `uv run alembic upgrade head` before
starting the app — STARCORE Platform will refuse to start against a
database whose schema is out of date rather than run with a silently
incomplete schema.

---

## Documentation

Long-term vision and engineering specifications live in `docs/ses/`. They describe where the project is headed, not its current state. See the tables above for that.

## License

Apache License 2.0

## Project Owner

GitHub: Fatalerorr69


## Seznam skriptů
- `starcore\starcore-platform\agents\kernel\agent_kernel.py` – Skript agent_kernel.py
- `starcore\starcore-platform\agents\missions\mission_executor.py` – Skript mission_executor.py
- `starcore\starcore-platform\agents\planner\task_planner.py` – Skript task_planner.py
- `starcore\starcore-platform\ai_core\kernel\ai_kernel.py` – Skript ai_kernel.py
- `starcore\starcore-platform\ai_runtime\agents\agent_registry.py` – !/usr/bin/env python3
- `starcore\starcore-platform\ai_runtime\inference\inference_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\ai_runtime\models\model_registry.py` – !/usr/bin/env python3
- `starcore\starcore-platform\api_gateway\api_gateway.py` – !/usr/bin/env python3
- `starcore\starcore-platform\automation\git\starcore_git_health.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\automation\github\scripts\backup_sync.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\automation\github\scripts\doctor_fix.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\automation\github\scripts\full_backup.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\automation\github\scripts\live_monitor.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\automation\github\scripts\release_check.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\automation\github\scripts\repository_audit.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\automation\github\scripts\security_scan.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\automation\github\scripts\starcore_doctor.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\automation\github\github_health.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\automation\github\starcore_github_control.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\automation\modules\ai\ai_status.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\automation\modules\android\android_check.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\automation\modules\android\battery.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\automation\modules\android\device_report.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\automation\modules\android\network.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\automation\modules\android\packages.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\automation\modules\android\storage.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\automation\modules\system\system_info.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\automation\modules\module_loader.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\automation\stabilization\scripts\starcore_verify.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\autonomous\agents\orchestrator.py` – Skript orchestrator.py
- `starcore\starcore-platform\autonomous\connectors\ai_core_bridge.py` – Skript ai_core_bridge.py
- `starcore\starcore-platform\autonomous\connectors\ollama_connector.py` – Skript ollama_connector.py
- `starcore\starcore-platform\autonomous\connectors\proxmox_controller.py` – Skript proxmox_controller.py
- `starcore\starcore-platform\autonomous\connectors\rag_bridge.py` – Skript rag_bridge.py
- `starcore\starcore-platform\autonomous\health\health_loop.py` – Skript health_loop.py
- `starcore\starcore-platform\autonomous\mesh\node_mesh.py` – Skript node_mesh.py
- `starcore\starcore-platform\autonomous\runtime\runtime.py` – Skript runtime.py
- `starcore\starcore-platform\autonomous\scheduler\scheduler.py` – Skript scheduler.py
- `starcore\starcore-platform\bundles_7x\install_7_3_4_ai_infra_knowledge.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\bundles_7x\install_7_5_6_studio_devops.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\bundles_7x\install_7_7_8_marketplace_observability.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\bundles_7x\install_7_9_10_security_final.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\bundles_7x\run_7x_bulk_suite.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\control_center\bin\log.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\control_center\modules\git.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\control_center\modules\network.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\control_center\modules\runtime.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\control_center\modules\security.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\control_center\modules\storage.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\control_center\modules\system.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\core\cli\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\core\cli\command_bus.py` – !/usr/bin/env python3
- `starcore\starcore-platform\core\cli\router.py` – !/usr/bin/env python3
- `starcore\starcore-platform\core\config\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\core\database\android\init_android_db.py` – !/usr/bin/env python3
- `starcore\starcore-platform\core\database\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\core\database\security_db.py` – Skript security_db.py
- `starcore\starcore-platform\core\database\security_store.py` – Skript security_store.py
- `starcore\starcore-platform\core\installer\engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\core\installer\logger.py` – !/usr/bin/env python3
- `starcore\starcore-platform\core\installer\registry.py` – !/usr/bin/env python3
- `starcore\starcore-platform\core\installer\validator.py` – !/usr/bin/env python3
- `starcore\starcore-platform\core\lib\starcore.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\core\logging\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\core\modules\android\android_cmd.py` – Skript android_cmd.py
- `starcore\starcore-platform\core\modules\android\audit.py` – Skript audit.py
- `starcore\starcore-platform\core\modules\android\battery.py` – Skript battery.py
- `starcore\starcore-platform\core\modules\android\device.py` – Skript device.py
- `starcore\starcore-platform\core\modules\android\integrity_engine.py` – Skript integrity_engine.py
- `starcore\starcore-platform\core\modules\android\integrity_scanner.py` – Skript integrity_scanner.py
- `starcore\starcore-platform\core\modules\android\magisk.py` – Skript magisk.py
- `starcore\starcore-platform\core\modules\android\network.py` – Skript network.py
- `starcore\starcore-platform\core\modules\android\packages.py` – Skript packages.py
- `starcore\starcore-platform\core\modules\android\processes.py` – Skript processes.py
- `starcore\starcore-platform\core\modules\android\properties.py` – Skript properties.py
- `starcore\starcore-platform\core\modules\android\resources.py` – Skript resources.py
- `starcore\starcore-platform\core\modules\android\risk_engine.py` – Skript risk_engine.py
- `starcore\starcore-platform\core\modules\android\root.py` – Skript root.py
- `starcore\starcore-platform\core\modules\android\security_engine.py` – Skript security_engine.py
- `starcore\starcore-platform\core\modules\android\security_intel.py` – Skript security_intel.py
- `starcore\starcore-platform\core\modules\android\security_report.py` – Skript security_report.py
- `starcore\starcore-platform\core\modules\android\security.py` – Skript security.py
- `starcore\starcore-platform\core\modules\android\storage.py` – Skript storage.py
- `starcore\starcore-platform\core\modules\system\logger.py` – Skript logger.py
- `starcore\starcore-platform\core\plugins\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\core\runtime\events\event_bus.py` – !/usr/bin/env python3
- `starcore\starcore-platform\core\runtime\plugins\plugin_manager.py` – !/usr/bin/env python3
- `starcore\starcore-platform\core\runtime\plugins\plugin_status.py` – !/usr/bin/env python3
- `starcore\starcore-platform\core\runtime\plugins\test_plugin.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\core\runtime\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\core\runtime\runtime_api.py` – !/usr/bin/env python3
- `starcore\starcore-platform\core\runtime\version.py` – Skript version.py
- `starcore\starcore-platform\core\services\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\core\utils\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\core\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\distributed\agents\network.py` – Skript network.py
- `starcore\starcore-platform\distributed\auth\auth.py` – Skript auth.py
- `starcore\starcore-platform\distributed\bus\bus.py` – Skript bus.py
- `starcore\starcore-platform\distributed\events\events.py` – Skript events.py
- `starcore\starcore-platform\distributed\execution\execution.py` – Skript execution.py
- `starcore\starcore-platform\distributed\memory\memory_sync.py` – Skript memory_sync.py
- `starcore\starcore-platform\distributed\recovery\recovery.py` – Skript recovery.py
- `starcore\starcore-platform\distributed\vector\vector_sync.py` – Skript vector_sync.py
- `starcore\starcore-platform\distributed\workflows\federation.py` – Skript federation.py
- `starcore\starcore-platform\github_intelligence\github_scanner.py` – !/usr/bin/env python3
- `starcore\starcore-platform\hardening\dependencies\dependency_manager.py` – !/usr/bin/env python3
- `starcore\starcore-platform\hardening\environment\environment_audit.py` – !/usr/bin/env python3
- `starcore\starcore-platform\installers\android\history\6BX\install_6BX11_control_plane.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\installers\android\history\6BX\install_6BX12_scheduler.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\installers\android\history\6BX\install_6BX13_control_fabric.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\installers\android\history\6BX\install_6BX14_remote_access.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\installers\android\history\6BX\install_6BX15_agent_mesh.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\installers\android\history\6BX\install_6BX16_ai_memory_fabric.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\installers\android\history\6BX\install_6BX17_self_repair.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\installers\android\install_6BX7.sh` – Skript install_6BX7.sh
- `starcore\starcore-platform\installers\android\starcore_installer.py` – !/usr/bin/env python3
- `starcore\starcore-platform\knowledge\core\knowledge_core.py` – Skript knowledge_core.py
- `starcore\starcore-platform\knowledge\rag\rag_engine.py` – Skript rag_engine.py
- `starcore\starcore-platform\knowledge_engine\knowledge_core.py` – !/usr/bin/env python3
- `starcore\starcore-platform\mission_engine\execution\execution_tracker.py` – !/usr/bin/env python3
- `starcore\starcore-platform\mission_engine\missions\mission_registry.py` – !/usr/bin/env python3
- `starcore\starcore-platform\mission_engine\workflows\workflow_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\performance\performance_analyzer.py` – !/usr/bin/env python3
- `starcore\starcore-platform\platform\.starcore\scripts\tests\__init__.py` – STARCORE scripts test package
- `starcore\starcore-platform\platform\.starcore\scripts\tests\test_decision_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\platform\.starcore\scripts\tests\test_qc_engines.py` – !/usr/bin/env python3
- `starcore\starcore-platform\platform\.starcore\scripts\tests\test_repository_map.py` – !/usr/bin/env python3
- `starcore\starcore-platform\platform\.starcore\scripts\tests\test_startup_protocol.py` – !/usr/bin/env python3
- `starcore\starcore-platform\platform\.starcore\scripts\__init__.py` – STARCORE .starcore/scripts — automation utilities for registry and session ledger
- `starcore\starcore-platform\platform\.starcore\scripts\decision_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\platform\.starcore\scripts\impact_analyzer.py` – !/usr/bin/env python3
- `starcore\starcore-platform\platform\.starcore\scripts\ledger.py` – !/usr/bin/env python3
- `starcore\starcore-platform\platform\.starcore\scripts\models.py` – Skript models.py
- `starcore\starcore-platform\platform\.starcore\scripts\qc_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\platform\.starcore\scripts\registry.py` – !/usr/bin/env python3
- `starcore\starcore-platform\platform\.starcore\scripts\regression_sentinel.py` – !/usr/bin/env python3
- `starcore\starcore-platform\platform\.starcore\scripts\release_readiness.py` – !/usr/bin/env python3
- `starcore\starcore-platform\platform\.starcore\scripts\repository_map.py` – !/usr/bin/env python3
- `starcore\starcore-platform\platform\.starcore\scripts\startup_protocol.py` – !/usr/bin/env python3
- `starcore\starcore-platform\platform\apps\cli\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\platform\apps\cli\main.py` – Skript main.py
- `starcore\starcore-platform\platform\apps\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\platform\migrations\versions\0001_initial_schema.py` – Skript 0001_initial_schema.py
- `starcore\starcore-platform\platform\migrations\versions\0002_add_users.py` – Skript 0002_add_users.py
- `starcore\starcore-platform\platform\migrations\env.py` – Skript env.py
- `starcore\starcore-platform\platform\packages\ai\providers\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\platform\packages\ai\providers\anthropic.py` – Skript anthropic.py
- `starcore\starcore-platform\platform\packages\ai\providers\openai_compat.py` – Skript openai_compat.py
- `starcore\starcore-platform\platform\packages\ai\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\platform\packages\ai\base.py` – Skript base.py
- `starcore\starcore-platform\platform\packages\ai\generator.py` – Skript generator.py
- `starcore\starcore-platform\platform\packages\ai\prompts.py` – Skript prompts.py
- `starcore\starcore-platform\platform\packages\blueprints\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\platform\packages\blueprints\executor.py` – Skript executor.py
- `starcore\starcore-platform\platform\packages\blueprints\loader.py` – Skript loader.py
- `starcore\starcore-platform\platform\packages\blueprints\models.py` – Skript models.py
- `starcore\starcore-platform\platform\packages\blueprints\planner.py` – Skript planner.py
- `starcore\starcore-platform\platform\packages\blueprints\template_resolver.py` – Skript template_resolver.py
- `starcore\starcore-platform\platform\packages\core\routers\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\platform\packages\core\routers\ai.py` – Skript ai.py
- `starcore\starcore-platform\platform\packages\core\routers\auth.py` – Skript auth.py
- `starcore\starcore-platform\platform\packages\core\routers\blueprints.py` – Skript blueprints.py
- `starcore\starcore-platform\platform\packages\core\routers\diagnostics.py` – Skript diagnostics.py
- `starcore\starcore-platform\platform\packages\core\routers\providers.py` – Skript providers.py
- `starcore\starcore-platform\platform\packages\core\routers\runs.py` – Skript runs.py
- `starcore\starcore-platform\platform\packages\core\routers\ws.py` – Skript ws.py
- `starcore\starcore-platform\platform\packages\core\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\platform\packages\core\auth.py` – Skript auth.py
- `starcore\starcore-platform\platform\packages\core\config.py` – Skript config.py
- `starcore\starcore-platform\platform\packages\core\correlation.py` – Skript correlation.py
- `starcore\starcore-platform\platform\packages\core\database.py` – Skript database.py
- `starcore\starcore-platform\platform\packages\core\diagnostics.py` – Skript diagnostics.py
- `starcore\starcore-platform\platform\packages\core\discovery.py` – Skript discovery.py
- `starcore\starcore-platform\platform\packages\core\environment.py` – Skript environment.py
- `starcore\starcore-platform\platform\packages\core\events.py` – Skript events.py
- `starcore\starcore-platform\platform\packages\core\logger.py` – Skript logger.py
- `starcore\starcore-platform\platform\packages\core\main.py` – Skript main.py
- `starcore\starcore-platform\platform\packages\core\metrics.py` – Skript metrics.py
- `starcore\starcore-platform\platform\packages\core\models_api.py` – Skript models_api.py
- `starcore\starcore-platform\platform\packages\core\models_db.py` – Skript models_db.py
- `starcore\starcore-platform\platform\packages\core\plugin_manager.py` – Skript plugin_manager.py
- `starcore\starcore-platform\platform\packages\core\repository.py` – Skript repository.py
- `starcore\starcore-platform\platform\packages\core\request_id_middleware.py` – Skript request_id_middleware.py
- `starcore\starcore-platform\platform\packages\core\resource_actions.py` – Skript resource_actions.py
- `starcore\starcore-platform\platform\packages\core\security.py` – Skript security.py
- `starcore\starcore-platform\platform\packages\core\tracing.py` – Skript tracing.py
- `starcore\starcore-platform\platform\packages\orchestrator\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\platform\packages\orchestrator\scheduler.py` – Skript scheduler.py
- `starcore\starcore-platform\platform\packages\orchestrator\task_graph.py` – Skript task_graph.py
- `starcore\starcore-platform\platform\packages\orchestrator\task.py` – Skript task.py
- `starcore\starcore-platform\platform\packages\orchestrator\timeout.py` – Skript timeout.py
- `starcore\starcore-platform\platform\packages\provider_sdk\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\platform\packages\provider_sdk\base.py` – Skript base.py
- `starcore\starcore-platform\platform\packages\provider_sdk\exceptions.py` – Skript exceptions.py
- `starcore\starcore-platform\platform\packages\provider_sdk\registry.py` – Skript registry.py
- `starcore\starcore-platform\platform\packages\provider_sdk\retry.py` – Skript retry.py
- `starcore\starcore-platform\platform\packages\providers\docker\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\platform\packages\providers\docker\provider.py` – Skript provider.py
- `starcore\starcore-platform\platform\packages\providers\kubernetes\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\platform\packages\providers\kubernetes\provider.py` – Skript provider.py
- `starcore\starcore-platform\platform\packages\providers\proxmox\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\platform\packages\providers\proxmox\provider.py` – Skript provider.py
- `starcore\starcore-platform\platform\packages\providers\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\platform\plugins\example_provider\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\platform\plugins\run_logger\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\platform\plugins\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\platform\scripts\doctor.py` – !/usr/bin/env python3
- `starcore\starcore-platform\platform\scripts\health.py` – !/usr/bin/env python3
- `starcore\starcore-platform\platform\scripts\make-executable.sh` – !/bin/bash
- `starcore\starcore-platform\platform\scripts\quickstart.sh` – !/bin/bash
- `starcore\starcore-platform\platform\scripts\release.py` – !/usr/bin/env python3
- `starcore\starcore-platform\platform\scripts\setup-copilot.sh` – !/bin/bash
- `starcore\starcore-platform\platform\scripts\verify-integration.sh` – !/bin/bash
- `starcore\starcore-platform\platform\tests\postgres\__init__.py` – Skript __init__.py
- `starcore\starcore-platform\platform\tests\postgres\conftest.py` – Skript conftest.py
- `starcore\starcore-platform\platform\tests\postgres\test_smoke.py` – Skript test_smoke.py
- `starcore\starcore-platform\platform\tests\conftest.py` – Skript conftest.py
- `starcore\starcore-platform\platform\tests\test_ai_generator.py` – Skript test_ai_generator.py
- `starcore\starcore-platform\platform\tests\test_ai_providers.py` – Skript test_ai_providers.py
- `starcore\starcore-platform\platform\tests\test_api.py` – Skript test_api.py
- `starcore\starcore-platform\platform\tests\test_auth.py` – Skript test_auth.py
- `starcore\starcore-platform\platform\tests\test_blueprint_parametrization.py` – Skript test_blueprint_parametrization.py
- `starcore\starcore-platform\platform\tests\test_blueprints.py` – Skript test_blueprints.py
- `starcore\starcore-platform\platform\tests\test_cli.py` – Skript test_cli.py
- `starcore\starcore-platform\platform\tests\test_correlation.py` – Skript test_correlation.py
- `starcore\starcore-platform\platform\tests\test_diagnostics.py` – Skript test_diagnostics.py
- `starcore\starcore-platform\platform\tests\test_discovery.py` – Skript test_discovery.py
- `starcore\starcore-platform\platform\tests\test_e2e_integration.py` – Skript test_e2e_integration.py
- `starcore\starcore-platform\platform\tests\test_environment.py` – Skript test_environment.py
- `starcore\starcore-platform\platform\tests\test_events.py` – Skript test_events.py
- `starcore\starcore-platform\platform\tests\test_exceptions.py` – Skript test_exceptions.py
- `starcore\starcore-platform\platform\tests\test_graph_execution.py` – Skript test_graph_execution.py
- `starcore\starcore-platform\platform\tests\test_health.py` – Skript test_health.py
- `starcore\starcore-platform\platform\tests\test_jwt_auth.py` – Skript test_jwt_auth.py
- `starcore\starcore-platform\platform\tests\test_kubernetes_provider.py` – Skript test_kubernetes_provider.py
- `starcore\starcore-platform\platform\tests\test_logger.py` – Skript test_logger.py
- `starcore\starcore-platform\platform\tests\test_metrics.py` – Skript test_metrics.py
- `starcore\starcore-platform\platform\tests\test_migrations.py` – Skript test_migrations.py
- `starcore\starcore-platform\platform\tests\test_persistence.py` – Skript test_persistence.py
- `starcore\starcore-platform\platform\tests\test_plugin_manager.py` – Skript test_plugin_manager.py
- `starcore\starcore-platform\platform\tests\test_property_based_ai.py` – Skript test_property_based_ai.py
- `starcore\starcore-platform\platform\tests\test_property_based_blueprints.py` – Skript test_property_based_blueprints.py
- `starcore\starcore-platform\platform\tests\test_property_based_cli.py` – Skript test_property_based_cli.py
- `starcore\starcore-platform\platform\tests\test_property_based_core.py` – Skript test_property_based_core.py
- `starcore\starcore-platform\platform\tests\test_property_based_dependency_semantics.py` – Skript test_property_based_dependency_semantics.py
- `starcore\starcore-platform\platform\tests\test_property_based_environment.py` – Skript test_property_based_environment.py
- `starcore\starcore-platform\platform\tests\test_property_based_metrics.py` – Skript test_property_based_metrics.py
- `starcore\starcore-platform\platform\tests\test_property_based_providers.py` – Skript test_property_based_providers.py
- `starcore\starcore-platform\platform\tests\test_property_based_retry.py` – Skript test_property_based_retry.py
- `starcore\starcore-platform\platform\tests\test_property_based_security.py` – Skript test_property_based_security.py
- `starcore\starcore-platform\platform\tests\test_property_based_timeout.py` – Skript test_property_based_timeout.py
- `starcore\starcore-platform\platform\tests\test_property_based.py` – Skript test_property_based.py
- `starcore\starcore-platform\platform\tests\test_providers.py` – Skript test_providers.py
- `starcore\starcore-platform\platform\tests\test_rate_limiting.py` – Skript test_rate_limiting.py
- `starcore\starcore-platform\platform\tests\test_request_id_middleware.py` – Skript test_request_id_middleware.py
- `starcore\starcore-platform\platform\tests\test_request_id.py` – Skript test_request_id.py
- `starcore\starcore-platform\platform\tests\test_resource_actions.py` – Skript test_resource_actions.py
- `starcore\starcore-platform\platform\tests\test_retry.py` – Skript test_retry.py
- `starcore\starcore-platform\platform\tests\test_security.py` – Skript test_security.py
- `starcore\starcore-platform\platform\tests\test_settings_isolation.py` – Skript test_settings_isolation.py
- `starcore\starcore-platform\platform\tests\test_scheduler.py` – Skript test_scheduler.py
- `starcore\starcore-platform\platform\tests\test_schema_management.py` – Skript test_schema_management.py
- `starcore\starcore-platform\platform\tests\test_sse.py` – Skript test_sse.py
- `starcore\starcore-platform\platform\tests\test_template_resolver.py` – Skript test_template_resolver.py
- `starcore\starcore-platform\platform\tests\test_timeout.py` – Skript test_timeout.py
- `starcore\starcore-platform\platform\tests\test_tracing.py` – Skript test_tracing.py
- `starcore\starcore-platform\platform\tests\test_ws_blueprint.py` – Skript test_ws_blueprint.py
- `starcore\starcore-platform\plugins\enabled\android\agent\android_agent_v2.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\agent\android_agent.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\agent_supervisor\supervisor.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\agents\registry.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\ai\device_analyzer.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\ai_bridge\ai_bridge.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\ai_bridge\ai_handshake.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\ai_core\agent\autonomous_loop.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\ai_core\bridge\fatalab_bridge.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\ai_core\decision\decision_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\ai_core\memory\memory_layer.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\ai_core\policy\policy_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\ai_core\recommendation\recommendation_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\api\gateway.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\api_gateway\api_gateway.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\audit\integrity_audit.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\automation\automation.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\autonomous\bridge\fatalab_connector.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\autonomous\events\event_intelligence.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\autonomous\memory\memory_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\autonomous\orchestrator\orchestrator.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\autonomous\scheduler\task_scheduler.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\autonomous\workers\worker_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\autonomous\health_check.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\autonomous_core\bootstrap\bootstrap.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\autonomous_core\decision_loop\decision_loop.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\autonomous_core\event_intelligence\event_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\autonomous_core\mission_manager\mission_manager.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\autonomous_core\optimizer\optimizer.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\autonomous_core\recovery\recovery.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\autonomous_core\state_controller\controller.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\autonomous_core\supervisor\supervisor.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\autonomous_core\sync\sync_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\autonomous_core\validator\master_validator.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\backup\backup_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\backup\snapshot_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\bin\health.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\plugins\enabled\android\bin\security_collect.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\plugins\enabled\android\bin\security.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\plugins\enabled\android\bin\snapshot.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\plugins\enabled\android\bin\telemetry.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\plugins\enabled\android\bootstrap\bootstrap_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\bridge\ai_bridge_v2.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\bridge\memory_bridge.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\cognitive\bridge\fatalab_bridge.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\cognitive\context\context_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\cognitive\health\cognitive_health.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\cognitive\memory\memory_graph.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\cognitive\router\ai_router.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\cognitive\vector\vector_interface.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\cognitive_v2\context\context_manager.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\cognitive_v2\decision\decision_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\cognitive_v2\inference\inference_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\cognitive_v2\learning\learning_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\cognitive_v2\planning\planning_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\cognitive_v2\reasoning\reasoning_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\cognitive_v2\reflection\reflection_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\cognitive_v2\supervisor\cognitive_supervisor.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\command_bus\command_bus.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\command_center\controller.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\compute_fabric\bootstrap\bootstrap.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\compute_fabric\containers\container_bridge.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\compute_fabric\cpu\cpu_monitor.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\compute_fabric\gpu\gpu_bridge.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\compute_fabric\memory\memory_optimizer.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\compute_fabric\performance\performance_supervisor.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\compute_fabric\remote\remote_compute.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\compute_fabric\resources\resource_manager.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\compute_fabric\scheduler\workload_scheduler.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\compute_fabric\validator\validator.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\config\config_manager.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\context\context_store.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\control\core_controller.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\control\state_manager.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\control_fabric\fabric_controller.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\control_plane\modules\health.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\control_plane\modules\status.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\control_plane\router.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\controller\android_core_controller.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\core\config_validator.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\core\health_check.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\core\integrity_check.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\core\master_report.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\core\module_registry.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\core\runtime_manager.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\dashboard\dashboard_state.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\dashboard\dashboard.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\deployment\deployment_manager.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\diagnostics\diagnostics.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\distributed\distributed_validator.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\distributed\node_discovery.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\distributed\node_registry.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\event_bus\event_bus_v2.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\events\event_bus.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\fatalab\connector.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\fatalab\health_sync.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\fatalab\tailscale_connector.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\fatalab_bridge\bridge.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\health\health_daemon.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\integrity\scanner.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\job_queue\job_manager.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\knowledge\graph.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\knowledge\knowledge_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\lifecycle\lifecycle_manager.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\lifecycle\lifecycle.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\log_intelligence\log_ai.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\master\master.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\master\release.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\master\validator.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\memory\health.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\memory\memory_registry.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\memory_fabric\backup\backup.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\memory_fabric\bootstrap\bootstrap.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\memory_fabric\embedding\embedding.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\memory_fabric\knowledge\knowledge_graph.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\memory_fabric\long_term\long_memory.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\memory_fabric\optimizer\optimizer.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\memory_fabric\short_term\short_memory.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\memory_fabric\sync\memory_sync.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\memory_fabric\validator\validator.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\memory_fabric\vector\vector_memory.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\memory_sync\memory_sync.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\mesh\health.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\mesh\heartbeat.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\metrics\metrics.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\monitor\event_monitor.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\monitoring\global_health.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\monitoring\metrics.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\network\network_intelligence_v2.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\network\network_intelligence.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\operations\audit_engine\audit.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\operations\command_center\command_center.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\operations\execution_engine\executor.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\operations\policy_manager\policy.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\operations\validator\validator.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\optimization\optimizer.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\orchestrator\orchestrator.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\plugin_manager\plugin_manager.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\policy\policy.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\recovery\recovery_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\recovery_v2\recovery.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\recovery_v3\recovery.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\release\release_validator.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\release_core\release.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\remote\access_health.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\remote\node_identity.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\remote\remote_manager.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\remote\remote_profile.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\remote\tailscale_check.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\remote_agents\supervisor.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\remote_api\api_gateway.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\repair\engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\repair\health.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\repair\snapshot.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\router\router.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\runtime\runtime_manager.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\security\baseline.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\security\security_guard.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\security\security_intelligence.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\security\security_scan.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\security_center\security.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\security_intelligence\audit\audit_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\security_intelligence\bootstrap\bootstrap.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\security_intelligence\identity\identity_manager.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\security_intelligence\incidents\incident_response.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\security_intelligence\integrity\integrity_monitor.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\security_intelligence\permissions\permission_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\security_intelligence\policies\policy_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\security_intelligence\supervisor\security_supervisor.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\security_intelligence\threats\threat_detector.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\security_monitor\security_monitor.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\selftest\selftest.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\scheduler\executor.py` – !/data/data/com.termux/files/usr/bin/python3
- `starcore\starcore-platform\plugins\enabled\android\scheduler\health.py` – !/data/data/com.termux/files/usr/bin/python3
- `starcore\starcore-platform\plugins\enabled\android\scheduler\scheduler_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\scheduler\scheduler.py` – !/data/data/com.termux/files/usr/bin/python3
- `starcore\starcore-platform\plugins\enabled\android\snapshot\snapshot_manager.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\ssh\ssh_manager.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\state_db\state_manager.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\sync\sync_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\tailscale\tailscale.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\tasks\task_manager.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\telemetry\master_health.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\telemetry\telemetry.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\termux\termux_intelligence.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\unified\installer_core.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\update\backup.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\update\rollback.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\update\updater.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\validator\global_validator.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\vector\vector_state.py` – !/usr/bin/env python3
- `starcore\starcore-platform\plugins\enabled\android\workers\worker.py` – !/usr/bin/env python3
- `starcore\starcore-platform\sdk\core\api.py` – !/usr/bin/env python3
- `starcore\starcore-platform\sdk\core\lifecycle.py` – !/usr/bin/env python3
- `starcore\starcore-platform\sdk\core\manifest.py` – !/usr/bin/env python3
- `starcore\starcore-platform\sdk\core\module.py` – !/usr/bin/env python3
- `starcore\starcore-platform\security\backup_engine.py` – !/usr/bin/env python3
- `starcore\starcore-platform\security\github_intelligence_upgrade.py` – !/usr/bin/env python3
- `starcore\starcore-platform\security\security_audit.py` – !/usr/bin/env python3
- `starcore\starcore-platform\studio\dashboard\dashboard.py` – !/usr/bin/env python3
- `starcore\starcore-platform\tools\access\file_inventory.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\tools\context\context_show.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\tools\control_center\claude_manager.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\tools\control_center\health_monitor.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\tools\control_center\starcore_control.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\tools\control_center\tmux_manager.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\tools\engineering\analyze.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\tools\engineering\git_intel.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\tools\engineering\prompt.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\tools\engineering\remote.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\tools\intelligence\git_intelligence.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\tools\intelligence\project_health.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\tools\intelligence\repo_scan.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\tools\remote_bridge\ai_health.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\tools\remote_bridge\bridge_health.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\tools\remote_bridge\full_health.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\tools\remote_bridge\proxmox_health.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\tools\remote_bridge\ssh_health.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\generate_7x_bulk_packages.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_6BX18_master_consolidator.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_6BX19_21_foundation.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_6BX22_25_master_part1.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_6BX26_30_master_part2.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_6BX31_35_master.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_6BX31_40_master_part1.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_6BX35_40_master_part2.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_6BY1_5_fatalab_bridge_part1.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_6BYY100_TERMUX_HARDENING.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_6BYY11_20_distributed_intelligence.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_6BYY21_30_remote_intelligence.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_6BYY31_40_operations_layer.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_6BYY41_50_agent_framework.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_6BYY51_60_cognitive_intelligence.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_6BYY6_10_distributed_ai_part2.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_6BYY61_70_memory_fabric.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_6BYY71_80_security_intelligence.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_6BYY81_90_compute_fabric.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_6BYY91_100_autonomous_master_part1.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_6BYY96_100_autonomous_master_part2.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_7_0_01_installer_framework.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_7_0_02_cli_command_bus.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_7_0_03_sdk_core.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_7_0_04_10_master_platform.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_7_0_05_07_services_part2.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_7_0_08_10_master_final.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_7_0_11_20_hardening_master.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_7_0_14_16_security_backup.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_7_0_17_20_final_production.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_7_1_01_10_autonomous_core_MASTER.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_7_2_01_10_distributed_intelligence_MASTER.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_8_FINAL_GLOBAL_AUDIT.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_8_GOLD_MASTER_BACKUP.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_8_RELEASE_SNAPSHOT.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_8A_ai_core_foundation_MASTER.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_8B_autonomous_agent_fabric_MASTER.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_8C_knowledge_rag_fabric_MASTER.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_8D_distributed_compute_fabric_MASTER.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_8E_security_self_healing_MASTER.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_8F_observability_control_plane_MASTER.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_8G_marketplace_plugin_ecosystem_MASTER.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_8H_automation_workflow_fabric_MASTER.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_8I_ai_optimization_learning_MASTER.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_8J_final_autonomous_operating_layer_MASTER.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_CLAUDE_RUNTIME_REPAIR_v1.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_STARCORE_AI_CONTEXT_ENGINE_v1.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_STARCORE_AUTONOMOUS_ENGINEERING_v3_1_REPAIR.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_STARCORE_AUTONOMOUS_ENGINEERING_v3.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_STARCORE_CONTROL_NODE_v2.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_STARCORE_ENGINEERING_FINAL_v1.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_STARCORE_INTELLIGENCE_LAYER_v1.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_STARCORE_UNIVERSAL_ACCESS_LAYER_v1.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_TERMUX_AI_TOOLKIT.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_TERMUX_CONTROL_CENTER_v1.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_TERMUX_CONTROL_CENTER.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_TERMUX_DEEP_AUDIT.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_TERMUX_DEV_VALIDATOR.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_TERMUX_FINAL_VALIDATION.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_TERMUX_OPTIMIZER.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_TERMUX_PACKAGE_HEALTH.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_TERMUX_REMOTE_AI_BRIDGE_1.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_TERMUX_REMOTE_AI_BRIDGE_2.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_TERMUX_REMOTE_AI_BRIDGE_3.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_TERMUX_REMOTE_AI_BRIDGE_4.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\install_TERMUX_REMOTE_AI_BRIDGE_5.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\preflight_STARCORE_8_MIGRATION_AUDIT.sh` – !/data/data/com.termux/files/usr/bin/bash
- `starcore\starcore-platform\repair_ENGINEERING_LAYER.sh` – !/data/data/com.termux/files/usr/bin/bash


## Hodnocení a doporučení
<!-- Doplňte na základě výše uvedených informací -->
- 
