import json, psutil

MANIFEST = "ULTRA_MANIFEST.json"

def recommend(profile):
    with open(MANIFEST) as f:
        data = json.load(f)

    ram = psutil.virtual_memory().total / (1024**3)
    modules = data["modules"]

    enabled = []
    disabled = []

    for m, meta in modules.items():
        if meta.get("required"):
            enabled.append(m)
            continue

        if ram < 6 and meta.get("heavy"):
            disabled.append(m)
        else:
            enabled.append(m)

    if profile == "pentest" and "ai" not in enabled:
        enabled.append("ai")

    return enabled, disabled

if __name__ == "__main__":
    e, d = recommend("full")
    print("ENABLE:", e)
    print("DISABLE:", d)
