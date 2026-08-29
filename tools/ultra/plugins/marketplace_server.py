from flask import Flask, jsonify
import json

app = Flask(__name__)

@app.route("/plugins")
def plugins():
    with open("plugins/marketplace.json") as f:
        return jsonify(json.load(f))

app.run(host="0.0.0.0", port=8787)
