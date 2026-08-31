import typer
from core import __version__

def version():
    """Zobrazí verzi STARCORE Core."""
    typer.echo(f"STARCORE Core v{__version__}")
