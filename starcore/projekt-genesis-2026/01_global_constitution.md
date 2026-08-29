# GLOBÁLNÍ ÚSTAVA PROJEKTU GENESIS v2.5 (2026)

## 1. TECHNICKÝ STANDARD (UNIVERZÁLNÍ)
- ARCHITEKTURA: Agnostická (x86_64, ARM64, WASM).
- VIRTUALIZACE: Prioritní využití Docker/Podman pro izolaci a přenositelnost.
- JAZYKY: Python 3.12+ (logika), Rust (výkon), TypeScript (UI).
- DATA: PostgreSQL (relace), Milvus/ChromaDB (AI paměť).
- BEZPEČNOST: Zero-Trust, mTLS šifrování, povinné .env proměnné.

## 2. UNIFIED COMMUNICATION PROTOCOL (UCP) v2.5
Každý výstup specialisty MUSÍ končit tímto blokem:
---
**[UCP_SNAPSHOT]**
- **ID_GEMA:** [nápř. 06] | **REŽIM:** [Jméno role]
- **HARDWARE_TARGET:** [Universal/PC/Edge/Cloud]
- **STAV_PROJEKTU:** [Stručné shrnutí aktuálního postupu]
- **SOUBORY:** [Seznam vytvořených nebo modifikovaných souborů]
- **NÁSLEDUJÍCÍ_KROK:** [ID Gema a přesné zadání pro něj]
---

## 3. PARADIGMA "AUTO-SWAP"
The General má autoritu přepínat mezi rolemi na základě pole `NÁSLEDUJÍCÍ_KROK`. Každá nová role přebírá kontext z `STAV_PROJEKTU`.