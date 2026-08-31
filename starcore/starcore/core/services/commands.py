import typer
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from .manager import manager

console = Console()

def start(service: str):
    """Spustí službu."""
    if manager.start(service):
        console.print(f"✅ Služba [green]{service}[/green] spuštěna")
    else:
        console.print(f"❌ Chyba při spouštění [red]{service}[/red]")

def stop(service: str):
    """Zastaví službu."""
    if manager.stop(service):
        console.print(f"✅ Služba [yellow]{service}[/yellow] zastavena")
    else:
        console.print(f"❌ Chyba při zastavování [red]{service}[/red]")

def status(service: str = None):
    """Zobrazí stav služby / všech služeb."""
    statuses = manager.status(service)
    if not statuses:
        console.print("❌ Žádné služby nejsou registrovány")
        return

    table = Table(title="STARCORE Service Status", show_header=True)
    table.add_column("Služba", style="cyan")
    table.add_column("Stav", style="yellow")
    table.add_column("Příkaz", style="dim")
    table.add_column("Popis", style="white")

    for name, data in statuses.items():
        status_icon = "🟢" if data["status"] == "running" else "🔴"
        table.add_row(name, f"{status_icon} {data['status']}", data["command"][:50], data["description"])

    console.print(table)

def logs(service: str, lines: int = 50):
    """Zobrazí log služby."""
    log_content = manager.logs(service, lines)
    console.print(Panel(log_content, title=f"Log: {service}", border_style="blue"))

def restart(service: str):
    """Restartuje službu."""
    if manager.restart(service):
        console.print(f"✅ Služba [green]{service}[/green] restartována")
    else:
        console.print(f"❌ Chyba při restartu [red]{service}[/red]")
