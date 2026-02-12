# Gallicus — Technical Resume (ITALIANO) · Level 3 Canonical

**Status:** SUPPORTING  
**Scope:** Italian technical summary of canonical Level 3 architecture and flow.  
**Source of truth:** docs/canon/RUN_ARCHITECTURE_CANON.md, docs/flow_wiring_contract.md  
**Last updated:** 2026-02-11  
**Notes:** Overlaps with: docs/technical_review_resume_it.md, docs/FLOW_OFFICIAL_EA.md.
- Candidate for archive after consolidation patch if a single technical summary is kept.

## Overlap
- Overlaps with: docs/technical_review_resume_it.md, docs/FLOW_OFFICIAL_EA.md.
- Candidate for archive after consolidation patch if a single technical summary is kept.

## Scope
Questo documento descrive **solo** il comportamento canonico Level 3 attivo.

## Invarianti architetturali (ufficiali)
- **Autorità unica della run:** `RunManager` (`res://scripts/systems/run_manager.gd`) è l’unico orchestratore del flow e degli esiti di gameplay.
- **Event bus globale unico:** ogni evento globale passa da `GameEvents` autoload (`res://scripts/systems/game_events.gd`).
- **Layer runtime passivi (Player/Arena/Enemies):** questi nodi eseguono rappresentazione/feedback visivo e ricevono direttive; non sono fonti autorevoli di avanzamento run.
- **UI esclusivamente reattiva:** `UIRoot` e `MainMenu` emettono intent (`request_*`) e riflettono stato/eventi; non calcolano outcome.

## Flusso canonico Level 3 (owner: RunManager)
1. **Start run:** riceve intent UI (`request_new_run` / `request_continue_run`), inizializza stato, emette `run_started`.
2. **Bet phase:** apre UI di scommessa (`betting_opened`, `bet_ui_opened`, `bet_opened`) e attende intent utente.
3. **Commit patto:** registra la scelta, chiude la UI bet (`bet_ui_closed`, `bet_closed`, `betting_closed`).
4. **Rituali:** emette `pact_sealed_opened/closed` e `resolve_ritual_opened/closed`.
5. **Arena resolution (authoritative):** emette `arena_started`, risolve con logica interna manager, emette `arena_completed`.
6. **Scelta intermedia / Push Your Luck:** apre modali (`intermediate_choice_opened`, `push_luck_opened`) e gestisce solo intent `request_*` provenienti dalla UI.
7. **End flow:** chiude run con eventi `run_finale_selected`, `run_ended` e `run_failed` (quando applicabile).

## Ruoli dei componenti
- **RunManager:** stato run, transizioni di fase, risoluzione esiti, reward/penalty/scars.
- **GameEvents:** trasporto segnali di intent/stato, senza logica di gameplay.
- **UI (`MainMenu`, `UIRoot`):** input utente → intent; rendering dello stato.
- **Arena / Player / Enemy:** presentazione visuale e feedback locale subordinato al manager.
