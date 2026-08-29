import typer
import sys
import os
import subprocess
import json
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich import box
from core.config import settings
from core.services.manager import manager as service_manager
from core.hive.engine import hive
from core.hive.orchestrator import orchestrator
from ai import runtime as ai_runtime

console = Console()

def check():
    """Komplexní ověření celého systému STARCORE."""
    
    console.print(Panel("🔍 STARCORE System Check", style="bold green", border_style="green"))
    results = []
    all_ok = True
    
    # 1. Základní systém
    console.print("\n[bold cyan]1. Základní systém[/bold cyan]")
    # Python
    py_ok = sys.version_info >= (3, 9)
    results.append(("Python", sys.version.split()[0], "✓" if py_ok else "✗"))
    # Git
    git_ok = subprocess.run(["git", "--version"], capture_output=True).returncode == 0
    results.append(("Git", "nalezen" if git_ok else "nenalezen", "✓" if git_ok else "✗"))
    # tmux
    tmux_ok = subprocess.run(["tmux", "-V"], capture_output=True).returncode == 0
    results.append(("tmux", "nalezen" if tmux_ok else "nenalezen", "✓" if tmux_ok else "✗"))
    
    # 2. STARCORE CLI
    console.print("[bold cyan]2. STARCORE CLI[/bold cyan]")
    try:
        from core import __version__
        version_ok = True
    except:
        version_ok = False
    results.append(("STARCORE verze", __version__ if version_ok else "N/A", "✓" if version_ok else "✗"))
    
    # 3. Služby
    console.print("[bold cyan]3. Service Manager[/bold cyan]")
    services = service_manager.list_all()
    results.append(("Registrované služby", str(len(services)), "✓" if services else "⚠"))
    running = sum(1 for s in services if service_manager.status(s)[s]["status"] == "running")
    results.append(("Běžící služby", str(running), "✓" if running > 0 else "⚠"))
    
    # 4. HIVE
    console.print("[bold cyan]4. HIVE Engine[/bold cyan]")
    hive_status = hive.status()
    orch_status = orchestrator.status()
    results.append(("HIVE Engine", "běží" if hive_status["running"] else "zastaven", "✓" if hive_status["running"] else "⚠"))
    results.append(("HIVE Scheduler", "běží" if hive_status["scheduler"]["running"] else "zastaven", "✓" if hive_status["scheduler"]["running"] else "⚠"))
    results.append(("Orchestrator", "běží" if orch_status["running"] else "zastaven", "✓" if orch_status["running"] else "⚠"))
    results.append(("Agenti", str(hive_status["agents"]["total"]), "✓" if hive_status["agents"]["total"] > 0 else "⚠"))
    
    # 5. AI Runtime
    console.print("[bold cyan]5. AI Runtime[/bold cyan]")
    ai_status = ai_runtime.status()
    results.append(("AI Runtime", "běží" if ai_status["running"] else "zastaven", "✓" if ai_status["running"] else "⚠"))
    results.append(("Provider", ai_status["provider"], "✓"))
    results.append(("Model", ai_status["model"], "✓"))
    
    # 6. Dashboard
    console.print("[bold cyan]6. Dashboard[/bold cyan]")
    try:
        import httpx
        resp = httpx.get("http://localhost:8000/health", timeout=2)
        dash_ok = resp.status_code == 200
    except:
        dash_ok = False
    results.append(("Dashboard", "běží" if dash_ok else "nedostupný", "✓" if dash_ok else "⚠"))
    
    # 7. Systémové zdroje
    console.print("[bold cyan]7. Systémové zdroje[/bold cyan]")
    # RAM
    try:
        with open("/proc/meminfo", "r") as f:
            mem = f.read()
        for line in mem.splitlines():
            if line.startswith("MemTotal:"):
                total_ram = int(line.split()[1]) // 1024
                break
        ram_info = f"{total_ram} MB"
        ram_ok = total_ram > 512
    except:
        ram_info = "N/A"
        ram_ok = False
    results.append(("RAM", ram_info, "✓" if ram_ok else "✗"))
    # Volné místo
    try:
        import shutil
        free = shutil.disk_usage(os.path.expanduser("~")).free // (1024**2)
        free_info = f"{free} MB"
        free_ok = free > 100
    except:
        free_info = "N/A"
        free_ok = False
    results.append(("Volné místo", free_info, "✓" if free_ok else "⚠"))
    
    # 8. Síť
    console.print("[bold cyan]8. Síť[/bold cyan]")
    try:
        import socket
        socket.create_connection(("1.1.1.1", 80), timeout=3)
        net_ok = True
    except:
        net_ok = False
    results.append(("Internet", "dostupný" if net_ok else "nedostupný", "✓" if net_ok else "✗"))
    
    # Výpis tabulky
    console.print("\n[bold cyan]9. Shrnutí[/bold cyan]")
    table = Table(title="STARCORE System Check", box=box.ROUNDED, show_header=True)
    table.add_column("Kontrola", style="cyan")
    table.add_column("Stav", style="yellow")
    table.add_column("Výsledek", style="green")
    
    for name, value, status in results:
        color = "green" if "✓" in status else "red" if "✗" in status else "yellow"
        table.add_row(name, value, f"[{color}]{status}[/{color}]")
        if "✗" in status:
            all_ok = False
    
    console.print(table)
    
    if all_ok:
        console.print(Panel("✅ Všechny kontroly prošly – STARCORE je plně funkční", style="bold green"))
    else:
        console.print(Panel("❌ Některé kontroly selhaly – opravte problémy", style="bold red"))
    
    # Doporučení
    console.print("\n[bold cyan]💡 Doporučení:[/bold cyan]")
    if not hive_status["running"]:
        console.print("  • Spusť HIVE: ./starcore hive-start")
    if not ai_status["running"]:
        console.print("  • Spusť AI Runtime: ./starcore ai-start")
    if not dash_ok:
        console.print("  • Spusť Dashboard: ./starcore start dashboard")
    if running == 0:
        console.print("  • Spusť testovací službu: ./starcore start test")
    
    return all_ok
