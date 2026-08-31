import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

import typer
from rich.console import Console
from .commands import version, info, doctor, verify
from core.services.commands import start, stop, status, logs, restart
from core.hive.commands import start as hive_start, stop as hive_stop, status as hive_status, schedule, agent_add, agent_list, task_list
from ai.commands import start as ai_start, stop as ai_stop, status as ai_status, config as ai_config, query as ai_query, test as ai_test
from core.check.commands import check
from core.monitor.commands import monitor

app = typer.Typer(help="STARCORE Mobile Core CLI")
console = Console()

# Core commands
app.command()(version.version)
app.command()(info.info)
app.command()(doctor.doctor)
app.command()(verify.verify)
app.command()(check)
app.command()(monitor)

# Service commands
app.command(name="start")(start)
app.command(name="stop")(stop)
app.command(name="status")(status)
app.command(name="logs")(logs)
app.command(name="restart")(restart)

# HIVE commands
app.command(name="hive-start")(hive_start)
app.command(name="hive-stop")(hive_stop)
app.command(name="hive-status")(hive_status)
app.command(name="hive-schedule")(schedule)
app.command(name="hive-agent-add")(agent_add)
app.command(name="hive-agent-list")(agent_list)
app.command(name="hive-task-list")(task_list)

# AI commands
app.command(name="ai-start")(ai_start)
app.command(name="ai-stop")(ai_stop)
app.command(name="ai-status")(ai_status)
app.command(name="ai-config")(ai_config)
app.command(name="ai-query")(ai_query)
app.command(name="ai-test")(ai_test)

# ====== ROZŠÍŘENÍ ======

# Vision
try:
    from extensions.vision import recognize_text
    app.command(name="vision-ocr")(recognize_text)
except ImportError:
    pass

# Network
try:
    from extensions.network import ping, speedtest
    app.command(name="ping")(ping)
    app.command(name="speedtest")(speedtest)
except ImportError:
    pass

# Sync
try:
    from extensions.sync import sync, push, pull, watch
    app.command(name="sync")(sync)
    app.command(name="sync-push")(push)
    app.command(name="sync-pull")(pull)
    app.command(name="sync-watch")(watch)
except ImportError:
    pass

# Backup
try:
    from extensions.backup import backup
    app.command(name="backup")(backup)
except ImportError:
    pass

# SSH
try:
    from extensions.ssh import add, list_connections, connect, exec_cmd, keygen, copy_id
    app.command(name="ssh-add")(add)
    app.command(name="ssh-list")(list_connections)
    app.command(name="ssh-connect")(connect)
    app.command(name="ssh-exec")(exec_cmd)
    app.command(name="ssh-keygen")(keygen)
    app.command(name="ssh-copy-id")(copy_id)
except ImportError:
    pass

# Proxmox
try:
    from extensions.proxmox import config, list_vms, start, stop, restart, snapshot
    app.command(name="proxmox-config")(config)
    app.command(name="proxmox-list")(list_vms)
    app.command(name="proxmox-start")(start)
    app.command(name="proxmox-stop")(stop)
    app.command(name="proxmox-restart")(restart)
    app.command(name="proxmox-snapshot")(snapshot)
except ImportError:
    pass

if __name__ == "__main__":
    app()

# ====== MOBILE (FÁZE H) ======
try:
    from mobile.commands import battery, notify, sensors, wifi, voice, listen
    app.command(name="battery")(battery)
    app.command(name="notify")(notify)
    app.command(name="sensors")(sensors)
    app.command(name="wifi")(wifi)
    app.command(name="voice")(voice)
    app.command(name="listen")(listen)
except ImportError:
    pass
