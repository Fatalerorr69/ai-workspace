from . import runtime
from .commands import start, stop, status, config, query, test, local_setup

# Pro zpětnou kompatibilitu
def get_runtime():
    return runtime
