import os
import subprocess
import shutil
import time
from rich.console import Console
from rich.panel import Panel
from core.logging import logger

console = Console()

def check_ollama():
    return shutil.which("ollama") is not None

def start_ollama_server():
    """Spustí Ollama server na pozadí a počká, až bude dostupný."""
    try:
        # Zabijeme starý proces
        subprocess.run(["pkill", "-f", "ollama serve"], capture_output=True)
        time.sleep(1)
        
        # Spustíme nový server
        subprocess.Popen(["ollama", "serve"], 
                        stdout=subprocess.DEVNULL, 
                        stderr=subprocess.DEVNULL,
                        start_new_session=True)
        
        # Počkáme, až bude server dostupný (max 10s)
        for i in range(10):
            try:
                subprocess.run(["ollama", "list"], capture_output=True, timeout=2)
                return True
            except:
                time.sleep(1)
        return False
    except Exception as e:
        logger.error(f"Chyba při spouštění Ollama: {e}")
        return False

def setup_local():
    console.print(Panel("[bold cyan]🤖 Nastavení lokálního AI modelu[/bold cyan]"))
    
    if not check_ollama():
        console.print("[red]❌ Ollama není nainstalován[/red]")
        console.print("[yellow]Nainstaluj ručně: pkg install ollama[/yellow]")
        console.print("[yellow]nebo stáhni z https://ollama.com/download[/yellow]")
        return False
    
    console.print("[bold yellow]Spouštím Ollama server...[/bold yellow]")
    if not start_ollama_server():
        console.print("[red]❌ Nepodařilo se spustit Ollama server[/red]")
        console.print("[yellow]Zkus spustit ručně: ollama serve[/yellow]")
        return False
    
    model = "llama3.2"
    console.print(f"[bold yellow]Kontrola modelu {model}...[/bold yellow]")
    try:
        result = subprocess.run(["ollama", "list"], capture_output=True, text=True)
        if model not in result.stdout:
            console.print(f"[yellow]Stahuji model {model}...[/yellow]")
            subprocess.run(["ollama", "pull", model], check=True)
            console.print("[green]✅ Model stažen[/green]")
        else:
            console.print("[green]✅ Model již existuje[/green]")
    except Exception as e:
        logger.error(f"Chyba při kontrole modelu: {e}")
        console.print(f"[red]❌ Chyba: {e}[/red]")
        return False
    
    # Konfigurace STARCORE
    from .runtime import ai
    ai.set_config("provider", "local")
    ai.set_config("base_url", "http://localhost:11434/v1")
    ai.set_config("model", model)
    
    console.print("[green]✅ Lokální model nastaven[/green]")
    console.print("[bold]Nyní můžeš použít:[/bold]")
    console.print("  ./starcore ai-start")
    console.print("  ./starcore ai-query 'Ahoj'")
    return True
