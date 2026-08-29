import typer
from rich.console import Console
from rich.table import Table
from core.utils.system import get_system_info

console = Console()

def info():
    """Zobrazí základní informace o systému a prostředí."""
    info = get_system_info()
    table = Table(title="STARCORE System Info")
    table.add_column("Klíč", style="cyan")
    table.add_column("Hodnota", style="green")
    for key, value in info.items():
        table.add_row(key, str(value))
    console.print(table)
