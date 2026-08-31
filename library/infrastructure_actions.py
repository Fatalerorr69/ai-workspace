#!/usr/bin/env python3
import subprocess
import sys
import json
from datetime import datetime

LOGFILE = "/opt/platform/ai-engine/actions.log"

def log(msg):
    with open(LOGFILE, "a") as f:
        f.write(f"{datetime.now()} - {msg}\n")

def restart_service(service):
    subprocess.call(["systemctl", "restart", service])
    log(f"restart_service:{service}")

def run_backup():
    subprocess.call(["/opt/platform/modules/backup.sh"])
    log("run_backup")

def cleanup_disk():
    subprocess.call(["apt", "autoremove", "-y"])
    subprocess.call(["apt", "clean"])
    log("cleanup_disk")

def scale_container(app, replicas):
    subprocess.call(["kubectl", "scale", "deployment", app, f"--replicas={replicas}"])
    log(f"scale_container:{app}:{replicas}")

if __name__ == "__main__":
    action = sys.argv[1]

    if action == "restart_service":
        restart_service(sys.argv[2])
    elif action == "run_backup":
        run_backup()
    elif action == "cleanup_disk":
        cleanup_disk()
    elif action == "scale_container":
        scale_container(sys.argv[2], sys.argv[3])
    else:
        log("unknown_action")
