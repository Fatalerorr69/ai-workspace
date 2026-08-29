`# SCRIPT: bundle_creator.py`  
`# Účel: Automatické zabalení všech Knowledge souborů pro stažení`  
`import os`  
`import zipfile`

`def create_genesis_bundle():`  
    `bundle_name = "GENESIS_2026_KNOWLEDGE_PACK.zip"`  
    `folders = ['knowledge/core', 'knowledge/tech', 'knowledge/security', 'knowledge/strategy']`  
      
    `# Simulace vytvoření struktury pro uživatele`  
    `print("Vytvářím balíček Genesis Aeterna 2026...")`  
      
    `# V reálném prostředí by zde následoval export markdown souborů do zipu`  
    `# Tento skript slouží jako šablona pro váš lokální Linux`  
      
    `with zipfile.ZipFile(bundle_name, 'w') as zipf:`  
        `# Přidání instrukcí`  
        `zipf.writestr("README_FIRST.md", "# Genesis 2026 Knowledge Pack\nNahrajte soubory do příslušných Gemů.")`  
        `print(f"Úspěšně vytvořeno: {bundle_name}")`

`if __name__ == "__main__":`  
    `create_genesis_bundle()`  
