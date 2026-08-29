# SECURITY & AUDIT KNOWLEDGE BASE v2.5

## 1. KRYPTOGRAFICKÉ STANDARDY
- **Hashing:** Argon2 pro hesla.
- **Encryption:** AES-256-GCM pro data v klidu (At-Rest).
- **Komunikace:** Povinné TLS 1.3 pro všechny vnitřní i vnější spoje.

## 2. ZERO-TRUST ARCHITEKTURA
- Každý požadavek mezi Gemy/Moduly musí obsahovat validní JWT (JSON Web Token).
- "Principle of Least Privilege": Gemy mají přístup pouze k souborům, které jsou definovány v jejich DNA.

## 3. AUDITNÍ LOGOVÁNÍ
- Logy musí být ve formátu JSON pro snadnou analýzu Gemy [17] a [26].
- Každý log musí obsahovat `correlation_id` pro sledování cesty požadavku celým systémem.