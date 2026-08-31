import subprocess
import json
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich import box

console = Console()

def _run_termux_api(cmd: list) -> dict:
    """Spustí Termux:API příkaz a vrátí JSON výstup."""
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
        if result.returncode != 0:
            return {"error": result.stderr.strip()}
        return json.loads(result.stdout)
    except json.JSONDecodeError:
        return {"error": "Neplatný JSON výstup", "raw": result.stdout}
    except FileNotFoundError:
        return {"error": f"Příkaz {cmd[0]} nebyl nalezen. Nainstalujte Termux:API."}
    except Exception as e:
        return {"error": str(e)}

def battery():
    """Zobrazí informace o baterii."""
    data = _run_termux_api(["termux-battery-status"])
    if "error" in data:
        console.print(f"[red]❌ Chyba: {data['error']}[/red]")
        return
    table = Table(title="🔋 Baterie", box=box.ROUNDED)
    table.add_column("Parametr", style="cyan")
    table.add_column("Hodnota", style="green")
    for key, value in data.items():
        if key in ["percentage", "temperature", "voltage", "current"]:
            table.add_row(key, str(value))
    console.print(table)

def notify(message: str, title: str = "STARCORE", priority: str = "high"):
    """Odešle notifikaci."""
    cmd = ["termux-notification", "--title", title, "--content", message, "--priority", priority]
    try:
        subprocess.run(cmd, check=True, timeout=2)
        console.print(f"[green]✅ Notifikace odeslána: {title} - {message}[/green]")
    except Exception as e:
        console.print(f"[red]❌ Chyba notifikace: {e}[/red]")

def sensors():
    """Zobrazí dostupné senzory a jejich hodnoty."""
    data = _run_termux_api(["termux-sensor", "-s", "all"])
    if "error" in data:
        console.print(f"[red]❌ Chyba: {data['error']}[/red]")
        return
    table = Table(title="📡 Senzory", box=box.ROUNDED)
    table.add_column("Senzor", style="cyan")
    table.add_column("Hodnota", style="green")
    table.add_column("Jednotka", style="yellow")
    for sensor, values in data.items():
        if isinstance(values, dict) and "values" in values:
            for v in values["values"]:
                if v.get("value") is not None:
                    unit = v.get("unit", "")
                    table.add_row(sensor, str(v["value"]), unit)
                    break
        else:
            table.add_row(sensor, str(values), "")
    console.print(table)

def wifi():
    """Zobrazí informace o WiFi připojení."""
    data = _run_termux_api(["termux-wifi-connectioninfo"])
    if "error" in data:
        console.print(f"[red]❌ Chyba: {data['error']}[/red]")
        return
    table = Table(title="📶 WiFi", box=box.ROUNDED)
    table.add_column("Parametr", style="cyan")
    table.add_column("Hodnota", style="green")
    for key in ["ssid", "bssid", "frequency", "rssi", "link_speed", "ip"]:
        if key in data:
            table.add_row(key, str(data[key]))
    console.print(table)

def voice(text: str, language: str = "cs-CZ"):
    """Přečte text hlasem (Text-to-Speech)."""
    cmd = ["termux-tts-speak", "-l", language, text]
    try:
        subprocess.run(cmd, check=True, timeout=10)
        console.print(f"[green]✅ Hlasový výstup: {text}[/green]")
    except Exception as e:
        console.print(f"[red]❌ Chyba TTS: {e}[/red]")

def listen():
    """Rozpozná hlas na text (Speech-to-Text)."""
    console.print("[yellow]🎤 Poslouchám... (řekněte něco)[/yellow]")
    try:
        result = subprocess.run(["termux-speech-to-text"], capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            console.print(f"[green]✅ Rozpoznáno:[/green] {result.stdout.strip()}")
        else:
            console.print(f"[red]❌ Chyba rozpoznávání: {result.stderr}[/red]")
    except subprocess.TimeoutExpired:
        console.print("[yellow]⏰ Časový limit vypršel[/yellow]")
    except Exception as e:
        console.print(f"[red]❌ Chyba: {e}[/red]")
