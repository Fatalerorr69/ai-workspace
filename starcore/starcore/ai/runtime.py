import os
import json
import httpx
from pathlib import Path
from core.config import settings
from core.logging import logger

STATE_FILE = settings.DATA_DIR / "ai_state.json"
_config = None
_client = None

def _read_state():
    if STATE_FILE.exists():
        with open(STATE_FILE, "r") as f:
            return json.load(f)
    return {"running": False, "pid": None}

def _write_state(state):
    with open(STATE_FILE, "w") as f:
        json.dump(state, f, indent=2)

def _load_config():
    global _config
    config_file = settings.DATA_DIR / "ai_config.json"
    if config_file.exists():
        with open(config_file, "r") as f:
            _config = json.load(f)
    else:
        _config = {
            "provider": "openrouter",
            "api_key": "",
            "model": "openai/gpt-4o",
            "base_url": "https://openrouter.ai/api/v1"
        }
        _save_config()

def _save_config():
    with open(settings.DATA_DIR / "ai_config.json", "w") as f:
        json.dump(_config, f, indent=2)

def get_config():
    if _config is None:
        _load_config()
    return _config

def set_config(key: str, value: str):
    global _config
    if _config is None:
        _load_config()
    value = value.replace('\n', '').replace('\r', '').strip()
    _config[key] = value
    _save_config()

def start():
    state = _read_state()
    if state.get("running", False):
        logger.warning("AI Runtime již běží")
        return True
    state["running"] = True
    state["pid"] = os.getpid()
    _write_state(state)
    logger.info("AI Runtime started")
    return True

def stop():
    state = _read_state()
    if not state.get("running", False):
        return True
    state["running"] = False
    state["pid"] = None
    _write_state(state)
    logger.info("AI Runtime stopped")
    return True

def status():
    state = _read_state()
    config = get_config()
    return {
        "running": state.get("running", False),
        "provider": config.get("provider"),
        "model": config.get("model")
    }

def query(prompt: str, system_prompt: str = None) -> str:
    state = _read_state()
    if not state.get("running", False):
        return "AI Runtime není spuštěn. Spusťte 'starcore ai-start'."

    config = get_config()
    provider = config.get("provider", "openrouter")
    api_key = config.get("api_key", "").strip()
    model = config.get("model", "openai/gpt-4o")
    base_url = config.get("base_url", "https://openrouter.ai/api/v1").strip()

    if provider == "openrouter":
        url = f"{base_url}/chat/completions"
        headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
            "HTTP-Referer": "https://starcore.local",
            "X-Title": "STARCORE Mobile"
        }
        if not api_key:
            return "Chybí API klíč pro OpenRouter"
    elif provider == "openai":
        url = f"{base_url or 'https://api.openai.com/v1'}/chat/completions"
        headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }
        if not api_key:
            return "Chybí API klíč pro OpenAI"
    elif provider == "local":
        url = f"{base_url or 'http://localhost:11434/v1'}/chat/completions"
        headers = {"Content-Type": "application/json"}
    else:
        return f"Neznámý provider: {provider}"

    messages = []
    if system_prompt:
        messages.append({"role": "system", "content": system_prompt})
    messages.append({"role": "user", "content": prompt})

    payload = {
        "model": model,
        "messages": messages,
        "temperature": 0.7,
        "max_tokens": 1000
    }

    global _client
    if _client is None:
        _client = httpx.Client(timeout=60.0)

    try:
        response = _client.post(url, json=payload, headers=headers)
        response.raise_for_status()
        data = response.json()
        return data["choices"][0]["message"]["content"]
    except httpx.HTTPStatusError as e:
        return f"HTTP chyba {e.response.status_code}: {e.response.text[:200]}"
    except httpx.ConnectError:
        return f"Nelze se připojit k {url}"
    except Exception as e:
        return f"Chyba: {str(e)}"

_load_config()
