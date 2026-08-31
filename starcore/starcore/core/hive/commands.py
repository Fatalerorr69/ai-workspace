import typer
import json
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from .engine import hive
from .orchestrator import orchestrator

console = Console()

def start():
    hive.start()
    console.print("[green]✅ HIVE Engine + Scheduler + Orchestrator spuštěny[/green]")

def stop():
    orchestrator.stop()
    hive.stop()
    console.print("[yellow]✅ HIVE Engine + Orchestrator zastaveny[/yellow]")

def status():
    status = hive.status()
    orch_status = orchestrator.status()
    table = Table(title="HIVE Status", show_header=True)
    table.add_column("Komponenta", style="cyan")
    table.add_column("Stav", style="yellow")
    table.add_row("Engine", "🟢 Running" if status["running"] else "🔴 Stopped")
    table.add_row("PID", str(status.get("pid", "N/A")))
    table.add_row("Scheduler", "🟢 Running" if status["scheduler"]["running"] else "🔴 Stopped")
    table.add_row("Orchestrator", "🟢 Running" if orch_status["running"] else "🔴 Stopped")
    table.add_row("Tasks", str(len(orch_status["tasks"])))
    table.add_row("Agents", str(status["agents"]["total"]))
    console.print(table)

def schedule():
    # Použijeme scheduler z hive
    status = hive.scheduler.status()
    if status["jobs"]:
        console.print(Panel("\n".join(status["jobs"]), title="Naplánované úlohy", border_style="blue"))
    else:
        console.print("❌ Žádné naplánované úlohy")

def agent_add(name: str, config: str):
    try:
        config_dict = json.loads(config)
        hive.agents.add(name, config_dict)
        console.print(f"[green]✅ Agent {name} přidán[/green]")
    except json.JSONDecodeError:
        console.print("[red]❌ Neplatný JSON config[/red]")

def agent_list():
    agents = hive.agents.list()
    if agents:
        table = Table(title="Agenti", show_header=True)
        table.add_column("Jméno", style="cyan")
        table.add_column("Config", style="white")
        for name, config in agents.items():
            table.add_row(name, json.dumps(config, ensure_ascii=False))
        console.print(table)
    else:
        console.print("❌ Žádní agenti")

def task_list():
    tasks = orchestrator.tasks
    if tasks:
        table = Table(title="Orchestrator Tasks", show_header=True)
        table.add_column("Název", style="cyan")
        table.add_column("Interval", style="yellow")
        table.add_column("Stav", style="green")
        for name, data in tasks.items():
            table.add_row(name, f"{data['interval']}s", data['status'])
        console.print(table)
    else:
        console.print("❌ Žádné úlohy")
