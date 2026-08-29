# Hluboká analýza: starko-ultimate-recovery-usb

## Základní informace
- **Cílová cesta:** $targetPath
- **Detekované technologie:** PowerShell, Shell
- **Počet skriptů:** 9

## Popis z README
# Starko Ultimate Recovery USB – Kompletní Manuál (PRO Edition)

## 1. Úvod

Tento USB nástroj představuje komplexní profesionální řešení pro obnovu dat, diagnostiku hardwaru, opravy operačního systému, bezpečnostní a penetrační analýzy. Celé prostředí je založeno na WinPE x64 a obsahuje interaktivní menu pro rychlý přístup ke všem nástrojům.

Cílem je poskytnout kompletní servisní nástroj, který je připraven okamžitě řešit kritické problémy se systémy Windows, disky, hardwarem a sítěmi.

---

## 2. Obsah USB

```
L:\
│
├─ WinPE\
├─ Tools\
│   ├─ Recovery\
│   ├─ Diagnostics\
│   ├─ Networking\
│   ├─ Pentest\
│   └─ System\
└─ Start_Starko_Menu.bat
```

---

## 3. Kategorie a detailní popisy nástrojů

### 3.1 Obnova dat (Recovery)

**R-Studio**

* Plně profesionální nástroj pro obnovu dat.
* Zvládá NTFS, FAT, exFAT, EXT4, HFS+, APFS.
* Dokáže obnovit i poškozené RAID pole.

**Recuva**

* Rychlá obnova zmazaných souborů.
* Doporučeno pro jednoduché případy.

**TestDisk**

* Oprava rozbitých oddílů, záchrana MBR/GPT.
* Obnova RAW oddílů.
* Možnost rekonstrukce ztraceného EFI záznamu.

**Doporučený postup:**

1. Spusť TestDisk → oprav oddíl, pokud je RAW.
2. Spusť R-Studio → hluboká obnova dat.
3. Recuva pouze jako doplněk.

---

### 3.2 Diagnostika hardware (Diagnostics)

**HWINFO**

* Nejkomplexnější diagnostika hardware.
* Teploty, napětí, senzory, výkonové limity.

**CPU-Z / GPU-Z**

* Detailní informace o CPU, RAM, GPU.
* Užitečné pro rychlou identifikaci poruch.

**CrystalDiskInfo**

* Zdravotní stav disku (SMART).
* Detekce selhávajících SSD / HDD.

**MemTest86**

* Test paměti RAM (chyby, stabilita).
* Doporučeno spustit při BSOD problémech.

**Doporučený postup při podezření na poruchu:**

1. CrystalDiskInfo → zjisti stav disku.
2. HWINFO → zkontroluj teploty a senzory.
3. MemTest86 (dlouhý test).
4. CPU-Z → ověř nastavení RAM (XMP/EXPO).

---

### 3.3 Oprava Windows a systémových chyb (System Tools)

**SFC / DISM / CHKDSK – již připraveno v menu**

* Kompletní sada oprav systému.
* Automatické skripty pro opravu bootu:

  * Rekonstrukce BCD
  * Oprava EFI oddílu
  * bcdboot /scanos /rebuildbcd

**RegBack Restore**

* Obnova registrů ze zálohy.
* Kritické při bootloopech.

**Offline Password Reset**

* Reset hesel účtů Windows.
* Nástroj nepoškozuje data.

**File Explorer (WinPE)**

* Správa souborů i v poškozeném systému.

---

### 3.4 Síťové nástroje (Networking)

**Ping / Tracert / Nslookup**

* Diagnostika spojení.

**NetSh Tools**

* Reset síťových adaptérů.
* Reset Winsock.
* Import/export profilu WiFi.

**Wireshark**

* Kompletní sniffer síťového provozu.

**Nmap**

* Sken portů a zjištění zranitelností.
* Identifikace zařízení v síti.

**Doporučený postup při síťových chybách:**

1. 
> etsh winsock reset`
2. 
> etsh int ip reset`
3. Restart adaptérů (v menu)
4. Nmap → ověř připojená zařízení

---

### 3.5 Penetrační testy a bezpečnost (Pentest)

