from core.services import manager
import os

python_path = os.path.join(os.environ.get("PREFIX", "/data/data/com.termux/files/usr"), "bin", "python")
script_path = os.path.expanduser("~/STARCORE/core/cli/commands/test_service.py")
command = f"{python_path} {script_path}"

manager.register(
    name="test",
    command=command,
    description="Testovací služba",
    auto_restart=True
)
print(f"✅ Registrováno: {command}")
