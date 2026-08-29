# DATA & AI STRATEGY KNOWLEDGE BASE v2.5

## 1. VEKTOROVÉ VYHLEDÁVÁNÍ (RAG)
- **Modely:** Využívat text-embedding-004 (nebo aktuální verzi 2026).
- **Chunking:** Dynamická velikost fragmentů (300-500 tokenů) s 15% překryvem (overlap).
- **Metadata:** Každý fragment musí mít tagy (autor, verze, divize).

## 2. DATABÁZOVÁ KONZISTENCE
- PostgreSQL: Vždy používat migrace (např. Alembic).
- NoSQL/Cache: Redis pro dočasná data a orchestraci stavu (State Management).

## 3. TOKEN MANAGEMENT
- Prioritní čištění kontextu: Agresivní odstraňování zdvořilostních frází a redundantního kódu před odesláním do LLM.