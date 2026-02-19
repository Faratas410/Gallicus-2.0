# RunManager L3 — Catalogazione funzioni necessarie vs candidati inutilizzati (senza rimozioni)

## Scopo
Catalogare le funzioni del `RunManager` in ottica **snellimento futuro** senza rimuovere nulla adesso.

## Metodo usato
1. Pre-flight canonico letto (PROCESS/RUN ARCHITECTURE/MECHANICS/GLOSSARY/LORE + repo map).
2. Censimento funzioni in `scripts/systems/run_manager.gd`.
3. Verifica riferimenti diretti interni (`name(`) e riferimenti esterni nel repository (`rg -F "name("`).
4. Distinzione tra:
   - callback indiretti (es. `signal.connect(_on_...)`, quindi necessari anche senza chiamata diretta);
   - API pubbliche usate da `scripts/ui/run_manager_ui_port.gd`;
   - funzioni senza riferimenti (candidate a legacy/debito tecnico).

## Esito sintetico
- **Core L3 necessario**: non emergono duplicazioni di authority (RunManager resta singola authority).
- **Funzioni candidate inutilizzate (osservazione statica)**: 12.
- **Funzioni con uso indiretto via segnali/timer**: presenti e da NON marcare come inutili.

---

## A) Necessarie per flow L3 (non candidate)
Queste categorie risultano coerenti con il canone Level 3 e con wiring runtime:
- Gate/phase authority (`_set_phase`, `_run_enter_phase`, `_enter_*`, `_guard_*`, request handlers).
- Wiring `GameEvents` (`_connect_gameevents` + `_on_request_*`/`_on_*` connessi a segnali).
- Boundary save/continue (`_autosave_run_checkpoint`, `_apply_run_save_payload`, `_resume_run_from_save`).
- UI reactive payload builders (`_build_*_ui_payload`, `_emit_ui`).
- API pubbliche usate dalla porta UI (`run_manager_ui_port.gd`): pact list/titles, arena themes, crowd counters, debug getters.

---

## B) Candidate “inutilizzate” (nessun riferimento rilevato nel repo)

> Nota: catalogazione statica; non rimosse.

### 1) Private helper senza call-site
1. `_register_level3_bet_choice(bet_id)`
2. `_parse_stringname_array(items)` *(duplicata funzionalmente rispetto a parser già presente in `run_state.gd`)*
3. `_get_enemy_profile_def(profile_id)` *(duplicata concettualmente con helper in `outcome_system.gd`)*
4. `_determine_level3_ending_id()`
5. `_has_used_bet(bet_id)`
6. `_try_register_irreversible_bet_scar(bet_id)`
7. `_get_bet_chain_doom_scale(chain_level)`
8. `_apply_bet_result(result)`

### 2) Public API apparentemente non consumate
9. `restart_run(preserve_coins = true)`
10. `get_coins()` — REMOVED (PATCH 13)
11. `handle_bet_failed(bet_id)`
12. `get_pact_reveal_line(pact_id)`

---

## C) Funzioni con falso positivo “0 call dirette” ma necessarie
Non catalogate come inutili perché attivate indirettamente:
- `_on_smoke_driver_tick`, `_smoke_quit_gate` (timer/deferred call).
- `_on_request_*`, `_on_bet_*`, `_on_modal_*`, `_on_wave_started`, `_on_player_spawned`, `_on_enemy_killed` (connect su `GameEvents`/runtime signals).
- `_on_arena_message_queue_completed`, `_force_post_bet_choice_fallback` (wiring su coda messaggi arena).

---

## D) Raccomandazione operativa (senza patch runtime)
Per snellire in sicurezza in patch successive (una patch = una rimozione/migrazione locale):
1. Confermare con test runtime se le 12 candidate non sono chiamate via `call("...")` da scene/tool esterni.
2. Rimuovere prima private helper isolate (semaforo verde).
3. Solo dopo valutare API pubbliche non usate (`restart_run`, `get_coins`, `handle_bet_failed`, `get_pact_reveal_line`) con verifica UI-port.
4. Dopo ogni rimozione: smoke flow L3 (menu → bet present → bet committed → post-bet → end run).

## Classificazione root-cause (per il problema di “codice pesante”)
- **Categoria**: `flow/state violation` **non rilevata**.
- **Stato reale**: debito tecnico da funzioni non referenziate / legacy residue.
