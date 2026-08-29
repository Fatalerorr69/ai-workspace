import requests, os
from datetime import datetime

TOKEN = os.getenv("GITHUB_TOKEN")
HEADERS = {"Authorization": f"token {TOKEN}"} if TOKEN else {}

KEYWORDS = ["raspberry pi 5", "rpi5", "arm64", "raspi", "bcm2712"]

CATEGORIES = {
    "OS": ["linux","distro","ubuntu","debian","arch"],
    "AI": ["ai","ml","llm"],
    "Docker/DevOps": ["docker","kubernetes","container"],
    "IoT/GPIO": ["gpio","iot","sensor"],
    "Media/Gaming": ["retro","emulator","kodi","game"],
    "Security": ["pentest","hack","security"],
    "Web/Dashboard": ["dashboard","monitor","web"],
    "Other": []
}

def categorize(text):
    t = text.lower()
    for cat, words in CATEGORIES.items():
        for w in words:
            if w in t:
                return cat
    return "Other"

results = []

for kw in KEYWORDS:
    url = f"https://api.github.com/search/repositories?q={kw}&sort=stars&order=desc&per_page=30"
    r = requests.get(url, headers=HEADERS)
    items = r.json().get("items", [])

    for repo in items:
        desc = repo["description"] or ""
        cat = categorize(repo["name"] + desc)

        results.append({
            "name": repo["full_name"],
            "url": repo["html_url"],
            "stars": repo["stargazers_count"],
            "lang": repo["language"],
            "category": cat
        })

timestamp = datetime.now().strftime("%Y-%m-%d %H:%M")

with open("data/rpi5_github_index.md", "w", encoding="utf-8") as f:
    f.write(f"# Raspberry Pi 5 GitHub Catalog\n\nAktualizace: {timestamp}\n\n")
    for cat in sorted(set(r["category"] for r in results)):
        f.write(f"## {cat}\n\n")
        for r in results:
            if r["category"] == cat:
                f.write(f"- [{r['name']}]({r['url']}) ⭐{r['stars']} ({r['lang']})\n")


import json

with open("data/rpi5_github_index.json", "w", encoding="utf-8") as f:
    json.dump(results, f, indent=2, ensure_ascii=False)


import json

with open("data/rpi5_github_index.json") as f:
    data = json.load(f)

for repo in data:
    print(repo["name"], repo["url"], repo["category"])

print("Hotovo")
