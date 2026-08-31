import logging
from core.config import settings

def setup_logger():
    logger = logging.getLogger("starcore")
    logger.setLevel(logging.INFO)
    fh = logging.FileHandler(settings.LOG_DIR / "starcore.log")
    fh.setFormatter(logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s"))
    logger.addHandler(fh)
    return logger

logger = setup_logger()
