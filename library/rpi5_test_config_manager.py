"""
Unit testy pro ConfigManager

Testuje správu a validaci konfigurací.
"""

import unittest
import tempfile
import json
import yaml
from pathlib import Path
from src.python.config_manager import ConfigManager


class TestConfigManager(unittest.TestCase):
    """Testy pro ConfigManager třídu"""
    
    def setUp(self):
        """Příprava - vytvoření temp adresáře s konfiguracemi"""
        self.temp_dir = tempfile.TemporaryDirectory()
        self.config_dir = self.temp_dir.name
        self.cm = ConfigManager(self.config_dir)
    
    def tearDown(self):
        """Čistka"""
        self.temp_dir.cleanup()
    
    def _create_test_config(self, filename: str, data: dict) -> str:
        """Pomocná metoda pro vytvoření testovacího YAML souboru"""
        filepath = Path(self.config_dir) / filename
        with open(filepath, 'w') as f:
            yaml.dump(data, f)
        return str(filepath)
    
    def test_load_config(self):
        """Test načtení konfigurace"""
        test_config = {
            'system': {'name': 'Test'},
            'network': {'hostname': 'test-host'},
            'security': {'ssh_port': 2222},
            'education': {'projects_path': '/projects'},
            'monitoring': {'enabled': True}
        }
        
        self._create_test_config('test.yaml', test_config)
        config = self.cm.load_config('test.yaml')
        
        self.assertIsNotNone(config)
        self.assertEqual(config['system']['name'], 'Test')
    
    def test_get_value(self):
        """Test získání hodnoty z konfigurace"""
        test_config = {
            'system': {'name': 'TestSystem'},
            'network': {'hostname': 'rpi-host', 'ip': '192.168.1.100'},
            'security': {},
            'education': {},
            'monitoring': {}
        }
        
        self._create_test_config('config.yaml', test_config)
        self.cm.load_config('config.yaml')
        
        # Testování vnořených klíčů
        self.assertEqual(self.cm.get('system.name'), 'TestSystem')
        self.assertEqual(self.cm.get('network.hostname'), 'rpi-host')
        self.assertEqual(self.cm.get('network.ip'), '192.168.1.100')
    
    def test_get_default_value(self):
        """Test výchozí hodnoty když klíč neexistuje"""
        test_config = {
            'system': {},
            'network': {},
            'security': {},
            'education': {},
            'monitoring': {}
        }
        
        self._create_test_config('config.yaml', test_config)
        self.cm.load_config('config.yaml')
        
        value = self.cm.get('nonexistent.key', default='default_value')
        self.assertEqual(value, 'default_value')
    
    def test_set_value(self):
        """Test nastavení hodnoty"""
        test_config = {
            'system': {},
            'network': {},
            'security': {},
            'education': {},
            'monitoring': {}
        }
        
        self._create_test_config('config.yaml', test_config)
        self.cm.load_config('config.yaml')
        
        self.cm.set('network.hostname', 'new-hostname')
        self.assertEqual(self.cm.get('network.hostname'), 'new-hostname')
    
    def test_save_config(self):
        """Test uložení konfigurace"""
        test_config = {
            'system': {'name': 'SaveTest'},
            'network': {},
            'security': {},
            'education': {},
            'monitoring': {}
        }
        
        self._create_test_config('original.yaml', test_config)
        self.cm.load_config('original.yaml')
        
        # Úprava a uložení
        self.cm.set('system.name', 'ModifiedName')
        success = self.cm.save_config('modified.yaml')
        
        self.assertTrue(success)
        
        # Načtení a ověření
        self.cm2 = ConfigManager(self.config_dir)
        config2 = self.cm2.load_config('modified.yaml')
        self.assertEqual(config2['system']['name'], 'ModifiedName')
    
    def test_missing_required_sections_warning(self):
        """Test varování při chybějících povinných sekcích"""
        incomplete_config = {
            'system': {'name': 'Test'}
            # Chybí ostatní sekce
        }
        
        self._create_test_config('incomplete.yaml', incomplete_config)
        config = self.cm.load_config('incomplete.yaml')
        
        # Konfigurace se má načíst, ale s varováním
        self.assertIsNotNone(config)


if __name__ == '__main__':
    unittest.main()
