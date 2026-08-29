# enhanced secret detector
import re
from pathlib import Path

WHITELIST = [
    # add patterns or exact filenames to ignore (e.g., public sample keys)
]

PATTERNS = {
    "AWS_ACCESS_KEY": re.compile(r"AKIA[0-9A-Z]{16}"),
    "AWS_SECRET": re.compile(r"(?i)aws(.{0,6})?secret(.{0,6})?[:=]\s*['\"]?[A-Za-z0-9/+=]{20,}['\"]?"),
    "SSH_PRIVATE_KEY_START": re.compile(r"-----BEGIN (RSA|OPENSSH|PRIVATE) KEY-----"),
    "POTENTIAL_API_KEY": re.compile(r"(?i)api[_-]?(key|token)\\W*[:=]\\W*[A-Za-z0-9\\-_.]{8,}"),
    "JWT": re.compile(r"eyJ[A-Za-z0-9-_]+\\.[A-Za-z0-9-_]+\\.[A-Za-z0-9-_]+")
}

def score_match(pattern_name, match_text):
    # jednoduché skórování pro prioritizaci
    if pattern_name.startswith("SSH") or pattern_name.startswith("AWS"):
        return 9
    if pattern_name == "JWT":
        return 7
    return 5

def analyze(path, content):
    if not content:
        try:
            content = Path(path).read_text(errors="ignore")
        except Exception:
            content = ""
    findings = []
    # whitelist by filename
    for w in WHITELIST:
        if w in path:
            return {"plugin": "secret_detector_enhanced", "skipped": True}
    for name, pat in PATTERNS.items():
        for m in pat.finditer(content):
            snippet = m.group(0)[:200]
            findings.append({"type": name, "snippet": snippet, "score": score_match(name, snippet)})
    return {"plugin": "secret_detector_enhanced", "count": len(findings), "findings": findings}
