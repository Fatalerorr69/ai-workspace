from flask import Blueprint
import subprocess

ai_api = Blueprint("ai", __name__)

@ai_api.route("/analyze")
def analyze():
    out = subprocess.check_output(
        ["python3", "core/ai_recommender.py", "full"]
    )
    return {"analysis": out.decode()}
