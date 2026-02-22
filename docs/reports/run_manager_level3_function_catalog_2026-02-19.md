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

## B) Tabella purge RunManager (organizzata)

> Nota: catalogazione statica; nessuna rimozione in questa patch.

### Dead End
Funzioni senza riferimenti nel repo e senza ruolo attivo nel flow Level 3 osservato.

| Funzione | Tipo | Nota |
| --- | --- | --- |
| `_register_level3_bet_choice(bet_id)` | Private helper | Nessun call-site rilevato. |
| `_determine_level3_ending_id()` | Private helper | Nessun call-site rilevato. |
| `_has_used_bet(bet_id)` | Private helper | Nessun call-site rilevato. |
| `_try_register_irreversible_bet_scar(bet_id)` | Private helper | Nessun call-site rilevato. |
| `_get_bet_chain_doom_scale(chain_level)` | Private helper | Nessun call-site rilevato. |
| `_apply_bet_result(result)` | Private helper | Nessun call-site rilevato. |
| `restart_run(preserve_coins = true)` | Public API | Apparentemente non consumata nel repo. |
| `handle_bet_failed(bet_id)` | Public API | Apparentemente non consumata nel repo. |
| `get_pact_reveal_line(pact_id)` | Public API | Apparentemente non consumata nel repo. |

### Level 3
Funzioni collegate esplicitamente a semantica Level 3 e quindi da validare con cautela prima di qualsiasi purge.

| Funzione | Tipo | Nota |
| --- | --- | --- |
| `_register_level3_bet_choice(bet_id)` | Private helper | Nome e dominio L3: verificare eventuali call dinamiche prima di rimozione. |
| `_determine_level3_ending_id()` | Private helper | Potenziale legame con finale L3 anche se non referenziata staticamente. |
| `_try_register_irreversible_bet_scar(bet_id)` | Private helper | Dominio scar/rituale L3: richiede smoke dedicato se candidata purge. |

### Unknown
Elementi che richiedono verifica manuale ulteriore (duplicazioni o stato già variato).

| Funzione | Tipo | Nota |
| --- | --- | --- |
| `_parse_stringname_array(items)` | Private helper | Duplicata funzionalmente rispetto a parser in `run_state.gd`; verificare assenza uso riflessivo. |
| `_get_enemy_profile_def(profile_id)` | Private helper | Duplicata concettualmente con helper in `outcome_system.gd`; verificare dipendenze legacy tool/runtime. |
| `get_coins()` | Public API | Già rimossa in patch precedente (`REMOVED (PATCH 13)`), mantenuta come traccia storica catalogo. |

---

## C) Funzioni con falso positivo “0 call dirette” ma necessarie
Non catalogate come inutili perché attivate indirettamente:
- `_on_smoke_driver_tick`, `_smoke_quit_gate` (timer/deferred call).
- `_on_request_*`, `_on_bet_*`, `_on_modal_*`, `_on_wave_started`, `_on_player_spawned`, `_on_enemy_killed` (connect su `GameEvents`/runtime signals).
- `[removed_post_bet_queue_callback]`, `_force_post_bet_choice_fallback` (wiring su coda messaggi arena).

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
