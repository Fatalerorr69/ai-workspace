import time, threading
from ai_logs import tail_logs
from ai_config import AI_LOG_FILE, ALERT_LEVELS

from rich.console import Console
console = Console()

def analyze_line(line):
    if "adb" in line.lower():
        return "Android problém – zkontroluj připojení / autorizaci"
    if "kali" in line.lower() and "error" in line.lower():
        return "Chyba Kali chroot – ověř rootfs a mounty"
    if "permission denied" in line.lower():
        return "Oprávnění – doporučeno sudo / chmod"

    if "ERROR" in line:
        return f"Kritická chyba: {line}"
    if "WARNING" in line:
        return f"Varování: {line}"

def run_ai():
    with open(AI_LOG_FILE, "a") as ai_log:
        for line in tail_logs():
            alert = analyze_line(line)
            if alert:
                ai_log.write(alert + "\n")
                ai_log.flush()

from rich.console import Console
console = Console()

# ai_core.py – run_daemon()
from plugin_ai import run_ai_plugin_recommender

def run_ai():
    with open(AI_LOG_FILE, "a") as ai_log:
        for line in tail_logs():
            alert = analyze_line(line)
            if alert:
                ai_log.write(alert+"\n")
                ai_log.flush()
        # Kontrola pluginů každých 15 minut
        run_ai_plugin_recommender()
