"""
Konfigurace systému - System Configuration Manager

Modul pro správu YAML konfigurací, validaci a aplikaci nastavení.
"""

import yaml
import logging
import os
from typing import Dict, Any, Optional
from pathlib import Path


class ConfigManager:
    """
    Správce konfigurace systému.
    
    Spravuje načítání, validaci a uplaňování YAML konfigurací.
    
    Attributes:
        config_dir (Path): Adresář s konfiguracemi
        logger (logging.Logger): Logger pro auditování
        config (Dict): Načtená konfigurace
    """
    
    REQUIRED_SECTIONS = [
        'system', 'network', 'security', 'education', 'monitoring'
    ]
    
    def __init__(self, config_dir: str = "/app/config"):
        """
        Inicializace správce konfigurace.
        
        Args:
            config_dir: Cesta k adresáři s konfiguracemi
        """
        self.config_dir = Path(config_dir)
        self.logger = self._setup_logging()
        self.config: Dict[str, Any] = {}
    
    def _setup_logging(self) -> logging.Logger:
        """Nastavení loggingu"""
        logger = logging.getLogger("ConfigManager")
        handler = logging.StreamHandler()
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        logger.setLevel(logging.INFO)
        return logger
    
    def load_config(self, filename: str) -> Optional[Dict[str, Any]]:
        """
        Načtení konfigurace z YAML souboru.
        
        Args:
            filename: Jméno souboru (např. 'main-config.yaml')
        
        Returns:
            Slovník s konfigurací nebo None
        """
        config_path = self.config_dir / filename
        
        if not config_path.exists():
            self.logger.error(f"Konfigurační soubor '{config_path}' neexistuje")
            return None
        
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                config = yaml.safe_load(f)
            
            if self._validate_config(config):
                self.config = config
                self.logger.info(f"Konfigurace '{filename}' úspěšně načtena")
                return config
            else:
                self.logger.error(f"Konfigurace '{filename}' není validní")
                return None
        
        except yaml.YAMLError as e:
            self.logger.error(f"Chyba při parsování YAML: {e}")
            return None
        except IOError as e:
            self.logger.error(f"Chyba při čtení souboru: {e}")
            return None
    
    def _validate_config(self, config: Dict[str, Any]) -> bool:
        """
        Validace konfigurace.
        
        Args:
            config: Konfigurace k validaci
        
        Returns:
            True pokud je konfigurace validní
        """
        if not isinstance(config, dict):
            self.logger.error("Konfigurace musí být slovník")
            return False
        
        missing_sections = [
            s for s in self.REQUIRED_SECTIONS 
            if s not in config
        ]
        
        if missing_sections:
            self.logger.warning(
                f"Chybějící povinné sekce: {', '.join(missing_sections)}"
            )
        
        return True
    
    def get(self, key: str, default: Any = None) -> Any:
        """
        Získání hodnoty z konfigurace (s support pro vnořené klíče).
        
        Args:
            key: Klíč (např. 'network.hostname')
            default: Výchozí hodnota
        
        Returns:
            Hodnota z konfigurace
        """
        keys = key.split('.')
        value = self.config
        
        for k in keys:
            if isinstance(value, dict):
                value = value.get(k)
            else:
                return default
        
        return value if value is not None else default
    
    def set(self, key: str, value: Any) -> bool:
        """
        Nastavení hodnoty v konfiguraci.
        
        Args:
            key: Klíč (např. 'network.hostname')
            value: Nová hodnota
        
        Returns:
            True pokud bylo nastavení úspěšné
        """
        keys = key.split('.')
        config = self.config
        
        for k in keys[:-1]:
            if k not in config:
                config[k] = {}
            config = config[k]
        
        config[keys[-1]] = value
        self.logger.info(f"Konfigurace '{key}' nastavena na '{value}'")
        return True
    
    def save_config(self, filename: str) -> bool:
        """
        Uložení konfigurace do YAML souboru.
        
        Args:
            filename: Jméno souboru
        
        Returns:
            True pokud bylo uložení úspěšné
        """
        config_path = self.config_dir / filename
        
        try:
            self.config_dir.mkdir(parents=True, exist_ok=True)
            with open(config_path, 'w', encoding='utf-8') as f:
                yaml.dump(self.config, f, default_flow_style=False, 
                         allow_unicode=True)
            self.logger.info(f"Konfigurace uložena do '{config_path}'")
            return True
        except IOError as e:
            self.logger.error(f"Chyba při zápisu konfigurace: {e}")
            return False
    
    def get_all(self) -> Dict[str, Any]:
        """Získání všech konfigurací"""
        return self.config.copy()
