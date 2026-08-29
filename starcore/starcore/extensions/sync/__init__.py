import subprocess
import json
from pathlib import Path
from rich.console import Console
from rich.panel import Panel
from core.config import settings

console = Console()
SSH_CONFIG_DIR = settings.BASE_DIR / "ssh_configs"

def _get_ssh_target(ssh_name: str) -> str:
    """Načte konfiguraci SSH spojení a vrátí user@host."""
    config_file = SSH_CONFIG_DIR / f"{ssh_name}.json"
    if not config_file.exists():
        return ssh_name  # fallback
    with open(config_file, "r") as f:
        config = json.load(f)
    return f"{config.get('user', 'root')}@{config['host']}"

def sync(source: str, target: str, ssh: str = None, exclude: str = None):
    """Synchronizuje zdroj a cíl přes rsync."""
    cmd = ["rsync", "-avz", "--progress"]
    if exclude:
        cmd.extend(["--exclude", exclude])
    if ssh:
        # Pokud je ssh jméno spojení, převedeme ho na user@host
        if not ssh.endswith('.json') and not '@' in ssh:
            ssh = _get_ssh_target(ssh)
        cmd.extend(["-e", f"ssh -o StrictHostKeyChecking=no"])
    cmd.extend([source, target])
    console.print(f"[cyan]Spouštím: {' '.join(cmd)}[/cyan]")
    try:
        subprocess.run(cmd, check=True)
        console.print("[green]✅ Synchronizace dokončena[/green]")
    except subprocess.CalledProcessError as e:
        console.print(f"[red]Chyba synchronizace: {e}[/red]")

def push(local: str, remote: str, ssh_name: str = None):
    """Odešle lokální adresář na vzdálený server."""
    # remote by měl být buď user@host:/cesta, nebo jen /cesta pokud použijeme ssh_name
    if ssh_name:
        # Pokud remote neobsahuje @, předpokládáme, že je to jen cesta
        if '@' not in remote and ':' not in remote:
            target_host = _get_ssh_target(ssh_name)
            target = f"{target_host}:{remote}"
        else:
            target = remote
        sync(local, target, ssh=ssh_name)
    else:
        sync(local, remote)

def pull(remote: str, local: str, ssh_name: str = None):
    """Stáhne vzdálený adresář lokálně."""
    if ssh_name:
        if '@' not in remote and ':' not in remote:
            target_host = _get_ssh_target(ssh_name)
            remote = f"{target_host}:{remote}"
        sync(remote, local, ssh=ssh_name)
    else:
        sync(remote, local)

def watch(local: str, remote: str, ssh_name: str = None):
    """Sleduje změny a automaticky synchronizuje (pomocí inotifywait)."""
    console.print("[yellow]Sledování změn vyžaduje nástroj inotifywait[/yellow]")
    console.print("[yellow]Pro automatickou synchronizaci použijte: inotifywait -r -m ...[/yellow]")
