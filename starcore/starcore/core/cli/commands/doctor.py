import typer
import sys
import os
import shutil
import sqlite3
import socket
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from core.utils.termux import check_termux_api

console = Console()

def doctor():
    results = []

    # Python
    results.append(("Python", sys.version.split()[0], "✓" if sys.version_info >= (3, 9) else "✗"))

    # Git
    git_ok = shutil.which("git") is not None
    results.append(("Git", "nalezen" if git_ok else "nenalezen", "✓" if git_ok else "✗"))

    # tmux
    tmux_ok = shutil.which("tmux") is not None
    results.append(("tmux", "nalezen" if tmux_ok else "nenalezen", "✓" if tmux_ok else "✗"))

    # SQLite
    try:
        sqlite3.connect(":memory:").close()
        sqlite_ok = True
    except:
        sqlite_ok = False
    results.append(("SQLite", "dostupné" if sqlite_ok else "nedostupné", "✓" if sqlite_ok else "✗"))

    # Termux:API – ověříme pomocí ověřené funkce
    api_ok = check_termux_api()
    results.append(("Termux:API", "dostupné" if api_ok else "nedostupné", "✓" if api_ok else "✗"))

    # Přístup k úložišti
    storage_ok = os.access(os.path.expanduser("~"), os.W_OK)
    results.append(("Úložiště (zápis)", "přístupné" if storage_ok else "nepřístupné", "✓" if storage_ok else "✗"))

    # RAM
    try:
        with open("/proc/meminfo", "r") as f:
            mem = f.read()
        total_ram = None
        for line in mem.splitlines():
            if line.startswith("MemTotal:"):
                total_ram = int(line.split()[1]) // 1024
                break
        ram_info = f"{total_ram} MB" if total_ram else "neznámá"
    except:
        ram_info = "nelze zjistit"
        total_ram = 0
    results.append(("RAM", ram_info, "✓" if total_ram and total_ram > 512 else "⚠" if total_ram else "✗"))

    # Volné místo
    try:
        statvfs = os.statvfs(os.path.expanduser("~"))
        free = (statvfs.f_frsize * statvfs.f_bavail) // (1024**2)
        free_info = f"{free} MB"
        free_ok = free > 100
    except:
        free_info = "nelze zjistit"
        free_ok = False
    results.append(("Volné místo", free_info, "✓" if free_ok else "⚠" if free > 50 else "✗"))

    # Internet
    try:
        socket.create_connection(("1.1.1.1", 80), timeout=3)
        net_ok = True
    except:
        net_ok = False
    results.append(("Internet", "dostupný" if net_ok else "nedostupný", "✓" if net_ok else "✗"))

    # Tabulka
    table = Table(title="STARCORE Doctor", show_header=True, header_style="bold magenta")
    table.add_column("Kontrola", style="cyan")
    table.add_column("Stav", style="yellow")
    table.add_column("Výsledek", style="green")

    all_ok = True
    for name, value, status in results:
        color = "green" if "✓" in status else "red" if "✗" in status else "yellow"
        table.add_row(name, value, f"[{color}]{status}[/{color}]")
        if "✗" in status:
            all_ok = False

    console.print(table)
    if all_ok:
        console.print(Panel("✅ Všechny kontroly prošly. STARCORE je připraven.", style="green"))
    else:
        console.print(Panel("❌ Některé kontroly selhaly. Opravte problémy a spusťte znovu.", style="red"))
