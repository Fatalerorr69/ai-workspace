"""
Utility funkce pro loggování a error handling

Standardní funkce pro konzistentní loggování v celém systému.
"""

import logging
import logging.handlers
import os
from pathlib import Path
from typing import Optional, Callable
from functools import wraps


class LoggerConfig:
    """Konfigurace systémového loggeru"""
    
    DEFAULT_LOG_DIR = "/var/log/nymea-kiosk"
    DEFAULT_LOG_FILE = "system.log"
    DEFAULT_FORMAT = (
        '%(asctime)s - %(name)s - [%(levelname)s] - %(funcName)s:%(lineno)d - %(message)s'
    )
    
    @staticmethod
    def setup_logger(
        name: str,
        log_file: Optional[str] = None,
        level: int = logging.INFO
    ) -> logging.Logger:
        """
        Nastavení loggeru se standardní konfigurací.
        
        Args:
            name: Jméno loggeru
            log_file: Cesta k log souboru (volitelné)
            level: Úroveň loggování
        
        Returns:
            Nakonfigurovaný logger
        """
        logger = logging.getLogger(name)
        logger.setLevel(level)
        
        # Prevence duplikátních handlersů
        if logger.handlers:
            return logger
        
        # Formátor
        formatter = logging.Formatter(LoggerConfig.DEFAULT_FORMAT)
        
        # Console handler
        console_handler = logging.StreamHandler()
        console_handler.setFormatter(formatter)
        logger.addHandler(console_handler)
        
        # File handler (pokud je zadán)
        if log_file:
            log_path = Path(log_file)
            log_path.parent.mkdir(parents=True, exist_ok=True)
            
            file_handler = logging.handlers.RotatingFileHandler(
                log_file,
                maxBytes=10*1024*1024,  # 10 MB
                backupCount=5
            )
            file_handler.setFormatter(formatter)
            logger.addHandler(file_handler)
        
        return logger


def log_execution(func: Callable) -> Callable:
    """
    Dekorátor pro automatické loggování spuštění funkcí.
    
    Logguje vstup, výstup a chyby.
    """
    @wraps(func)
    def wrapper(*args, **kwargs):
        logger = logging.getLogger(func.__module__)
        logger.info(f"Spuštění: {func.__name__}({args}, {kwargs})")
        
        try:
            result = func(*args, **kwargs)
            logger.info(f"Úspěch: {func.__name__} vrátil {type(result).__name__}")
            return result
        except Exception as e:
            logger.error(f"Chyba v {func.__name__}: {str(e)}", exc_info=True)
            raise
    
    return wrapper


def log_shell_command(command: str, logger: logging.Logger) -> None:
    """
    Loggování shell příkazu.
    
    Args:
        command: Příkaz k loggování
        logger: Logger instance
    """
    logger.info(f"Shell příkaz: {command}")


def log_config_change(
    key: str,
    old_value: str,
    new_value: str,
    logger: logging.Logger
) -> None:
    """
    Loggování změny konfigurace.
    
    Args:
        key: Klíč konfigurace
        old_value: Stará hodnota
        new_value: Nová hodnota
        logger: Logger instance
    """
    logger.info(f"Konfigurace změněna: '{key}' {old_value} → {new_value}")
