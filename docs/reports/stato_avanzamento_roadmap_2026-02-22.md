# Gallicus — Stato avanzamento lavori e roadmap progressiva (snapshot tecnico)

Data: 2026-02-22  
Scope: assessment tecnico su codice + runtime, orientato alla pianificazione incrementale.

> Documento di report (non canon). Le decisioni autoritative restano nei file `docs/canon/*`.

## 1) Stato attuale sintetico

### 1.1 Runtime invariants (baseline)
Check automatici eseguiti:
- `python3 scripts/ci/check_runtime_invariants.py` → **OK**
- `python3 scripts/ci/check_no_legacy_references.py` → **OK**
- `python3 tools/ci/validate_gameevents_contract.py` → **OK** (19 segnali richiesti validati)
- `python3 tools/ci/verify_res_paths.py` → **OK**

L’architettura risulta coerente con i vincoli Level 3 (single RunManager authority + GameEvents contract + path `res://` validi).

### 1.2 Stato coding (strutturale)
- `RunManager` è ancora molto esteso (`~4656` righe): forte centralizzazione logica/flow.
- `UIRoot` è anch’esso grande (`~2416` righe): gestione reattiva ampia ma densa.
- Persistono segnali di contenuto incompleto lato betting legacy in `data/bets.gd` (`pact` con stringhe placeholder).
- `run_flow_catalog.gd` mantiene router eventi vuoto (`pass`) con registry mutation attivo: struttura presente, adozione parziale.

### 1.3 Stato runtime (verifica eseguibile)
- **Non verificato in questa snapshot**: avvio reale Godot 4.6 della scena `res://scenes/Main.tscn` e assenza warning editor/runtime.
- I check statici e di contratto passano, ma manca ancora una sessione di smoke runtime completa con evidenza registrata.

---

## 2) Cosa manca oggi (gap operativi)

## A) Gap di coding
1. **Completamento contenuti dati betting “storici”**
   - In `data/bets.gd` i campi `pact` sono ancora placeholder testuali.
   - Impatto: qualità/consistenza contenutistica; riduce percezione di “build pronta”.

2. **Riduzione rischio da concentrazione logica**
   - `RunManager` e `UIRoot` hanno elevata superficie di regressione per patch minime.
   - Impatto: manutenzione lenta, review più difficile, costo fix crescente.

3. **Allineamento documentazione di inventory**
   - Alcuni report storici citano ancora `legacy-runtime`, ma nello snapshot corrente la directory non risulta presente.
   - Impatto: rumore cognitivo e possibili decisioni basate su inventario non aggiornato.

## B) Gap di runtime/QA
1. **Smoke test end-to-end in engine non formalizzato nel report corrente**
   - Mancano prove aggiornate “boot Main -> run completa -> finale -> restart/continue” con log allegato.

2. **Validazione “warnings = errors” lato editor Godot**
   - I check Python passano, ma serve la verifica editor/headless Godot per chiudere il requisito operativo.

3. **Matrice regressione flow/UI non ancora serializzata come routine periodica**
   - Esiste copertura contrattuale, ma non una checklist E2E corta e ripetibile per ogni milestone.

---

## 3) Roadmap progressiva consigliata (incrementale)

## Fase 0 — Baseline verificabile (quick win, 1 ciclo)
**Obiettivo:** trasformare lo stato attuale in baseline tracciata.

- Raccogliere smoke log runtime Godot 4.6 su `Main.tscn` (new run + continue + finale).
- Registrare esito warning count = 0 in un report tecnico unico.
- Congelare output comandi CI già verdi nello stesso report.

**Done quando:** check statici + smoke runtime + warning zero sono tutti documentati insieme.

## Fase 1 — Chiusura gap contenutistici minimi (1-2 cicli)
**Obiettivo:** rimuovere indicatori espliciti di incompleto.

- Sostituire i placeholder `pact` in `data/bets.gd` con copy coerente al canon.
- Verificare che i nuovi testi siano riflessi correttamente nella UI betting.

**Done quando:** nessun placeholder utente-facing nelle entry bet L3 attive.

## Fase 2 — Hardening runtime operativo (2 cicli)
**Obiettivo:** rendere la regressione flow più difficile.

- Introdurre una checklist smoke corta e stabile (esecuzione obbligatoria pre-merge).
- Tracciare i passaggi di fase principali (MAIN_MENU → RUN_INIT → BET_PRESENT → …) con assert di coerenza.
- Consolidare in un report singolo la diagnostica flow (evitando frammentazione tra più report storici).

**Done quando:** ogni patch può dimostrare in modo rapido che il flow canonico non è regredito.

## Fase 3 — Riduzione rischio manutenzione (continuativa)
**Obiettivo:** abbassare il costo delle patch senza alterare authority.

- Pianificare micro-split progressivi su `RunManager`/`UIRoot` solo dove già previsto dal perimetro attuale (nessun cambio di authority, nessun refactor ampio in un colpo).
- Ogni split deve restare: minimale, reversibile, e coperto da check CI + smoke.

**Done quando:** diminuisce la superficie per patch (file/funzioni toccate) mantenendo invarianti invariati.

## Fase 4 — Igiene documentale (continuativa)
**Obiettivo:** evitare drift tra “stato reale repo” e report.

- Consolidare report obsoleti/doppi in `docs/reports/INDEX.md` con marcatura “storico/non più corrente”.
- Aggiornare inventory report quando cambia struttura reale cartelle.

**Done quando:** un nuovo contributor legge un solo percorso documentale e non trova conflitti operativi.

---

## 4) Priorità pratica (ordine di esecuzione)
1. **Fase 0** (blocca incertezza runtime).  
2. **Fase 1** (chiude gap visibili al player).  
3. **Fase 2** (stabilizza QA flow).  
4. **Fase 4** (riduce rumore documentale).  
5. **Fase 3** (riduzione rischio manutenzione nel medio periodo).

---

## 5) Nota decisionale
Lo snapshot mostra una base tecnica robusta lato invarianti/contratti, ma ancora incompleta lato “prove runtime tracciate” e pulizia di alcuni segnali di incompleto (placeholder + report storici non allineati). La roadmap sopra privilegia prima la verificabilità in engine, poi la rifinitura contenutistica, poi l’hardening di processo.
