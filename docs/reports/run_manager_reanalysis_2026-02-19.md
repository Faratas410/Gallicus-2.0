# RunManager — Re-analisi di frammentazione (2026-02-19)

## Contesto e vincoli (Level 3)
- Target: `res://scripts/systems/run_manager.gd`.
- Obiettivo: individuare **solo** punti candidati a frammentazione/ottimizzazione strutturale senza introdurre autorità di flusso parallela.
- Invarianti preservati: un solo `RunManager`, `GameEvents` unica authority eventi globali, UI reattiva.

## Osservazioni oggettive
- Il file è attualmente molto esteso (**5180 linee**).
- Sono presenti molte responsabilità eterogenee nello stesso modulo: flow authority, save/continue payload boundary, orchestrazione arena/player, payload UI, scar/register tracking, debug/smoke.
- Le funzioni `request_*`, i gate di fase (`_guard_*`, `_require_phase`) e il cambio fase restano il nucleo da **non estrarre**.

## Cosa si può frammentare (ordine consigliato, minimo rischio)

### 1) Save/Continue boundary helper (priorità alta)
**Motivo:** blocco ad alta densità dati ma con logica quasi pura (serialize/parse/apply payload).

**Candidati:**
- `_autosave_run_checkpoint`
- `_apply_run_save_payload`
- `_resume_run_from_save`
- helper di serializzazione/parsing (`_serialize_*`, `_parse_*`, `_apply_scars_detail`, `_parse_pacts_log`)

**Strategia minima:**
- Nuovo helper `scripts/systems/run/run_save_boundary_helper.gd` con API pura su `Dictionary/Array`.
- `RunManager` mantiene solo orchestrazione e guardie fase.

### 2) Arena theme + special arena policy (priorità media)
**Motivo:** è dominio “policy/content progression” più che autorità di stato.

**Candidati:**
- `_get_available_arena_theme_ids`, `_pick_next_arena_theme`, `_emit_arena_theme_changed`
- `_pick_special_arena_index`, `_maybe_activate_special_arena`, `_emit_special_arena_started`
- `_get_special_arena_title`, `_get_special_arena_description`

**Strategia minima:**
- Helper `run_arena_theme_policy.gd` stateless/state-light.
- `RunManager` invoca policy e conserva le emissioni finali critiche.

### 3) UI payload builders (priorità media)
**Motivo:** blocco prevalentemente di composizione dati per UI reattiva.

**Candidati:**
- `_build_intermediate_choice_ui_payload`, `_build_push_luck_ui_payload`
- `_build_phase_ui_payload`, `_build_push_luck_payload`
- `_build_sentence_payload`, `_get_sentence_rule`, `_get_sentence_doom`

**Strategia minima:**
- Factory dedicata (es. `run_ui_payload_factory.gd`) già allineata al principio “UI reattiva, logica fuori UI”.

### 4) Scar/register annotation policy (priorità medio-bassa)
**Motivo:** logica coerente ma separabile in policy domain-specific.

**Candidati:**
- valutazioni e annotazioni registro/scar non direttamente necessarie al phase switch core.

**Strategia minima:**
- estrarre solo la parte di generazione annotation text/metrics verdict.
- lasciare in `RunManager` trigger, timing ed emissione eventi.

## Cosa NON frammentare
- `request_*` public API del RunManager.
- Guardie di fase (`_guard_request_phase`, `_require_phase`, `_guard_phase`).
- Entry/exit di fase e dispatch principale.
- Emissioni finali di run-end e fail authority.

## Ottimizzazioni “safe” non-architetturali
- Ridurre lookup ripetuti su nodi con cache locale validata (senza cambiare flow).
- Compattare mapping statici in moduli catalog già esistenti (dove già preloadati), evitando duplicazioni nel manager.
- Consolidare logging/debug helper in modulo dedicato mantenendo call-site invariati.

## Sequenza patch consigliata (una patch per task)
1. Estrarre Save/Continue boundary helper.
2. Estrarre Arena theme/special arena policy.
3. Estrarre UI payload builders.
4. Estrarre Scar/Register annotation policy.

Ogni step deve mantenere:
- nessuna nuova authority di flusso,
- nessuna mutazione delle transizioni canoniche,
- nessun cambiamento di comportamento runtime visibile.

## Esito
- La frammentazione è possibile, ma solo per **domini di supporto**.
- Il cuore del RunManager deve restare unico per rispettare i vincoli di authority Level 3.
