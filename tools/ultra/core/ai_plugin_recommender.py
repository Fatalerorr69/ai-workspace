import json, sys

PROFILE = sys.argv[1] if len(sys.argv) > 1 else "full"

with open("registry/plugin_marketplace.json") as f:
    plugins = json.load(f)["plugins"]

recommended = []

for p in plugins:
    if PROFILE in p.get("tags", []):
        recommended.append(p["id"])
    if PROFILE == "pentest" and "security" in p.get("tags", []):
        recommended.append(p["id"])

print("RECOMMEND:", " ".join(set(recommended)))
