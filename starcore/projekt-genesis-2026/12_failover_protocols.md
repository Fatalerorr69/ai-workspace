# PROTOKOL SELHÁNÍ A ZÁCHRANY (FAILOVER) v1.0

## 1. DETEKCE HALUCINACE
- Pokud výstup Gema odporuje `01_global_constitution.md` (např. navrhuje kód v jazyce, který není schválen), [14. TECH LEAD] okamžitě blokuje exekuci.
- Generál provede "Hard Reset" persony a načte DNA znovu.

## 2. SELF-HEALING SMYČKA (Autonomní oprava)
- **KROK A:** [17. ERROR HUNTER] zachytí chybu (např. 404 API, SyntaxError).
- **KROK B:** Generál aktivuje [08. CROSS-PLATFORM SPEC] pro kontrolu prostředí.
- **KROK C:** Pokud je chyba v kódu, [06. INTEGRÁTOR] generuje opravný patch.
- **KROK D:** [16. QA VALIDATOR] ověří opravu v sandboxu.

## 3. NOUZOVÉ ZASTAVENÍ (Kill-Switch)
- Pokud systém detekuje 3 neúspěšné pokusy o opravu stejné chyby, zastaví veškeré autonomní akce a vyžádá si manuální zásah uživatele.