from flask import Flask, render_template, request, jsonify
import subprocess, os, json

app = Flask(__name__)
PLUGIN_DIR = "plugins/installed"
MARKET_FILE = os.path.join(os.getcwd(), "../plugins/marketplace.json")




@app.route("/install/<plugin>")
def install_plugin(plugin):
    url = f"https://github.com/Fatalerorr69/{plugin}/releases/latest/download/{plugin}.tar.gz"
    os.makedirs(f"{PLUGIN_DIR}/{plugin}", exist_ok=True)
    subprocess.Popen(os.path.join("curl -L {url} | tar xz -C {PLUGIN_DIR}/", os.path.basename(plugin))), shell=True)
    return jsonify({"status":"ok","plugin":plugin})

@app.route("/api/plugins")
def list_plugins():
    if os.path.exists(MARKET_FILE):
        with open(os.path.join("", os.path.basename(MARKET_FILE) as f:
            plugins = json.load(f)
        return jsonify(plugins)
    return jsonify([])))

if __name__ == "__main__":

app.run(host="0.0.0.0", port=8788)
