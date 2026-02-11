# GAL LICUS — Flow Ufficiale EA (Repo-Aligned Contract)

**Status:** SUPPORTING  
**Scope:** Repository-aligned Level 3 flow narrative and signal sequence reference.  
**Source of truth:** docs/flow_wiring_contract.md, docs/run_architecture_ledger.md  
**Last updated:** 2026-02-11  
**Notes:** Overlaps with: docs/game_flow_v2.md, docs/game_flow.md, docs/flow_wiring_contract.md.
- Candidate for archive after consolidation patch if fully subsumed by canonical flow contract.

## Overlap
- Overlaps with: docs/game_flow_v2.md, docs/game_flow.md, docs/flow_wiring_contract.md.
- Candidate for archive after consolidation patch if fully subsumed by canonical flow contract.

## Scopo
Documento canonico del flow “Level 3” implementato nel repo corrente.
Serve per debugging, prevenzione regressioni e memoria dei passaggi.

## Principi invarianti
1) RunManager è autorità di stato e progressione.
2) UI è reattiva (emette solo request_*).
3) Comunicazione cross-layer solo via GameEvents.
4) Il flow è implicito (funzioni + segnali), non esiste una state machine enum.

## Nomi reali (GameEvents)
- Avvio/continua: request_new_run, request_continue_run
- Betting: request_open_bet_ui, request_place_bet, bet_ui_opened, bet_placed
- Rituali: pact_sealed_opened/closed, resolve_ritual_opened/closed
- Arena: arena_started, arena_completed (emette solo arena_index)
- Post-arena: request_intermediate_choice, push_luck_opened,
  request_push_luck_cashout, request_push_luck_double
- Run end: run_finale_selected, run_failed
- Menu return: request_show_main_menu
- Save: SaveManager.clear_run() chiamato in end-run

---

## Flow canonico (ordine fisso)

### 0) MENU
STATE mentale: MENU_IDLE  
UI: menu principale  
UI → RunManager: request_new_run, request_continue_run

### 1) RUN START (Level 3)
STATE mentale: RUN_INIT  
RunManager: _start_level3_run() → run_started → start_arena()

### 2) ARENA SETUP
STATE mentale: ARENA_SETUP  
RunManager: start_arena():
- arena_index++
- tema/special arena
- profilo nemici
- apre betting Level 3

### 3) BET UI OPEN
STATE mentale: BET_OFFER  
RunManager → UI: bet_ui_opened  
UI → RunManager: request_place_bet(bet_id)

### 4) BET SELECTED + CHECKPOINT
STATE mentale: BET_SIGNED  
RunManager: select_bet():
- registra bets_history/condanne
- emette bet_placed
- chiude UI bet
- AUTOSAVE: RUN_FLOW_BET_SIGNED
- avvia rituali/risoluzione

### 5) RITUAL 1 — PACT SEALED
STATE mentale: PACT_SEAL_RITUAL  
RunManager → UI: pact_sealed_opened  
Chiusura: pact_sealed_closed emesso dal RunManager (timer/flow interno)

### 6) RITUAL 2 — RESOLVE RITUAL
STATE mentale: RESOLVE_RITUAL  
RunManager → UI: resolve_ritual_opened  
Chiusura: resolve_ritual_closed emesso dal RunManager

### 7) ARENA RESOLVE
STATE mentale: ARENA_RESOLVE  
RunManager:
- arena_started
- arena_completed(arena_index)
- applica outcome, aggiorna audience
AUTOSAVE: RUN_FLOW_INTERMEDIATE_CHOICE (subito dopo la risoluzione)

### 8) POST-ARENA — GESTURE
STATE mentale: POST_ARENA_GESTURE  
RunManager → UI: apertura scelta gesto  
UI → RunManager: request_intermediate_choice(placa|provoca)  
AUTOSAVE: RUN_FLOW_PUSH_LUCK

### 9) PUSH YOUR LUCK
STATE mentale: PUSH_LUCK  
RunManager → UI: push_luck_opened(payload)  
UI → RunManager:
- request_push_luck_cashout
- request_push_luck_double

Checkpoint:
- Double → AUTOSAVE RUN_FLOW_BET_OFFER e ritorno a ARENA_SETUP
- Cashout → end-run (nessun autosave; clear_run a fine)

### 10) RUN END — VERDETTO
STATE mentale: RUN_END_VERDICT  
RunManager:
- SaveManager.clear_run()
- run_finale_selected(payload)
- se loss: run_failed
UI:
- VERDETTO
- bottoni: Nuova Run / Torna al Menu (request_show_main_menu)

---

## Checkpoints autosave (canonici)
1) Dopo firma patto → RUN_FLOW_BET_SIGNED
2) Dopo risoluzione arena → RUN_FLOW_INTERMEDIATE_CHOICE
3) Dopo scelta gesto → RUN_FLOW_PUSH_LUCK
4) Dopo scelta Double → RUN_FLOW_BET_OFFER
5) End-run → clear_run()

---

## Bug hotspots
- Rituali: open senza close → softlock (timer/flow interno)
- Betting: mismatch segnali request_place_bet
- arena_completed senza payload outcome → UI deve derivare da RunState
- Legacy BetManager attivo insieme a Level 3 → flow misto (da evitare)

## Regola d’oro
Se una UI non appare: non è layout.  
È un open non emesso, un close non emesso o un listener non connesso.
