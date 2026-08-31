from core.services import manager
import os

python_path = os.path.join(os.environ.get("PREFIX", "/data/data/com.termux/files/usr"), "bin", "python")
dashboard_script = os.path.expanduser("~/STARCORE/dashboard/main.py")
command = f"{python_path} {dashboard_script}"

manager.register(
    name="dashboard",
    command=command,
    description="STARCORE Web Dashboard (FastAPI)",
    auto_restart=True
)
print(f"✅ Dashboard registrován: {command}")
