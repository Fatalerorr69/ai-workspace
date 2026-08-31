def list():
    return open("/etc/samba/smb.conf").read()

def reload():
    import subprocess
    subprocess.call(["systemctl", "restart", "smbd"])
