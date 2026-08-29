# **Architektura GENESIS AETERNA v10.0 (Univerzální)**

## **1\. Jádro Systému (Kernel Space)**

* **Host OS:** Ubuntu/Debian (Linux) nebo Windows 10/11 (přes WSL2/Docker Desktop).  
* **Orchestrátor:** Docker Compose (zajišťuje izolaci a přenositelnost).  
* **Storage:** Sjednocená struktura /genesis/vault mapovaná do kontejnerů.

## **2\. Funkční Sektory (Microservices)**

* **Sektor 01 (Core):** Dashboard (Python Dash/Flask) \- port 8050\.  
* **Sektor 02 (AI Engine):** Ollama API \- port 11434\.  
* **Sektor 03 (Management):** Portainer (GUI pro kontejnery) \- port 9443\.  
* **Sektor 04 (Data):** Vector DB (ChromaDB) pro RAG.  
* **Sektor 09 (Security):** Síťové nástroje (izolované v privilegovaném kontejneru).

## **3\. Logika Adaptace (HAL)**

* **Detekce RPi 5:** Aktivuje NVMe Gen3 tuning a chlazení.  
* **Detekce PC (Windows/Linux):** Aktivuje CUDA/ROCm pro AI akceleraci a rozšiřuje RAM limity.

## **4\. Komunikační Protokol**

* Gemy komunikují přes REST API a sdílené logy v \~/genesis/logs/system.json.