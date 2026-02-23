# CHECK — Sigilla Patto → INTERMEDIATE_CHOICE

## Domande di verifica (ordine runtime)

1. **Dopo Sigilla Patto viene emesso `pact_sealed_closed`?**
   - **Sì.** In `_start_pact_sealed_ritual`, dopo timer `PACT_SEALED_SECONDS`, RunManager emette `GameEvents.pact_sealed_closed.emit()`.

2. **Dopo `pact_sealed_closed` viene chiamato `set_phase(INTERMEDIATE_CHOICE)`?**
   - **Parzialmente (importante):** viene chiamata `_open_intermediate_choice(bet_id)` che usa **`_set_phase(RunPhase.INTERMEDIATE_CHOICE, ...)`**, non `set_phase(...)`.
   - Il metodo pubblico `set_phase(...)` è un legacy backdoor e rifiuta la mutazione (errore/assert), quindi il flow corretto passa sempre da `_set_phase`.

3. **Dopo `_set_phase` viene emesso `phase_changed`?**
   - **No.** Nel contratto corrente non esiste un segnale `phase_changed` in `GameEvents`; esiste `run_phase_changed(phase: int)` ma viene emesso solo da `_set_runtime_gate_phase(...)`, non da `_set_phase(...)`.

4. **La UI riceve il segnale/payload?**
   - **Sì.** La UI collega `pact_sealed_closed` a `_on_pact_sealed_closed`.
   - Per il cambio fase visivo, RunManager usa `_emit_ui(...)` e chiama `apply_run_ui_payload(payload)` su UI root; la UI poi esegue `show_phase(payload.phase)`.

5. **UI: il match usa `RunPhase.NAME` o numeri?**
   - **Numeri (int) via costanti contrattuali.** `ui_root.gd` mappa le fasi con costanti `RUN_PHASE_*` derivate da `RunPhaseContract` e `show_phase(phase: int)` usa una mappa `Dictionary` int→nodo.

6. **Esiste nodo `Phase_INTERMEDIATE_CHOICE` in scena?**
   - **No, naming attuale: `Phase_MID_CHOICE`.**
   - `RunPhaseContract.INTERMEDIATE_CHOICE` è collegata alla UI alias `RUN_PHASE_MID_CHOICE`, che punta al nodo `UI_RunRoot/Phase_MID_CHOICE`.

## Conclusione rapida
- La catena corretta è:
  - Sigilla → `pact_sealed_opened`
  - timer → `pact_sealed_closed`
  - `_open_intermediate_choice` → `_set_phase(INTERMEDIATE_CHOICE)`
  - `_emit_ui(payload)` → UI `apply_run_ui_payload` → `show_phase(INTERMEDIATE_CHOICE)` su nodo `Phase_MID_CHOICE`.
