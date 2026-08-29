import jwt, datetime
from flask import request, jsonify
from functools import wraps

SECRET = "ULTRA_SUPER_SECRET"
ALGO = "HS256"

def generate_token():
    payload = {
        "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=8),
        "iat": datetime.datetime.utcnow()
    }
    return jwt.encode(payload, SECRET, algorithm=ALGO)

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get("Authorization")
        if not token:
            return jsonify({"error":"Missing token"}), 401
        try:
            jwt.decode(token, SECRET, algorithms=[ALGO])
        except:
            return jsonify({"error":"Invalid token"}), 401
        return f(*args, **kwargs)
    return decorated
