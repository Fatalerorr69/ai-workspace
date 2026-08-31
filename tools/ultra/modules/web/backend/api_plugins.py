from flask import Blueprint
import json

plugin_api = Blueprint("plugins", __name__)

@plugin_api.route("/list")
def list_plugins():
    with open("registry/plugin_marketplace.json") as f:
        return json.load(f)
