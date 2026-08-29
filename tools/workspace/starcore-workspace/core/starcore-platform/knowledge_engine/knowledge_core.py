#!/usr/bin/env python3

import json
import os
from datetime import datetime


BASE=os.path.expanduser("~/STARCORE")


state={
    "component":"STARCORE Knowledge Engine",
    "version":"7.0.07",
    "timestamp":datetime.utcnow().isoformat(),
    "indexes":[],
    "memory_connector":"ready",
    "status":"online"
}


with open(
f"{BASE}/runtime/knowledge/knowledge_state.json",
"w"
) as f:
    json.dump(state,f,indent=4)


print("KNOWLEDGE ENGINE ONLINE")
