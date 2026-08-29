# Příspívání do Nymea:Kiosk Ultimate System

Děkujeme za zájem přispívat do projektu! 🎉

## 📋 Obsah

- [Code of Conduct](#code-of-conduct)
- [Jak začít](#jak-začít)
- [Postup pro přispívání](#postup-pro-přispívání)
- [Style Guides](#style-guides)
- [Testování](#testování)
- [Merge Request proces](#merge-request-proces)

## Code of Conduct

Buďte respektující vůči ostatním. Všichni přispěvatelé jsou vítáni bez ohledu na:
- Věk, pohlaví, identitu
- Zkušenosti a znalosti
- Původ, národnost
- Sexuální orientaci
- Handicap nebo fyzické schopnosti

## Jak začít

### 1. Nastavte vývojové prostředí

```bash
# Fork a klonujte
git clone https://github.com/YOUR_USERNAME/nymeakiosk-ultimate-system.git
cd nymeakiosk-ultimate-system

# Přidejte upstream
git remote add upstream https://github.com/Fatalerorr69/nymeakiosk-ultimate-system.git

# Vytvořte virtuální prostředí
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# nebo
venv\Scripts\activate  # Windows

# Instalujte závislosti
pip install -r requirements.txt
pip install -e ".[dev]"
```

### 2. Seznamte se s projektem

- Přečtěte [README.md](../README.md)
- Přečtěte [docs/DOCUMENTATION.md](DOCUMENTATION.md)
- Prohlédněte existující [Issues](https://github.com/Fatalerorr69/nymeakiosk-ultimate-system/issues)

## Postup pro přispívání

### Malé opravy (typo, dokumentace)

```bash
# Vytvořte branch
git checkout -b fix/typo-in-readme

# Udělejte změny
# Commitujte
git commit -m "docs: fix typo in README.md"

# Push a otevřete PR
git push origin fix/typo-in-readme
```

### Nové vlastnosti

```bash
# 1. Otevřete Issue nejdřív
# Diskutujte o návrhu s maintainers

# 2. Vytvořte feature branch
git checkout -b feature/new-dashboard-widget

# 3. Implementujte
# Píšejte testy!

# 4. Push a PR
git push origin feature/new-dashboard-widget
```

### Bug fix

```bash
# 1. Nahlaste issue s repro kroky
# 2. Vytvořte bugfix branch
git checkout -b fix/kiosk-crash-on-startup

# 3. Opravte s testem (zvýraznit regresi)
# 4. PR s odkazem na issue
```

## Style Guides

### Python kod

```python
# ✓ DOBRÉ
from src.python.project_manager import ProjectManager

def create_student_project(name: str, description: str) -> dict:
    """
    Vytvoří nový studentský projekt.
    
    Args:
        name: Název projektu
        description: Popis
    
    Returns:
        Slovník s daty projektu
    
    Raises:
        ValueError: Pokud projekt již existuje
    """
    pm = ProjectManager()
    return pm.create_project(name, description, [], "1 week")

# ✗ ŠPATNĚ
def createStudentProject(name,description):
    # Vytvoření projektu
    pm = ProjectManager()
    return pm.create_project(name, description, [], "1 week")
```

**Pravidla:**
- Použijte `snake_case` pro funkce a proměnné
- Používejte type hints
- Napište docstrings (Google style)
- Max 100 znaků na řádek
- Importy: stdlib, third-party, local

### Shell skripty

```bash
#!/bin/bash
################################################################################
# Krátký popis
# Verze: 1.0
################################################################################

set -euo pipefail

readonly LOG_FILE="/var/log/nymea-kiosk/script.log"

# Funkce
log_info() {
    echo "[INFO] $@"
}

log_error() {
    echo "[ERROR] $@" >&2
}

# Hlavní kód
main() {
    log_info "Spouštím..."
}

main "$@"
```

**Pravidla:**
- `set -euo pipefail` na začátku
- Jednotný logging (log_info, log_error, log_warn)
- Třídění a komentáře
- Testujte s `shellcheck`

### Commitové zprávy

```bash
# Format: <type>(<scope>): <subject>
# <body>
# <footer>

# Příklady:

git commit -m "feat(project-manager): add export to JSON"
git commit -m "fix(kiosk): prevent display freeze on startup"
git commit -m "docs(README): improve installation section"
git commit -m "test(config-manager): add validation tests"
git commit -m "refactor(logging): consolidate logger setup"

# Type: feat, fix, docs, style, refactor, perf, test, chore
# Scope: komponenta, která je ovlivněna
# Subject: imperativ, lowercase, bez tečky na konci
```

## Testování

### Spouštění testů

```bash
# Všechny testy
pytest

# Konkrétní test
pytest tests/unit/test_project_manager.py

# S coverage
pytest --cov=src --cov-report=html

# Shellcheck
shellcheck src/scripts/*.sh
```

### Psaní testů

```python
# tests/unit/test_my_feature.py
import unittest
from src.python.my_module import MyClass

class TestMyFeature(unittest.TestCase):
    """Testy pro novou vlastnost"""
    
    def setUp(self):
        """Příprava testu"""
        self.obj = MyClass()
    
    def test_happy_path(self):
        """Test normálního případu"""
        result = self.obj.do_something()
        self.assertEqual(result, expected_value)
    
    def test_error_handling(self):
        """Test error handlingu"""
        with self.assertRaises(ValueError):
            self.obj.do_invalid_operation()
    
    def tearDown(self):
        """Čistka"""
        pass

if __name__ == '__main__':
    unittest.main()
```

## Merge Request proces

### Příprava PR

1. **Aktualizujte upstream**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Push do vaší fork**
   ```bash
   git push origin feature/my-feature
   ```

3. **Otevřete PR** na GitHubu
   - Jasný název
   - Popis (co a proč)
   - Reference na issue (`Closes #123`)
   - Screenshots (pokud relevantní)

### PR Template

```markdown
## Popis
Krátký popis změny

## Type změny
- [ ] Bug fix
- [ ] Nová vlastnost
- [ ] Breaking change
- [ ] Dokumentace

## Jak otestovat?
1. ...
2. ...

## Checklist
- [ ] Moje kód respektuje style guides
- [ ] Spustil jsem `pytest` a vše prošlo
- [ ] Spustil jsem `shellcheck` na .sh soubory
- [ ] Přidal jsem testy
- [ ] Aktualizoval jsem dokumentaci
- [ ] Commit zprávy jsou čisté
```

### Review proces

Běžně bude váš PR zkontrolován:
- **Automaticky:**
  - Syntax & linting check
  - Unit tests
  - Code coverage

- **Ručně:**
  - Code review od maintainera
  - Otázky či požadavky na změny
  - Schválení či odmítnutí

### Slučování

Jakmile je PR schválen:
1. Rebase na main
2. Squash malých commitů (pokud relevantní)
3. Maintainer sloučí PR

## FAQ

**Q: Jak doporučuji novou vlastnost?**  
A: Otevřete Issue s `[FEATURE REQUEST]` ve jménu

**Q: Jak nahlašuji bug?**  
A: Otevřete Issue s `[BUG]`, včetně repro kroků

**Q: Jak se podívám na to, na čem se pracuje?**  
A: Podívejte se na [Projects](https://github.com/Fatalerorr69/nymeakiosk-ultimate-system/projects)

**Q: Jak se stanu maintainerem?**  
A: Dlouhodobé aktivní přispívání + schválení

## Užitečné odkazy

- [GitHub Issues](https://github.com/Fatalerorr69/nymeakiosk-ultimate-system/issues)
- [GitHub Discussions](https://github.com/Fatalerorr69/nymeakiosk-ultimate-system/discussions)
- [Dokumentace](./DOCUMENTATION.md)
- [Copilot Instructions](./.github/copilot-instructions.md)

---

Děkujeme za přispívání! ❤️

Máte otázky? Zeptejte se v [Discussions](https://github.com/Fatalerorr69/nymeakiosk-ultimate-system/discussions)!
