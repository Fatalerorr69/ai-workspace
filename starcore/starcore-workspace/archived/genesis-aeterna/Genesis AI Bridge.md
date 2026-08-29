`import requests`  
`import json`  
`import os`  
`from pathlib import Path`

`# Konfigurace cest podle globální ústavy projektu`  
`LOG_PATH = Path.home() / "genesis/logs/genesis_v8_global.log"`  
`OLLAMA_API = "http://localhost:11434/api/generate"`

`class GenesisBridge:`  
    `"""Propojuje systémové logy s inteligencí Ollama."""`  
      
    `def __init__(self, model="genesis-analytik"):`  
        `self.model = model`

    `def get_recent_logs(self, lines=20):`  
        `if not LOG_PATH.exists():`  
            `return "Log soubor neexistuje."`  
        `with open(LOG_PATH, "r") as f:`  
            `return "".join(f.readlines()[-lines:])`

    `def analyze_status(self):`  
        `logs = self.get_recent_logs()`  
        `prompt = (`  
            `f"Jsi Genesis Analytik. Zde jsou poslední záznamy z logů:\n{logs}\n"`  
            `"Identifikuj kritické chyby a navrhni přesné Bash příkazy pro jejich opravu."`  
        `)`  
          
        `payload = {`  
            `"model": self.model,`  
            `"prompt": prompt,`  
            `"stream": False`  
        `}`

        `try:`  
            `response = requests.post(OLLAMA_API, json=payload, timeout=30)`  
            `if response.status_code == 200:`  
                `return response.json().get("response", "AI neposkytla odpověď.")`  
            `return f"Chyba API: {response.status_code}"`  
        `except Exception as e:`  
            `return f"Chyba připojení k Ollama: {str(e)}"`

`if __name__ == "__main__":`  
    `bridge = GenesisBridge()`  
    `print("--- AI ANALÝZA SYSTÉMU ---")`  
    `print(bridge.analyze_status())`  
