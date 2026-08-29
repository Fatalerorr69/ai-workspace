# ❓ FAQ - Často Kladené Otázky

## 📋 Obsah
- [Obecné](#obecné)
- [Instalace](#instalace)
- [Používání](#používání)
- [Windows Specifické](#windows-specifické)
- [Linux Specifické](#linux-specifické)
- [Android Specifické](#android-specifické)
- [Troubleshooting](#troubleshooting)
- [Bezpečnost](#bezpečnost)

---

## 🌐 Obecné

### Q: Co je SuperNastroj?
**A:** SuperNastroj je multi-platformní systémový nástroj pro diagnostiku, opravu a optimalizaci systémů Windows, Linux a Android/Termux.

### Q: Je SuperNastroj zdarma?
**A:** Ano! SuperNastroj je 100% zdarma a open-source pod MIT licencí.

### Q: Jaké platformy jsou podporovány?
**A:** 
- ✅ Windows 7/8/10/11
- ✅ Linux (Debian, Ubuntu, Fedora, Arch, atd.)
- ✅ Android/Termux (7.0+)
- ✅ macOS (experimentální)
- ✅ BSD systémy (FreeBSD, OpenBSD)

### Q: Potřebuji internetové připojení?
**A:** 
- **Ne** pro většinu funkcí
- **Ano** pro:
  - Stahování ISO souborů
  - Kontrolu aktualizací
  - Některé síťové testy
  - Instalaci závislostí

### Q: Je SuperNastroj bezpečný?
**A:** Ano! Je open-source, můžete zkontrolovat kód. Dodržujeme bezpečnostní best practices.

---

## 💿 Instalace

### Q: Jak nainstalovat na Windows?
**A:**
```cmd
1. Stáhnout SuperNastroj_Complete.bat
2. Uložit do složky
3. Pravý klik → "Spustit jako správce"
```

### Q: Jak nainstalovat na Linux?
**A:**
```bash
git clone https://github.com/Fatalerorr69/SuperNastroj.git
cd SuperNastroj
chmod +x *.sh
sudo ./SuperNastroj_launcher.sh
```

### Q: Jak nainstalovat na Android?
**A:**
```bash
# V Termux:
pkg install git
git clone https://github.com/Fatalerorr69/SuperNastroj.git
cd SuperNastroj
chmod +x SuperNastroj_android.sh
./SuperNastroj_android.sh
```

### Q: Jaké jsou systémové požadavky?
**A:**
| Platform | Minimum | Doporučeno |
|----------|---------|------------|
| Windows  | 2GB RAM, 1GB disk | 4GB RAM, 2GB disk |
| Linux    | 1GB RAM, 500MB disk | 2GB RAM, 1GB disk |
| Android  | 1GB RAM, 500MB storage | 2GB RAM, 1GB storage |

---

## 🎮 Používání

### Q: Jak provést rychlou opravu systému?
**A:** Spusťte nástroj a vyberte volbu [1] "Rychlá oprava systému".

### Q: Jak vytvořit záchranné USB?
**A:** Windows: Volba [4] → [1] "Windows Repair USB"

### Q: Jak zálohovat data?
**A:** Volba [7] → [3] "Vytvořit zálohu"

### Q: Kde najdu logy?
**A:** Ve složce `SuperNastroj_Logs/`:
- `system.log` - Všechny operace
- `errors.log` - Pouze chyby
- `network.log` - Síťové operace

### Q: Jak často bych měl spouštět diagnostiku?
**A:** 
- **Pravidelně:** Měsíčně
- **Při problémech:** Okamžitě
- **Po aktualizacích:** Pro kontrolu

### Q: Mohu používat více funkcí současně?
**A:** Ne, funkce se spouští sekvenčně. Počkejte na dokončení aktuální operace.

---

## 🖥️ Windows Specifické

### Q: Proč potřebuji admin práva?
**A:** Mnoho funkcí (SFC, DISM, CHKDSK) vyžaduje administrátorská práva pro přístup k systémovým souborům.

### Q: "PowerShell není povolen" - co dělat?
**A:**
```powershell
# Otevřete PowerShell jako admin:
Set-ExecutionPolicy RemoteSigned -Force
```

### Q: Antivirus blokuje SuperNastroj?
**A:** 
1. Přidejte složku SuperNastroj do výjimek
2. Je to falešný poplach (false positive)
3. Můžete zkontrolovat kód - je open-source

### Q: Jak dlouho trvá rychlá oprava?
**A:** Obvykle 15-30 minut, závisí na stavu systému.

### Q: Mohu přerušit běžící operaci?
**A:** Ano, pomocí Ctrl+C, ale může to zanechat systém v nestabilním stavu.

### Q: Podporuje Windows 7?
**A:** Ano, ale některé funkce mohou být omezené (např. DISM).

---

## 🐧 Linux Specifické

### Q: Potřebuji root práva?
**A:** Ano, pro většinu funkcí. Spouštějte s `sudo`.

### Q: "Command not found" - co dělat?
**A:**
```bash
# Nainstalujte závislosti:
# Debian/Ubuntu:
sudo apt install nmap curl wget

# Fedora:
sudo dnf install nmap curl wget

# Arch:
sudo pacman -S nmap curl wget
```

### Q: Funguje na WSL?
**A:** Ano! WSL (Windows Subsystem for Linux) je podporován.

### Q: Které distribuce jsou podporovány?
**A:** Většina hlavních distribucí:
- Debian/Ubuntu
- Fedora/RHEL/CentOS
- Arch Linux
- Debian deriváty (Mint, Pop!_OS)

### Q: Mohu použít bez sudo?
**A:** Některé základní funkce ano, ale diagnostika a opravy vyžadují root.

---

## 📱 Android Specifické

### Q: Proč používat F-Droid Termux?
**A:** Google Play verze Termuxu je zastaralá a neaktualizovaná. F-Droid má nejnovější verzi.

### Q: Jak povolit úložiště?
**A:**
```bash
termux-setup-storage
# Pak povolte v Android dialogu
```

### Q: "Package not found" chyba?
**A:**
```bash
pkg update
termux-change-repo  # Změňte mirror
pkg install <package>
```

### Q: Potřebuji root?
**A:** Ne! SuperNastroj funguje bez root práv.

### Q: Funguje na tabletu?
**A:** Ano, pokud má Android 7.0+ a Termux.

### Q: Spotřebovává hodně baterie?
**A:** Závisí na funkci. Síťové skenování a diagnostika ano, základní použití ne.

---

## 🔧 Troubleshooting

### Q: "Přístup odepřen" error?
**A:**
- **Windows:** Spusťte jako správce
- **Linux:** Použijte `sudo`
- **Android:** Zkontrolujte oprávnění

### Q: Nástroj se nespustí?
**A:**
1. Zkontrolujte oprávnění: `chmod +x *.sh`
2. Zkontrolujte závislosti
3. Podívejte se do `errors.log`
4. Zkontrolujte cestu ke skriptu

### Q: Funkce nefunguje?
**A:**
1. Zkontrolujte logy v `SuperNastroj_Logs/`
2. Ujistěte se, že máte admin/root práva
3. Zkontrolujte internetové připojení (pokud je potřeba)
4. Nahlaste bug na GitHubu

### Q: Jak obnovit po chybné operaci?
**A:**
- Windows: Použijte bod obnovy
- Linux: Obnovte ze zálohy
- Android: Reinstalujte Termux balíčky

### Q: Logy jsou příliš velké?
**A:** Automaticky se rotují. Můžete ručně smazat staré logy v `SuperNastroj_Logs/`.

---

## 🔒 Bezpečnost

### Q: Je bezpečné provádět systémové změny?
**A:** Ano, pokud:
- ✅ Máte zálohu
- ✅ Rozumíte co děláte
- ✅ Používáte nejnovější verzi
- ❌ NENÍ pro produkční servery bez testování

### Q: Ukládají se moje hesla?
**A:** **NE!** SuperNastroj nikdy neukládá hesla nebo citlivá data.

### Q: Co se loguje?
**A:** 
- ✅ Systémové operace
- ✅ Chyby
- ✅ Síťové operace
- ❌ Hesla
- ❌ Osobní data

### Q: Může SuperNastroj poškodit můj systém?
**A:** Při správném použití ne. Ale jako každý systémový nástroj:
- ⚠️ Vždy zálohujte před větším zásahem
- ⚠️ Čtěte co nástroj dělá
- ⚠️ Testujte nejdřív na testovacím systému

### Q: Jak mohu ověřit integritu souborů?
**A:** Kontrolujte SHA256 hash na GitHubu nebo kompilujte ze zdrojového kódu.

---

## 🔄 Aktualizace

### Q: Jak aktualizovat?
**A:**
```bash
cd SuperNastroj
git pull origin main
```
Nebo stáhněte nejnovější verzi z GitHubu.

### Q: Jak často vycházejí aktualizace?
**A:** 
- **Major updates:** Čtvrtletně
- **Minor updates:** Měsíčně
- **Hotfixes:** Podle potřeby

### Q: Automatické aktualizace?
**A:** V `config.ini` nastavte:
```ini
[General]
AutoUpdate=true
CheckUpdatesOnStart=true
```

---

## 💡 Tipy & Triky

### Q: Jak zrychlit diagnostiku?
**A:** V `config.ini`:
```ini
[Performance]
ParallelTasks=8  # Více paralelních úloh
```

### Q: Jak snížit velikost logů?
**A:**
```ini
[Logging]
LogLevel=ERROR  # Pouze chyby
MaxLogSize=5242880  # 5MB limit
```

### Q: Jak vytvořit vlastní konfiguraci?
**A:** Vytvořte `config_local.ini` - přepíše defaultní `config.ini`.

---

## 🆘 Další Pomoc

### Nenašli jste odpověď?

- 🐛 [GitHub Issues](https://github.com/Fatalerorr69/SuperNastroj/issues)
- 💬 [GitHub Discussions](https://github.com/Fatalerorr69/SuperNastroj/discussions)
- 📖 [Dokumentace](https://github.com/Fatalerorr69/SuperNastroj/wiki)
- 📧 Email: (bude doplněno)

### Před Dotazem:
1. ✅ Přečtěte tuto FAQ
2. ✅ Zkontrolujte dokumentaci
3. ✅ Prohledejte existující issues
4. ✅ Zkontrolujte logy

---

**Poslední aktualizace:** 1. prosince 2024  
**Verze FAQ:** 1.0.0

*Máte návrh na další otázku? Vytvořte issue nebo PR!*
