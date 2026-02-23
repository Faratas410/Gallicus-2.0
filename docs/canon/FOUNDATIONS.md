# GALLICUS — FOUNDATIONS (Unified Canon Index)

Status: CANON
Level: 3
Authority: Governance Root

Questo documento sostituisce e unifica tutti i precedenti file “Foundation”.

Diventa la fonte primaria di:

- Principi strutturali
- Filosofia L3
- Regole di autorità
- Invarianti concettuali
- Metastruttura del progetto

---

# INDEX

1. Visione Fondativa
2. Architettura Autoritativa
3. Determinismo & Seed Contract
4. Single Authority Principle
5. UI Reactivity Doctrine
6. Flow Integrity Rules
7. Canon Governance Model
8. Zone Model (Core / Flexible / Tooling)
9. Patch Discipline
10. Evolution Constraints

---

# 1. Visione Fondativa

Gallicus è un sistema:

- Centralizzato
- Autoritativo
- Deterministico
- Documentally Sealed

Non è un prototipo.
È un sistema coerente con confini chiari.

---

# 2. Architettura Autoritativa

- Single RunManager
- GameEvents come unico bus eventi
- Nessuna doppia autorità
- Nessun flow parallelo

Se emergono autorità duplicate → STOP immediato.

---

# 3. Determinismo & Seed Contract

- Seed riproducibile
- Nessuna dipendenza da stato globale volatile
- Nessuna influenza esterna (internet / tempo sistema)

Il determinismo è vincolo architetturale, non feature opzionale.

---

# 4. Single Authority Principle

Ogni responsabilità ha:

- un solo owner
- una sola fonte di verità
- un solo punto di mutazione

Duplicazioni strutturali sono vietate.

---

# 5. UI Reactivity Doctrine

La UI:

- Non prende decisioni
- Non contiene logica di gameplay
- Reagisce a stato ed eventi

Se una UI “decide” qualcosa → violazione.

---

# 6. Flow Integrity Rules

Il flow:

- è lineare
- è fase-driven
- è validato

Transizioni non autorizzate → flow/state violation.

---

# 7. Canon Governance Model

Se qualcosa:

- non è nel canon
- è in conflitto col canon
- non aggiorna il canon quando necessario

→ non è valido.

---

# 8. Zone Model

Core Authority Zone — Hard Freeze
Flexible Domain Zone — Controlled
Tooling Zone — High Freedom

Le regole operative di queste zone sono definite in PROCESS_AND_FREEZE.md.

---

# 9. Patch Discipline

Una patch:

- ha un solo obiettivo
- è localizzata
- dichiara impatto
- rispetta le zone

Refactor non richiesti sono vietati.

---

# 10. Evolution Constraints

Ogni evoluzione deve dichiarare impatto su:

- MECHANICS
- RUN_ARCHITECTURE
- UI
- LORE
- GLOSSARY

Se non aggiorna il canon corretto → la feature è incompleta.

---

# Deprecation Notice

I precedenti file “Foundation” sono stati rimossi dal repository.

La fonte primaria è ora:

docs/canon/FOUNDATIONS.md

In caso di conflitto con materiale esterno o storico:

FOUNDATIONS.md prevale.
