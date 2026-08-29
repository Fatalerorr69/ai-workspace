# DEVELOPMENT KNOWLEDGE BASE v2.5 (2026)

## 1. STANDARDY KÓDOVÁNÍ (PYTHON 3.12+)
- **Typování:** Striktní využívání modulu `typing`. Funkce bez definovaných vstupů a výstupů nebudou přijaty.
- **Async:** Preferovat `asyncio` pro I/O operace.
- **Struktura:** Vždy oddělovat logiku (Business Logic) od rozhraní (API/CLI).

## 2. DOCKER & UNIVERZÁLNOST
- **Multi-platform:** Dockerfile musí vždy obsahovat `--platform=$BUILDPLATFORM`.
- **Base Image:** Používat výhradně `python:3.12-slim` nebo `alpine` pro minimalizaci velikosti.
- **Layers:** Optimalizovat cache (nejdříve `requirements.txt`, pak zbytek kódu).

## 3. UNIVERZÁLNÍ HARDWARE ABSTRAKCE (HAL)
- Přístup k souborům: Vždy přes `pathlib`, nikdy ne hardcoded cesty jako `C:\` nebo `/home/pi`.
- Periferie (IoT): Používat abstrakční knihovny, které detekují hardware (např. simulace pinů, pokud neběží na Raspberry Pi).