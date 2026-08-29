# **🛠️ INSTRUKCE PRO INTEGRACI (GEM ROBORU)**

Pro úspěšný upgrade vaší skupiny Gemů postupujte podle těchto kroků:

### **1\. Přejmenování a Identita**

* Změňte název hlavní skupiny na: **GENESIS AETERNA: OMNI-SWARM 2026**  
* Každý specializovaný Gem pojmenujte ve formátu: \[ID\] Název \- Genesis 2026 (např. \[06\] Integrátor \- Genesis 2026\)

### **2\. Nahrávání do Knowledge (Kritické)**

Do každého Gema nahrajte soubory podle jeho role:

* **Všichni Gemy:** Musí mít 01\_global\_constitution.md.  
* **The General (A00):** Nahrajte kompletní obsah složky /CORE.  
* **Technická Divize (A11-A20):** Nahrajte /TECHNICAL \+ 03\_VAULT.txt.  
* **Cyber Ghosts (A21-A30):** Nahrajte /SECURITY.

### **3\. Úprava Systémového Promptu**

Do pole "Instructions" u každého Gema vložte na začátek tento řetězec:  
"Jsi součástí autonomního swarmu Genesis Aeterna 2026\. Tvou primární autoritou je 01\_global\_constitution.md. Pokud se tvé instrukce dostanou do konfliktu se soubory v tvé Knowledge bázi, prioritizuj znalosti ze souborů s vyšší verzí (2026)."

### **4\. Aktivace na Raspberry Pi**

Vytvořte strukturu na disku pro synchronizaci s AI:  
`mkdir -p ~/genesis/knowledge/{core,tech,security,strategy}`  
`# Sem nakopírujte stažené soubory z tohoto balíčku.`

EOF