**Nmap**

* Full TCP scan
* Detekce služeb
* OS Fingerprinting

**Wireshark**

* Zachytávání paketů, analýza WiFi/LAN.

**John the Ripper**

* Test síly hesel.

**Hash Identifier**

* Určení typu hash hesla.

**Hashcat (pokud jej přidáš)**

* GPU cracking hesel.
* Podpora wordlistů.

**Doporučený postup bezpečnostní analýzy:**

1. Nmap – zmapovat síť.
2. Wireshark – analyzovat podezřelý provoz.
3. Hashcat / John – test hesel.
4. Kontrola otevřených portů.

---

### 3.6 Ostatní užitečné nástroje (Utility)

**Notepad++**

* Editace konfigurací, registrů, skriptů.

**AOMEI Backupper / Macrium Reflect**

* Kompletní diskové obrazy.
* Klonování disků.

**GParted / DiskPart GUI**

* Pokročilá správa oddílů.

---

## 4. Doporučené postupy pro nejčastější situace

### 4.1 Poškozený boot Windows

1. Otevřít menu → „Oprava bootu“
2. Automatický skript provede:

   * `bootrec /fixmbr`
   * `bootrec /fixboot`
   * `bootrec /scanos`
   * `bootrec /rebuildbcd`
   * `bcdboot C:\Windows /s D: /f UEFI`

### 4.2 Poškozený systém

1. „Oprava systémových souborů“
2. Spustí:

   * `sfc /scannow /offbootdir=C:\ /offwindir=C:\Windows`
   * `dism /image:C:\ /cleanup-image /restorehealth`

### 4.3 Obnova smazaných dat

1. TestDisk → oprava oddílu
2. R-Studio → hluboká obnova

### 4.4 Podezření na vadný hardware

1. CrystalDiskInfo → kontrola SSD/HDD
2. MemTest86 → dlouhý test RAM
3. HWINFO → přehřátí, napětí

---

## 5. Jak spustit WinPE prostředí

1. V BIOSu zvolte boot z USB.
2. Naběhne WinPE.
3. Automaticky se otevře `Start_Starko_Menu.bat`.

---

## 6. Logování a export výsledků

Menu umožňuje:

* uložit výsledky diagnostiky do složky:

  ```
  L:\Logs\YYYY-MM-DD\
  ```
* exportovat:

  * Nmap scan
  * HWINFO report
  * Wireshark capture
  * SFC/DISM logy

---

## 7. Požadavky

* USB: 8–64 GB
* Windows ADK + WinPE Add-on (kontrola a instalace probíhá ve skriptu)
* Režim UEFI (doporučeno)

---

## 8. Kontakty

Starko – Ultimate Recovery Toolkit


## Seznam skriptů
- `infrastructure\starko-ultimate-recovery-usb\install_starko_recovery.sh` – !/bin/bash
- `infrastructure\starko-ultimate-recovery-usb\starko_linux.sh` – !/bin/bash
- `infrastructure\starko-ultimate-recovery-usb\Starko_Recovery_AIO_Generator.ps1` – Skript Starko_Recovery_AIO_Generator.ps1
- `infrastructure\starko-ultimate-recovery-usb\Starko_Recovery_AIO_ULTIMATE.ps1` – =================================================================
- `infrastructure\starko-ultimate-recovery-usb\Starko_Recovery_AIO_v5.ps1` – =================================================================
- `infrastructure\starko-ultimate-recovery-usb\Starko_Recovery_Builder_FINAL.cmd` – Skript Starko_Recovery_Builder_FINAL.cmd
- `infrastructure\starko-ultimate-recovery-usb\starko_termux_full_v11.sh` – !/data/data/com.termux/files/usr/bin/bash
- `infrastructure\starko-ultimate-recovery-usb\starko_termux_full_v12.3_interactive.sh` – !/data/data/com.termux/files/usr/bin/bash
- `infrastructure\starko-ultimate-recovery-usb\starko_termux_full_v12.3-ultra.sh` – !/data/data/com.termux/files/usr/bin/bash


## Hodnocení a doporučení
<!-- Doplňte na základě výše uvedených informací -->
- 
