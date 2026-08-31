#!/usr/bin/env python3
import psutil
import subprocess
import json
import time
import sqlite3
from datetime import datetime

POLICY_FILE = "/opt/platform/ai-engine/policy.json"
DB_FILE = "/opt/platform/ai-engine/memory.db"
LOG_FILE = "/opt/platform/ai-engine/ai.log"

def log(msg):
    with open(LOG_FILE, "a") as f:
        f.write(f"{datetime.now()} - {msg}\n")

def load_policy():
    with open(POLICY_FILE) as f:
        return json.load(f)

def init_db():
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    c.execute("""
    CREATE TABLE IF NOT EXISTS actions (
        timestamp TEXT,
        cpu REAL,
        disk REAL,
        ram REAL,
        action TEXT,
        result TEXT
    )
    """)
    conn.commit()
    conn.close()

def save_action(state, action, result):
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    c.execute("INSERT INTO actions VALUES (?,?,?,?,?,?)",
              (datetime.now(), state["cpu"], state["disk"], state["ram"], action, result))
    conn.commit()
    conn.close()

def get_state():
    return {
        "cpu": psutil.cpu_percent(interval=1),
        "ram": psutil.virtual_memory().percent,
        "disk": psutil.disk_usage("/").percent
    }

def decide(state):
    if state["disk"] > 85:
        return "cleanup_disk"
    if state["cpu"] > 90:
        return "restart_service"
    return "none"

def execute_action(action, policy):
    if action == "cleanup_disk":
        subprocess.call(["python3", "/opt/platform/ai-engine/actions.py", "cleanup_disk"])
        return "executed"
    elif action == "restart_service":
        subprocess.call(["python3", "/opt/platform/ai-engine/actions.py", "restart_service", "docker"])
        return "executed"
    return "skipped"

def main():
    init_db()
    log("AI Engine started")

    while True:
        policy = load_policy()
        state = get_state()
        action = decide(state)

        log(f"State: {state}, Decision: {action}")

        if policy["mode"] == "observe":
            save_action(state, action, "observe_only")

        elif policy["mode"] == "assist":
            save_action(state, action, "suggested")

        elif policy["mode"] == "auto":
            if action in policy["allowed_actions"]:
                result = execute_action(action, policy)
                save_action(state, action, result)

        time.sleep(300)

if __name__ == "__main__":
    main()
