import json, subprocess, requests
from pathlib import Path
from ai_config import ULTRA_ROOT

MARKETPLACE_URL = "https://ultra.local/plugins/market"

INSTALLED_PLUGINS_DIR = Path(f"{ULTRA_ROOT}/plugins/enabled")

def get_installed_plugins():
    return [p.name for p in INSTALLED_PLUGINS_DIR.iterdir() if p.is_dir()]

def fetch_marketplace():
    resp = requests.get(f"{MARKETPLACE_URL}")
    return resp.json().get("plugins", [])

def ai_recommend_plugins():
    installed = get_installed_plugins()
    market = fetch_marketplace()

    recommendations = []
    for plugin in market:
        name = plugin.get("name")
        requires = plugin.get("requires", [])
        if name not in installed and all(r in installed or r in ["core","ai"] for r in requires):
            recommendations.append(plugin)
    return recommendations

def auto_install_plugin(plugin):
    repo = plugin.get("repo")
    subprocess.run(["bash", f"{ULTRA_ROOT}/plugins/plugin_manager.sh", "install", repo])

def run_ai_plugin_recommender():
    recs = ai_recommend_plugins()
    for plugin in recs:
        auto_install_plugin(plugin)
        print(f"[AI] Nainstalován doporučený plugin: {plugin.get('name')}")
