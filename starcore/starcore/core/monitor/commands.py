import typer
import subprocess
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from core.config import settings

console = Console()

def monitor():
    """Zobrazí aktuální využití systémových zdrojů."""
    table = Table(title="STARCORE System Monitor", show_header=True)
    table.add_column("Parametr", style="cyan")
    table.add_column("Hodnota", style="green")

    # CPU
    try:
        cpu = subprocess.check_output("top -bn1 | grep 'Cpu(s)' | awk '{print $2}'", shell=True, text=True).strip()
        table.add_row("CPU", f"{cpu}%")
    except:
        table.add_row("CPU", "N/A")

    # RAM
    try:
        mem = subprocess.check_output("free -h | grep Mem | awk '{print $3 \"/\" $2}'", shell=True, text=True).strip()
        table.add_row("RAM", mem)
    except:
        table.add_row("RAM", "N/A")

    # Disk
    try:
        disk = subprocess.check_output("df -h ~ | tail -1 | awk '{print $3 \"/\" $2 \" (\" $5 \")\"}'", shell=True, text=True).strip()
        table.add_row("Disk", disk)
    except:
        table.add_row("Disk", "N/A")

    # Network
    try:
        net = subprocess.check_output("ifconfig wlan0 | grep 'inet ' | awk '{print $2}'", shell=True, text=True).strip()
        table.add_row("IP", net if net else "N/A")
    except:
        table.add_row("IP", "N/A")

    console.print(table)
