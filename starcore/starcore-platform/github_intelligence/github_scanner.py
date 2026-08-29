#!/usr/bin/env python3

import json
import os
from datetime import datetime


BASE=os.path.expanduser("~/STARCORE")


state={
    "component":"STARCORE GitHub Intelligence",
    "version":"7.0.06",
    "timestamp":datetime.utcnow().isoformat(),
    "repositories":[],
    "scanner":"ready",
    "status":"online"
}


with open(
f"{BASE}/runtime/github/github_registry.json",
"w"
) as f:
    json.dump(state,f,indent=4)


print("GITHUB INTELLIGENCE ONLINE")
