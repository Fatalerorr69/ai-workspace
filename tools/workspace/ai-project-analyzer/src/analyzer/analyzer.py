#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Analyzer: paralelní, plugin-aware analyzátor souborů.
Podporované backendy: OPENAI, CLAUDE, GEMINI, CUSTOM (OpenAI-compatible), LOCAL (Ollama/LocalAI)
Env: /etc/ai_project_analyzer/env nebo .env v BASE_DIR
Výstup: <output_dir>/analysis.json (list objektů s analýzou)
"""

import os
import sys
import json
import time
import traceback
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
import multiprocessing
import re

MAX_FILE_BYTES = 5 * 1024 * 1024
MAX_WORKERS = max(1, multiprocessing.cpu_count() - 1)
ENV_PATH = "/etc/ai_project_analyzer/env"
FALLBACK_MODEL = "gpt-4-turbo"

# --- util: načtení env ---
def load_env(path=ENV_PATH):
    env = {}
    if os.path.exists(path):
        with open(path, "r", encoding="utf-8") as fh:
            for line in fh:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                if "=" in line:
                    k, v = line.split("=", 1)
                    env[k.strip()] = v.strip().strip('"').strip("'")
    # také načti lokální .env pokud existuje v working dir
    if os.path.exists(".env"):
        with open(".env", "r", encoding="utf-8") as fh:
            for line in fh:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                if "=" in line:
                    k, v = line.split("=", 1)
                    env.setdefault(k.strip(), v.strip().strip('"').strip("'"))
    return env

ENV = load_env()

# --- plugin loader ---
PLUGINS_DIR = "/opt/ai_project_analyzer/plugins"
PLUGIN_FUNCS = []
if os.path.isdir(PLUGINS_DIR):
    for p in Path(PLUGINS_DIR).glob("*.py"):
        try:
            import importlib.util as iu
            spec = iu.spec_from_file_location(p.stem, str(p))
            m = iu.module_from_spec(spec)
            spec.loader.exec_module(m)
            if hasattr(m, "analyze"):
                PLUGIN_FUNCS.append(m.analyze)
        except Exception as e:
            print(f"[plugin load error] {p}: {e}")

# --- file readers + chunker (text/binary heuristics) ---
def is_binary(path: Path) -> bool:
    try:
        with open(path, "rb") as fh:
            chunk = fh.read(1024)
            if b"\0" in chunk:
                return True
    except Exception:
        return True
    return False

def read_text_truncated(path: Path, max_bytes=200_000):
    try:
        if is_binary(path):
            return None
        size = path.stat().st_size
        if size <= max_bytes:
            return path.read_text(errors="ignore")
        # chunking: return head + tail with marker
        head = path.read_text(errors="ignore")[: max_bytes // 2]
        tail = path.read_text(errors="ignore")[- max_bytes // 2 :]
        return head + "\n\n\n...[TRUNCATED]...\n\n\n" + tail
    except Exception:
        return None

# --- model call helpers ---
def call_openai_chat(messages, model=FALLBACK_MODEL, temperature=0.2, max_tokens=2000, api_base=None, api_key=None):
    import openai

    if api_key:
        openai.api_key = api_key
    if api_base:
        openai.api_base = api_base
    resp = openai.ChatCompletion.create(model=model, messages=messages, temperature=temperature, max_tokens=max_tokens)
    return resp.choices[0].message.content

def call_anthropic(prompt, model="claude-3-opus-20240229", max_tokens=2000, api_key=None):
    import anthropic

    client = anthropic.Anthropic(api_key=api_key)
    resp = client.completions.create(model=model, prompt=prompt, max_tokens=max_tokens)
    # probabilně vrací dict s klíčem 'completion' nebo 'text'
    if isinstance(resp, dict):
        return resp.get("completion") or resp.get("text") or str(resp)
    return str(resp)

def call_gemini(prompt, model="gemini-1.5-pro", api_key=None):
    import google.generativeai as genai

    genai.configure(api_key=api_key)
    model_obj = genai.Models.get(model)
    r = model_obj.generate(prompt=prompt)
    return getattr(r, "text", str(r))

def call_local_ollama(prompt, model="mistral", timeout=60):
    # assumes 'ollama run <model>' is available
    import subprocess
    p = subprocess.run(["ollama", "run", model], input=prompt.encode(), capture_output=True, timeout=timeout)
    return p.stdout.decode(errors="ignore")

def call_custom_openai_compatible(prompt, api_base, api_key, model=FALLBACK_MODEL):
    # use requests to generic endpoint (OpenAI-compatible)
    import requests, json
    headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}
    payload = {"model": model, "messages": [{"role": "user", "content": prompt}], "temperature": 0.2}
    r = requests.post(f"{api_base.rstrip('/')}/v1/chat/completions", json=payload, headers=headers, timeout=120)
    jj = r.json()
    return jj.get("choices", [{}])[0].get("message", {}).get("content", str(jj))

# --- compose prompt for file ---
PROMPT_TEMPLATE = """Jsi systematický AI inženýr. Níže je soubor a jeho kontext.
Analyzuj účel souboru, vazby (závislosti), možné bezpečnostní problémy (tajné klíče), doporučené přeuspořádání v nové struktuře, a navrhni mini implementaci (případně ukázkové části) pokud je to vhodné.
Uveď také, které soubory by měly být přesunuty nebo sloučeny.
Soubor: {path}
Velikost: {size} bytes
Obsah (možná oříznutý):
