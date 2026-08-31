#!/usr/bin/env python3
# ==============================================================
# AI Workspace Server – API pro Twister Smart Suite
# Autor: Starko, 2025
# ==============================================================

import os
import json
import subprocess
from http.server import HTTPServer, BaseHTTPRequestHandler

PLUGINS_DIR = os.path.expanduser("~/twisteros_supermanager/plugins")
STATUS_FILE = os.path.expanduser("~/twisteros_supermanager/plugins/plugin_status.json")
LOG_FILE = os.path.expanduser("~/twisteros_supermanager/logs/plugin.log")
PORT = 5000

class Handler(BaseHTTPRequestHandler):
    def _set_headers(self, code=200, content_type="application/json"):
        self.send_response(code)
        self.send_header('Content-type', content_type)
        self.end_headers()

    def _run_plugin(self, plugin_name, action):
        plugin_path = os.path.join(PLUGINS_DIR, f"{plugin_name}.sh")
        if not os.path.exists(plugin_path):
            return {"error": f"Plugin {plugin_name} neexistuje."}
        try:
            subprocess.run([plugin_path, action], check=True)
            with open(STATUS_FILE, "r") as f:
                status = json.load(f)
            return {"success": True, "status": status}
        except subprocess.CalledProcessError as e:
            return {"error": str(e)}

    def do_GET(self):
        if self.path == "/plugins":
            # Vrátí stav všech pluginů
            try:
                with open(STATUS_FILE, "r") as f:
                    status = json.load(f)
            except:
                status = {}
            self._set_headers()
            self.wfile.write(json.dumps(status).encode('utf-8'))

        elif self.path.startswith("/run/"):
            # Spustí konkrétní plugin, např. /run/plugin_ai_workspace/start
            parts = self.path.strip("/").split("/")
            if len(parts) == 3:
                _, plugin_name, action = parts
                result = self._run_plugin(plugin_name, action)
                self._set_headers()
                self.wfile.write(json.dumps(result).encode('utf-8'))
            else:
                self._set_headers(400)
                self.wfile.write(json.dumps({"error": "Špatná syntaxe"}).encode('utf-8'))

        elif self.path == "/logs":
            # Vrátí obsah logu
            try:
                with open(LOG_FILE, "r") as f:
                    log_data = f.read()
            except:
                log_data = "Log file neexistuje."
            self._set_headers(content_type="text/plain")
            self.wfile.write(log_data.encode('utf-8'))

        else:
            self._set_headers(404)
            self.wfile.write(json.dumps({"error": "Neznámá cesta"}).encode('utf-8'))

    def do_POST(self):
        self._set_headers(405)
        self.wfile.write(json.dumps({"error": "POST není podporováno"}).encode('utf-8'))

def run(server_class=HTTPServer, handler_class=Handler):
    server_address = ('', PORT)
    httpd = server_class(server_address, handler_class)
    print(f"🤖 AI Workspace server běží na portu {PORT}...")
    httpd.serve_forever()

if __name__ == "__main__":
    run()
