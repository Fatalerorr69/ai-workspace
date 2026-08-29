#!/usr/bin/env python3

import json
import os
from datetime import datetime


BASE=os.path.expanduser("~/STARCORE")


state={
    "component":"STARCORE API Gateway",
    "version":"7.0.05",
    "timestamp":datetime.utcnow().isoformat(),
    "services":[],
    "status":"online"
}


with open(
f"{BASE}/runtime/api/api_gateway.json",
"w"
) as f:
    json.dump(state,f,indent=4)


print("API GATEWAY ONLINE")
