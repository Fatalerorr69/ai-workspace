import subprocess
import shutil

def check_termux_api():
    """Ověří, zda je nainstalován Termux:API a dostupný."""
    if shutil.which("termux-battery-status") is not None:
        try:
            subprocess.run(["termux-battery-status"], capture_output=True, timeout=2)
            return True
        except:
            return False
    return False
