import subprocess

def run(cmd):
    return subprocess.getoutput(cmd)

def pools():
    return run("zpool list -H -o name,size,health").splitlines()

def datasets():
    return run("zfs list -H -o name,used,avail").splitlines()

def create_dataset(name):
    run(f"zfs create {name}")

def destroy_dataset(name):
    run(f"zfs destroy {name}")
