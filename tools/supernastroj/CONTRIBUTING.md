# Contributing to SuperNastroj

Děkujeme za váš zájem přispět do projektu SuperNastroj! 🎉

## 📋 Obsah
- [Code of Conduct](#code-of-conduct)
- [Jak přispět](#jak-přispět)
- [Reporting Bugs](#reporting-bugs)
- [Feature Requests](#feature-requests)
- [Pull Requests](#pull-requests)
- [Coding Standards](#coding-standards)
- [Testing](#testing)

---

## 🤝 Code of Conduct

Tento projekt dodržuje [Contributor Covenant](CODE_OF_CONDUCT.md). 
Účastí v tomto projektu souhlasíte s dodržováním jeho pravidel.

---

## 🚀 Jak Přispět

### 1. Fork Repository
```bash
# Fork na GitHubu, potom:
git clone https://github.com/YOUR_USERNAME/SuperNastroj.git
cd SuperNastroj
```

### 2. Vytvořte Branch
```bash
# Pro novou funkci:
git checkout -b feature/amazing-feature

# Pro opravu bugu:
git checkout -b fix/bug-description

# Pro dokumentaci:
git checkout -b docs/improve-readme
```

### 3. Proveďte Změny
- Napište čistý, čitelný kód
- Dodržujte coding standards (viz níže)
- Přidejte testy pokud je to možné
- Aktualizujte dokumentaci

### 4. Commit
```bash
git add .
git commit -m "feat: Add amazing feature"
```

**Commit Message Convention:**
```
feat: nová funkce
fix: oprava bugu
docs: dokumentace
style: formátování
refactor: refactoring kódu
test: přidání testů
chore: údržba
```

### 5. Push & Pull Request
```bash
git push origin feature/amazing-feature
```

Vytvořte Pull Request na GitHubu s:
- Popisem změn
- Důvodem změn
- Screenshots (pokud jsou relevantní)

---

## 🐛 Reporting Bugs

### Před Nahlášením
1. Zkontrolujte [existující issues](https://github.com/Fatalerorr69/SuperNastroj/issues)
2. Ujistěte se, že používáte nejnovější verzi
3. Zkuste reprodukovat bug

### Jak Nahlásit
Vytvořte issue s:
- **Název:** Krátký popisný název
- **Popis:** Detailní popis problému
- **Kroky k reprodukci:**
  1. První krok
  2. Druhý krok
  3. ...
- **Očekávané chování:** Co mělo být
- **Aktuální chování:** Co se stalo
- **Prostředí:**
  - OS: Windows 10/11, Linux (distribuce), Android
  - Verze SuperNastroj: 5.0.0
  - Další relevantní info

**Šablona:**
```markdown
## Bug Report

**Popis:**
[Popis problému]

**Kroky k reprodukci:**
1. Spustit SuperNastroj
2. Vybrat volbu X
3. ...

**Očekávané chování:**
[Co mělo být]

**Aktuální chování:**
[Co se stalo]

**Prostředí:**
- OS: Windows 11
- Verze: 5.0.0
- Admin práva: Ano

**Logy:**
```
[Připojte relevantní logy]
```

**Screenshots:**
[Pokud je relevantní]
```

---

## ✨ Feature Requests

### Jak Navrhnout Novou Funkci
1. Zkontrolujte [existující issues](https://github.com/Fatalerorr69/SuperNastroj/issues)
2. Ujistěte se, že funkce již neexistuje
3. Vytvořte issue s:
   - Popisem funkce
   - Use case (jak by se používala)
   - Příklady (pokud možné)
   - Mockups/wireframes (volitelné)

**Šablona:**
```markdown
## Feature Request

**Je tato funkce související s problémem?**
[Ano/Ne, popište]

**Navrhované řešení:**
[Jak by funkce měla fungovat]

**Alternativy:**
[Další možnosti, které jste zvažovali]

**Use Case:**
[Jak byste funkci používali]

**Dodatečný kontext:**
[Screenshots, mockups, odkazy]
```

---

## 🔄 Pull Requests

### Checklist
Před odesláním PR zkontrolujte:

- [ ] Kód je čistý a čitelný
- [ ] Dodrženy coding standards
- [ ] Přidány/aktualizovány testy
- [ ] Aktualizována dokumentace
- [ ] Aktualizován CHANGELOG.md
- [ ] Všechny testy procházejí
- [ ] Žádné konflikty s main branchí
- [ ] Commit messages jsou ve správném formátu

### PR Template
```markdown
## Popis
[Co tento PR dělá]

## Typ změny
- [ ] Bug fix
- [ ] Nová funkce
- [ ] Breaking change
- [ ] Dokumentace

## Testing
[Jak jste to testovali]

## Screenshots
[Pokud je relevantní]

## Checklist
- [ ] Kód odpovídá style guidelines
- [ ] Self-review proveden
- [ ] Dokumentace aktualizována
- [ ] Žádné nové warnings
- [ ] Testy přidány/aktualizovány
```

---

## 📝 Coding Standards

### General
- Používejte smysluplné názvy proměnných
- Komentujte složitý kód
- Držte funkce krátké a focused
- Vyhněte se duplicitnímu kódu

### Windows (.bat)
```batch
:: Komentáře začínají ::
:: Používejte mezery kolem operátorů

@echo off
setlocal EnableDelayedExpansion

:: Proměnné velkými písmeny
set "VARIABLE_NAME=value"

:: Funkce s jasným názvem
:FunctionName
echo Doing something
goto :eof
```

### Linux/Android (.sh)
```bash
#!/bin/bash
# Komentáře začínají #

# Proměnné lowercase s underscore
variable_name="value"

# Konstanty uppercase
readonly CONSTANT_NAME="value"

# Funkce snake_case
function_name() {
    local local_var="value"
    echo "Doing something"
}

# Error handling
if [ $? -ne 0 ]; then
    echo "Error occurred"
    return 1
fi
```

### Dokumentace
```markdown
# Používejte jasné nadpisy
## Podnadpisy pro sekce
### Sub-sekce

- Bullet points pro seznamy
1. Číslované seznamy pro kroky

**Bold** pro důležité
*Italic* pro emphasis
`code` pro inline code

\```language
code block
\```
```

---

## 🧪 Testing

### Manuální Testing
Před odesláním PR otestujte:

**Windows:**
```cmd
SuperNastroj_Complete.bat
# Projděte všechny menu volby
# Zkontrolujte logy
```

**Linux:**
```bash
sudo ./SuperNastroj_linux.sh
# Otestujte všechny funkce
# Zkontrolujte permissions
```

**Android:**
```bash
./SuperNastroj_android.sh
# Otestujte Termux specifické funkce
# Zkontrolujte API calls
```

### Automated Testing
(Připravujeme test suite)

```bash
# Spustit všechny testy
./run_tests.sh

# Konkrétní platformu
./tests/test_windows.bat
./tests/test_linux.sh
./tests/test_android.sh
```

---

## 📚 Další Zdroje

- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

## ❓ Máte Otázky?

- 💬 [GitHub Discussions](https://github.com/Fatalerorr69/SuperNastroj/discussions)
- 🐛 [GitHub Issues](https://github.com/Fatalerorr69/SuperNastroj/issues)
- 📧 Email: (bude doplněno)

---

## 🙏 Poděkování

Děkujeme všem přispěvatelům, kteří pomáhají SuperNastroj být lepší!

---

**Happy Coding!** 🚀
