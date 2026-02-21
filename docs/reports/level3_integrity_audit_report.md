# Level 3 Runtime Integrity Audit Report

**Status:** REPORT  
**Scope:** Historical Level 3 integrity audit findings and risk flags.  
**Source of truth:** docs/CODEX_GOLDEN_CHECKLIST.md, docs/canon/RUN_ARCHITECTURE_CANON.md  
**Last updated:** 2026-02-11  
**Notes:** This is historical; not canon.

Overlaps with: docs/reports/level3_open_questions_log.md, docs/reports/codex_report_1_0_gap.md.

## Overlap
- Overlaps with: docs/reports/level3_open_questions_log.md, docs/reports/codex_report_1_0_gap.md.

## Scope
- Audit statico (repo-wide) su runtime Level 3.
- **Doc-only**: nessuna modifica codice.
- Verifica su authority, isolamento legacy, path paralleli, elementi non deterministici.

---

## SECTION A — Run Authority Verification

Signal verificati:
- `run_started`
- `run_failed`
- `run_ended`
- `run_finale_selected`

### Emitters trovati (`GameEvents.<signal>.emit(...)`)
- `scripts/systems/run_manager.gd`
  - `GameEvents.run_started.emit()`
  - `GameEvents.run_failed.emit()`
  - `GameEvents.run_ended.emit(...)`
  - `GameEvents.run_finale_selected.emit(...)`

### Esito
- **Solo RunManager emette** i 4 segnali di autorità run.
- **Risk**: **LOW** (invariante rispettata).

---

## SECTION B — `request_*` Events

Pattern richiesti:
- `request_fail_run`
- `request_place_bet`
- `request_start_run`

### `request_fail_run`
- **Emitters**:
  - `legacy-runtime/gameplay/player_legacy.gd`
  - `scripts/systems/bet_manager.gd`
- **Receivers (connect)**:
  - `scripts/systems/run_manager.gd` (`_on_request_fail_run`)
- **Valutazione**:
  - Intent -> RunManager presente.
  - Esistono però emitters non-RunManager (legacy + BetManager).
  - **Risk**: **MEDIUM** (canale corretto ma riattivabile da sistemi non L3).

### `request_place_bet`
- **Emitters**:
  - `scripts/ui/ui_root.gd`
- **Receivers (connect)**:
  - `scripts/systems/run_manager.gd` (`_on_request_place_bet`)
  - `scripts/systems/bet_manager.gd` (`_on_request_place_bet`)
- **Valutazione**:
  - Non è “solo intent -> RunManager”, perché BetManager ascolta in parallelo.
  - **Risk**: **HIGH** (path parallelo runtime possibile).

### `request_start_run`
- **Risultato ricerca**: non trovato nel repo.
- **Nota**: flow start usa `request_new_run` / `request_continue_run`.
- **Valutazione**: mapping semantico plausibile ma non identico al pattern richiesto.
- **Risk**: **UNCERTAIN** (nomenclatura diverge dal requisito testuale).

---

## SECTION C — Instantiate & Timer Scan

Pattern cercati:
- `instantiate(`
- `create_timer(`
- `Timer.new(`
- `await get_tree().create_timer`

### Trovati in `legacy-runtime/`
- `legacy-runtime/pickups/PickupSpawner.gd`
  - `instantiate()` + `await get_tree().create_timer(...)`
- `legacy-runtime/pickups/Pickup.gd`
  - `await get_tree().create_timer(...)`
- `legacy-runtime/gameplay/player_legacy.gd`
  - multipli `await get_tree().create_timer(...)`

**Valutazione L3**:
- Fuori albero runtime ufficiale.
- Nessun riferimento da `scenes/` o `scripts/` runtime L3 a `res://legacy-runtime/*`.
- **Risk**: **MEDIUM** (inattivo per wiring attuale, ma codice eseguibile se referenziato in futuro).

### Trovati in runtime L3 (`scripts/`)

#### `scripts/Arena.gd`
- `instantiate()` (player/enemy/layout elements)
- `await get_tree().create_timer(...)`
- **Guardia**: funzioni gameplay protette con `LEVEL3_PASSIVE_MODE` (ritorni anticipati).
- **Risk**: **LOW** (presenti ma disattivati in passive mode).

#### Legacy avatar script (removed)
- `await get_tree().create_timer(...)`
- **Guardia**: script in `LEVEL3_PASSIVE_MODE := true` con blocchi passivi.
- **Risk**: **LOW**.

#### `scripts/ui/ui_root.gd`
- `instantiate()` (UI enemy bar / betting circle)
- `await get_tree().create_timer(...)` (solo timing UI)
- **Guardia**: non tramite `LEVEL3_PASSIVE_MODE` (non necessaria: è UI).
- **Risk**: **LOW**.

#### `scripts/systems/run_manager.gd`
- `instantiate()` (arena/player/layout)
- `await get_tree().create_timer(...)` (sequenze flow)
- **Guardia**: è authority runtime, non soggetto a passive flag.
- **Risk**: **LOW**.

