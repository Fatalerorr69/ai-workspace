import typer
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from . import runtime

console = Console()

def start():
    if runtime.start():
        console.print("[green]✅ AI Runtime spuštěn[/green]")
    else:
        console.print("[red]❌ AI Runtime se nepodařilo spustit[/red]")

def stop():
    runtime.stop()
    console.print("[yellow]✅ AI Runtime zastaven[/yellow]")

def status():
    status = runtime.status()
    table = Table(title="AI Runtime Status", show_header=True)
    table.add_column("Komponenta", style="cyan")
    table.add_column("Stav", style="yellow")
    table.add_row("Runtime", "🟢 Running" if status["running"] else "🔴 Stopped")
    table.add_row("Provider", status["provider"])
    table.add_row("Model", status["model"])
    console.print(table)

def config(
    key: str = typer.Argument(None, help="Klíč konfigurace"),
    value: str = typer.Argument(None, help="Hodnota")
):
    if key and value is not None:
        runtime.set_config(key, value)
        console.print(f"[green]✅ Nastaveno: {key} = {value[:20]}...[/green]")
    elif key:
        config_data = runtime.get_config()
        console.print(f"{key}: {config_data.get(key, 'nenalezeno')}")
    else:
        config_data = runtime.get_config()
        table = Table(title="AI Konfigurace", show_header=True)
        table.add_column("Klíč", style="cyan")
        table.add_column("Hodnota", style="white")
        for k, v in config_data.items():
            if k == "api_key" and v:
                v = v[:10] + "..." + v[-4:] if len(v) > 14 else v
            table.add_row(k, v if v else "(prázdné)")
        console.print(table)

def query(prompt: str, system: str = None):
    with console.status("[bold green]Zpracovávám dotaz...[/bold green]"):
        response = runtime.query(prompt, system)
    console.print(Panel(response, title="AI Odpověď", border_style="blue"))

def test():
    console.print("[bold cyan]Test AI spojení...[/bold cyan]")
    config_data = runtime.get_config()
    console.print(f"Provider: {config_data['provider']}")
    console.print(f"Model: {config_data['model']}")
    console.print(f"Base URL: {config_data['base_url']}")
    api_key = config_data.get('api_key', '')
    console.print(f"API Key: {api_key[:10] + '...' + api_key[-4:] if api_key and len(api_key) > 14 else '(prázdný)'}")

    if not api_key and config_data['provider'] != 'local':
        console.print("[red]❌ Chybí API klíč[/red]")
        return

    runtime.start()
    if not runtime.status()["running"]:
        console.print("[red]❌ Runtime se nepodařilo spustit[/red]")
        return

    response = runtime.query("Odpověz jedním slovem: OK?", "Odpovídej pouze 'ANO' nebo 'NE'.")
    runtime.stop()
    console.print(f"[bold]Odpověď:[/bold] {response}")

def local_setup():
    console.print("[yellow]Lokální setup bude brzy dostupný[/yellow]")
