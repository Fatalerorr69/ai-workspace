#!/usr/bin/env python3

import os
import json
import subprocess
from datetime import datetime


BASE=os.path.expanduser("~/STARCORE")


def run(cmd):
    try:
        return subprocess.check_output(
            cmd,
            shell=True,
            text=True
        ).strip()
    except:
        return "unknown"


report={

    "component":
    "STARCORE Performance Analyzer",

    "version":
    "7.0.17",

    "timestamp":
    datetime.utcnow().isoformat(),

    "metrics":
    {
        "cpu":
        run("nproc"),

        "memory":
        run("free -h"),

        "storage":
        run("du -sh ~/STARCORE")
    },

    "status":
    "online"
}


with open(
f"{BASE}/runtime/performance/performance_report.json",
"w"
) as f:

    json.dump(
        report,
        f,
        indent=4
    )


print("PERFORMANCE ANALYZER ONLINE")

