# CANON — PROCESS AND FREEZE

Status: Single source of truth

If another doc conflicts, this doc wins.

Last merged from: docs/FASE_10_FREEZE.md, docs/CODEX_GOLDEN_CHECKLIST.md

## Canon Contract

This document is authoritative for its category.
No other file may redefine these concepts.
All changes to systems described here must update this document in the same PR.


## Index

- [TASK 10.1 — Freeze di design](#task-101-freeze-di-design)
- [SOURCE: CODEX_GOLDEN_CHECKLIST](#source-docscodexgoldenchecklistmd)

## SOURCE: docs/FASE_10_FREEZE.md

# FASE 10 — FREEZE

**Status:** SUPPORTING  
**Scope:** Operational freeze policy for patch scope and stop conditions.  
**Source of truth:** docs/CODEX_GOLDEN_CHECKLIST.md, docs/00_RISK_DRIVEN_DESIGN_BIBLE  
**Last updated:** 2026-02-11  
**Notes:** Overlaps with: docs/CODEX_GOLDEN_CHECKLIST.md.
- Candidate for archive after consolidation patch if freeze policy is merged into canon operations docs.

## Overlap
- Overlaps with: docs/CODEX_GOLDEN_CHECKLIST.md.
- Candidate for archive after consolidation patch if freeze policy is merged into canon operations docs.

## TASK 10.1 — Freeze di design

### Scopo
- Gallicus 1.0 è in stato **chiuso**.

### Regola operativa
- **Non aggiungere feature**.
- Applicare **solo bugfix compatibili** con l'architettura attuale.
- Segnalare esplicitamente ogni tentazione di "migliorare" oltre il fix richiesto.

### Vincoli in vigore durante il freeze
- Valgono integralmente i vincoli di `docs/CODEX_GOLDEN_CHECKLIST.md`.
- Valgono integralmente gli intenti di `docs/00_RISK_DRIVEN_DESIGN_BIBLE`.
- Una task = una patch minimale, localizzata, reversibile.

### Criterio di stop
Se la correzione richiede refactor, tocca più sistemi o implica redesign: **STOP e report**, senza applicare cambiamenti strutturali.

## SOURCE: docs/CODEX_GOLDEN_CHECKLIST.md

# Codex Golden Checklist

**Status:** CANON  
**Scope:** Non-negotiable technical, architecture, and patch invariants for Codex operations.  
**Source of truth:** docs/CODEX_GOLDEN_CHECKLIST.md  
**Last updated:** 2026-02-11  
**Notes:** Overlaps with: docs/FASE_10_FREEZE.md (operational freeze framing).

## Overlap
- Overlaps with: docs/FASE_10_FREEZE.md (operational freeze framing).

🟡 GALlicus — GOLDEN CHECKLIST (Codex Edition · Level 3)

Questa checklist definisce i limiti di sicurezza entro cui Codex può operare.
Non è un elenco di divieti assoluti, ma di invarianti da rispettare.

Se una patch li viola, la patch va fermata e segnalata.

---

# EVOLUZIONE L3 — FLEXIBLE DOMAIN POLICY

Gallicus Level 3 introduce una distinzione strutturale tra:

• Core Authority Zone (Hard Freeze)
• Flexible Domain Zone (Controlled Freedom)
• Tooling & Infrastructure Zone (High Freedom)

L’obiettivo è aumentare la velocità operativa di Codex cloud
senza compromettere autorità, determinismo e coerenza canonica.

---

## 1️⃣ CORE AUTHORITY ZONE — HARD FREEZE

Questa zona NON è negoziabile.

Comprende:

- RunManager flow authority
- Phase routing
- GameEvents contract
- Seed determinism logic
- Scar RNG state contract
- Single-run authority guarantees
- Entry scene contract

Regole:

❌ Nessun refactor strutturale
❌ Nessuna modifica architetturale implicita
❌ Nessuna "ottimizzazione migliorativa"

Consentito solo:

✅ Bugfix derivante da sintomo concreto
✅ Fix di violazione invarianti
✅ Correzione determinismo / idempotenza

Se una patch tocca questa zona:
→ deve dichiararlo esplicitamente nel report.

---

## 2️⃣ FLEXIBLE DOMAIN ZONE — CONTROLLED FREEDOM

Zona accelerata per sviluppo.

Comprende:

- Scar kernel interno (non authority)
- Data catalogs statici
- UI layout e presentazione
- Asset wiring
- Static resource binding
- Serialization helpers
- Pure utility modules

Qui Codex può:

✅ Rifattorizzare codice puramente meccanico
✅ Estrarre costanti / data file
✅ Eliminare duplicazioni
✅ Applicare pulizie locali
✅ Eseguire batch micro-fix coerenti nello stesso dominio

Vincolo:

La semantica runtime non deve cambiare.

Se cambia comportamento → non è più zona flexible.

---

## 3️⃣ TOOLING & INFRASTRUCTURE ZONE — HIGH FREEDOM

Comprende:

- CI workflows
- Smoke test matrix
- Headless validation
- Setup / maintenance scripts
- Lint / type enforcement
- Container configuration
- Cloud environment configuration

In questa zona Codex può operare con ampia autonomia,
inclusi:

✅ Miglioramenti performance CI
✅ Hardening test
✅ Parallel validation
✅ Container caching tuning

Unico limite:

Il runtime del gioco non deve dipendere da internet o tool esterni.

---

## Nuova Regola Operativa

La regola evolve da:

"Una task = una patch"

a:

"Una task = un dominio coerente"

Dominio coerente significa:

✔ stesso sistema
✔ stessa responsabilità
✔ stessa zona operativa

Se una modifica attraversa due zone diverse:
→ STOP e separare in task distinte.

---

Principio guida L3 evoluto:

Velocità sì.
Autorità non si tocca.

Il core resta sigillato.
Le periferie possono accelerare.

1. INVARIANTI TECNICI (NON NEGOZIABILI)

Engine: Godot 4.6

Linguaggio: strict typed GDScript

Zero warnings (warnings = errors)

Entry point: res://scenes/Main.tscn

Deve avviarsi senza errori

Un solo RunManager

path: res://scripts/systems/run_manager.gd

group: run_manager

❌ Nessun RunManager duplicato o alternativo

GameEvents

deve esistere

deve essere Autoload

nessun event bus alternativo

2. INVARIANTI DI ARCHITETTURA (LEVEL 3)

UI è reattiva, non decisionale

la UI mostra stato

non decide outcome

La logica di gioco:

NON vive nella UI

NON vive nell’arena

L’arena è solo rituale visivo

può animare

non governa il flow

Node groups ammessi:

run_manager

arena (visual only)

player (passive / visual)

enemies (passive / visual)

3. INVARIANTI DI FLOW

Nessuno stato deve lasciare lo schermo “vuoto”

Ogni azione dell’utente deve:

produrre feedback visivo o testuale

portare a uno stato successivo

❌ Dead-end vietati

Se qualcosa “non succede”:

è un problema di flow o di evento

non di layout

4. PATCH DISCIPLINE (FONDAMENTALE)

Una task = una patch

La patch deve essere:

minimale

localizzata

comprensibile

❌ No refactor “già che ci sono”

❌ No pulizie strutturali non richieste

❌ No rinomine arbitrarie

✅ Meglio una patch incompleta che una patch invasiva

5. COSA È CONSENTITO

Codex PUÒ:

sistemare errori runtime

correggere path, segnali, init order

ripristinare UI o flow mancanti

rimuovere riferimenti legacy solo se richiesto

aggiungere micro-feedback (testo, stato disabled)

Codex NON DEVE:

reinterpretare il design

“migliorare” il gioco di propria iniziativa

aggiungere feature non richieste

cambiare struttura delle scene senza richiesta esplicita

6. REGOLA DI PRUDENZA

Se una modifica:

tocca più sistemi

richiede refactor

rompe una invariante

non è chiaramente motivata dal sintomo

👉 STOP. REPORT. NON AGIRE.

7. PRINCIPIO GUIDA

Gallicus non deve diventare “più complesso”.
Deve diventare più coerente.

## Level 3 Stability Seal

Runtime structure and documentation are aligned.
Any future runtime modification requires updating:
- RUN_ARCHITECTURE_CANON
- repo_map.md
- MECHANICS_UNIFIED (if flow impacted)


---

## 🔒 L3 — Legacy & Enum Stability Policy

### 1️⃣ Legacy nel Flow L3 Attivo

Quando una fase, funzione o traiettoria viene dichiarata **legacy** nel flow L3 attivo, deve rispettare una delle due condizioni:

**Opzione A (preferita):**

* Nessun callsite runtime
* Nessun signal collegato
* Nessun timer/fallback associato
* Nessun ingresso di fase (_set_phase / _run_enter_phase)
* Nessuna dipendenza in guardie request

**Opzione B (solo se richiesto da compatibilità):**

* Slot enum mantenuto ma marcato come:
  `# RESERVED (removed in L3)`
* Nessun percorso eseguibile verso quella fase

Non è ammesso lasciare codice “legacy ma ancora eseguibile”.

---

### 2️⃣ Enum di Fase — Regola di Stabilità

Le enum di RunPhase seguono questa regola:

* Se la fase NON è persistita in save/checkpoint:
  → È consentita la compattazione numerica.

* Se la fase È persistita (direttamente o indirettamente):
  → I valori numerici diventano **frozen**.
  → Le fasi rimosse devono restare come `RESERVED`.
  → Qualsiasi modifica richiede:

  * level3_schema bump
  * migrazione esplicita

---

### 3️⃣ Single Trajectory Principle

Nel flow L3 attivo deve esistere **una sola traiettoria autoritativa** per ogni segmento critico (es. post-firma patto).

Non sono ammessi:

* callback alternativi
* timer fallback paralleli
* rami di fase raggiungibili ma non documentati
