import re

FILE = "data/rpi5_github_index.md"

with open(FILE, "r", encoding="utf-8") as f:
    content = f.read()

repos = re.findall(r"\[(.*?)\]\((https://github.com/.*?)\)", content)

print(f"Nalezeno {len(repos)} zdrojů:\n")

for name, url in repos:
    print(f"{name} -> {url}")
