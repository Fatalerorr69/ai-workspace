import os
import sys
import platform
import subprocess

def get_system_info():
    info = {
        "OS": platform.system(),
        "Architektura": platform.machine(),
        "Python": sys.version.split()[0],
        "Termux": "Ano" if "com.termux" in os.environ.get("PREFIX", "") else "Ne",
        "Uživatel": os.environ.get("USER", "unknown"),
        "Domovský adresář": os.path.expanduser("~"),
        "Aktuální adresář": os.getcwd(),
    }
    # Pokus o získání verze Androidu
    try:
        output = subprocess.check_output(["getprop", "ro.build.version.release"], text=True).strip()
        if output:
            info["Android"] = output
    except:
        pass
    return info
