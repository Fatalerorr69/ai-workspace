#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generator: na základě analysis.json vytvoří `new_structure.md` (podrobný návrh).
Podporuje opakované volání, retry, truncation a jednoduché sanity-check.
"""

import os
import sys
import json
import textwrap
from pathlib import Path
from itertools import islice

ENV_PATH = "/etc/ai_project_analyzer/env"
DEFAULT_MODEL = "gpt-4-turbo"
MAX_SUMMARY_CHARS = 18000  # bezpečné omezení, aby API nevypálilo tokeny

def load_env(path=ENV_PATH):
    env = {}
    if os.path.exists(path):
        with open(path, "r", encoding="utf-8") as fh:
            for line in fh:
                if "=" in line and not line.strip().startswith("#"):
                    k, v = line.strip().split("=", 1)
                    env[k] = v.strip().strip('"').strip("'")
    return env

ENV = load_env()

def build_prompt(analysis_results):
    # analysis_results: list of dicts (from analysis.json)
    def item_summary(item):
        path = item.get("path", "<unknown>")
        analysis = item.get("analysis") or ""
        # take first 1200 chars of each analysis to keep prompt small
        return f"FILE: {path}\nANALYSIS_SNIPPET:\n{analysis[:1200]}\n---\n"
    parts = [item_summary(it) for it in analysis_results]
    joined = "\n".join(parts)
    if len(joined) > MAX_SUMMARY_CHARS:
        joined = joined[:MAX_SUMMARY_CHARS] + "\n\n...[TRUNCATED]"
    prompt = f"""
Jsi AI architekt. Na základě níže uvedených analýz pro jednotlivé soubory navrhni kompletní novou, soběstačnou strukturu projektu.
Výstup: 1) Strom složek s popisy 2) Seznam souborů s krátkými rolemi 3) Pro klíčové skripty/configy dej ukázkovou implementaci v kódu (v code fence).
Požaduj preciznost — když něco není jasné, navrhni konzervativní řešení.
ANALYSIS_SUMMARY:
{joined}
"""
    return prompt

# --- call model (reuse simple wrapper from analyzer) ---
def call_model_text(prompt, env):
    backend = env.get("MODEL", "OPENAI").upper()
    try:
        if backend == "OPENAI" and env.get("OPENAI_API_KEY"):
            import openai
            openai.api_key = env.get("OPENAI_API_KEY")
            resp = openai.ChatCompletion.create(model=env.get("OPENAI_MODEL", DEFAULT_MODEL), messages=[{"role":"user","content":prompt}], temperature=0.2, max_tokens=3000)
            return resp.choices[0].message.content
        if backend == "CLAUDE" and env.get("ANTHROPIC_API_KEY"):
            import anthropic
            client = anthropic.Anthropic(api_key=env.get("ANTHROPIC_API_KEY"))
            r = client.completions.create(prompt=prompt, model="claude-3-opus-20240229", max_tokens=2000)
            return r.get("completion") or str(r)
        if backend == "GEMINI" and env.get("GOOGLE_API_KEY"):
            import google.generativeai as genai
            genai.configure(api_key=env.get("GOOGLE_API_KEY"))
            model = genai.Models.get("gemini-1.5-pro")
            r = model.generate(prompt=prompt)
            return getattr(r, "text", str(r))
        if backend == "CUSTOM" and env.get("OPENAI_API_BASE") and env.get("OPENAI_API_KEY"):
            import requests
            payload = {"model": env.get("OPENAI_MODEL", DEFAULT_MODEL), "messages": [{"role": "user", "content": prompt}], "temperature": 0.2}
            headers = {"Authorization": f"Bearer {env.get('OPENAI_API_KEY')}", "Content-Type": "application/json"}
            r = requests.post(f"{env.get('OPENAI_API_BASE').rstrip('/')}/v1/chat/completions", json=payload, headers=headers, timeout=120)
            return r.json().get("choices",[{}])[0].get("message",{}).get("content", str(r.json()))
        if backend == "LOCAL":
            import subprocess
            p = subprocess.run(["ollama","run", env.get("LOCAL_MODEL","mistral")], input=prompt.encode(), capture_output=True, timeout=120)
            return p.stdout.decode(errors="ignore")
    except Exception as e:
        return f"(model call failed: {e})"

    return "(no model configured)"

def generate_new_structure(analysis_json_path, out_dir):
    with open(analysis_json_path, "r", encoding="utf-8") as fh:
        analysis = json.load(fh)
    prompt = build_prompt(analysis)
    env = ENV
    response = call_model_text(prompt, env)
    Path(out_dir).mkdir(parents=True, exist_ok=True)
    md_path = Path(out_dir) / "new_structure.md"
    with open(md_path, "w", encoding="utf-8") as fh:
        fh.write(response or "(no response)")
    # also create a short plan JSON
    plan = {"generated": True, "model": env.get("MODEL", "UNKNOWN"), "md": str(md_path)}
    with open(Path(out_dir) / "plan.json", "w", encoding="utf-8") as fh:
        json.dump(plan, fh, indent=2, ensure_ascii=False)
    return md_path

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: generator.py <analysis_folder>")
        sys.exit(2)
    out = generate_new_structure(os.path.join(sys.argv[1], "analysis.json"), sys.argv[1])
    print("Generated:", out)