#### `Timer.new(`
- Nessuna occorrenza trovata.

---

## SECTION D — Legacy Runtime Isolation

Verifica `res://legacy-runtime/`:

### Preload / instantiate
- Trovati **solo internamente** a file in `legacy-runtime/` (es. `PickupSpawner.gd`).
- **Nessun preload/instantiate da `scripts/` o `scenes/` runtime L3**.

### Riferimenti in scene runtime
- Nessuna scena runtime attiva (`scenes/Main.tscn`, `scenes/UI.tscn`, `scenes/Arena.tscn`, `scenes/enemies/*`) referenzia `res://legacy-runtime/*`.

### Esito
- Legacy runtime risulta confinato per wiring statico.
- **Risk**: **LOW**.

---

## SECTION E — Dynamic Discovery Scan

Pattern:
- `get_node_or_null(`
- `find_child(`
- `get_first_node_in_group(`

### Aree principali
- `scripts/systems/run_manager.gd`: discovery intenso di `arena`, `player`, UI paths, spawn points.
- `scripts/ui/ui_root.gd`: discovery nodi UI + lookup gruppi (`arena`, `player`, `run_manager`, `bet_manager`).
- `scripts/Arena.gd`, `scripts/entities/enemy_basic.gd`: lookup di gruppo `run_manager` e nodi visual.
- `legacy-runtime/*`: lookup run manager e nodi runtime legacy.

### Valutazione per flow
- Discovery in RunManager: **critico** e coerente con ruolo authority.
- Discovery in UI/Arena/Player: per binding visuale o fallback runtime.
- Presenza lookup `bet_manager` in UI indica canale secondario potenziale.

### Necessità
- Molti lookup sono necessari per robustezza scena dinamica.
- Alcuni fallback multipli (`find_child`/group lookup) aumentano superficie di riattivazione path paralleli.

**Risk complessivo sezione**: **MEDIUM**.

---

## SECTION F — Scene Graph Check

Verifica target:
- `scenes/Main.tscn`
- `RunManager` (script `scripts/systems/run_manager.gd`)
- `UIRoot` (script `scripts/ui/ui_root.gd` + `scenes/UI.tscn`)

### Esito su inclusioni dirette vietate
- **PickupSpawner**: non incluso direttamente.
- **Legacy enemy**: non incluso direttamente.
- **Legacy player**: non incluso direttamente.
- **BetManager**:
  - non incluso direttamente in `Main.tscn` / `UI.tscn`.
  - ma `UIRoot` effettua lookup gruppo `bet_manager` (dipendenza runtime opzionale).

### Classificazione
- Inclusioni legacy dirette: **LOW** (non rilevate).
- Dipendenza opzionale da `bet_manager`: **MEDIUM** (path parallelo potenziale, non garantito attivo staticamente).

---

## Consolidated Findings

### LOW
- Emissione `run_*` autoritativa solo da RunManager.
- Nessun riferimento runtime L3 a `res://legacy-runtime/*`.
- Instanziazioni/timer UI e RunManager coerenti col ruolo.
- `Arena.gd` con passive-mode attivo nei punti gameplay principali; avatar runtime rimosso in Level 3.

### MEDIUM
- Emitters `request_fail_run` fuori RunManager (legacy + BetManager).
- `request_place_bet` ricevuto sia da RunManager sia da BetManager.
- Dynamic discovery esteso con fallback multipli.
- Legacy code con timer/instantiate ancora presente (pur confinato).

### HIGH
- `request_place_bet` con receiver parallelo (`bet_manager.gd`) rompe l’aspettativa “solo intent -> RunManager” in modo staticamente osservabile.

### UNCERTAIN
- `request_start_run` non esiste; flow usa `request_new_run` / `request_continue_run`.

---

## Acceptance Criteria — Risposte dirette

1. **Level 3 è realmente single-authority?**
   - **Parzialmente sì**: i segnali terminali di run (`run_started`, `run_failed`, `run_ended`, `run_finale_selected`) sono emessi solo da RunManager.
   - **Ma non pienamente** lato intent betting, per receiver parallelo su `request_place_bet` (HIGH).

2. **Il legacy è completamente confinato?**
   - **Staticamente sì nel wiring runtime**: nessun riferimento `res://legacy-runtime/*` da scene/script runtime L3.
   - Codice legacy resta presente ed eseguibile se referenziato (MEDIUM).

3. **Esistono ancora path paralleli?**
   - **Sì**: almeno su `request_place_bet` (RunManager + BetManager receiver).
   - Lookup opzionale `bet_manager` in UI amplia la superficie.

4. **Il runtime è deterministico?**
   - **Non completamente determinabile staticamente** (UNCERTAIN).
   - Strutturalmente migliorato sul single-authority degli output `run_*`, ma i path paralleli intent riducono la garanzia di determinismo assoluto.
