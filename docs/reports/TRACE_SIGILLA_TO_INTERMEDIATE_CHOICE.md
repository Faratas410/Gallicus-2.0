# Trace — Sigilla → Intermediate Choice

## Obiettivo
Verificare il percorso runtime tra click su **Sigilla** (UI betting circle) e apertura fase **INTERMEDIATE_CHOICE**.

## Sequenza verificata
1. `SigillaButton` invoca `_on_sigilla_pressed()` in `betting_circle_ui.gd`.
2. `_on_sigilla_pressed()` emette `GameEvents.bet_selected(bet_id)` e chiude il modal.
3. `UIRoot` riceve `bet_selected` e salva solo `_selected_bet_id` (stato UI locale).
4. La progressione di flow non passa da `bet_selected`: il RunManager avanza quando riceve le request di bet (`request_place_bet` / intro select+confirm), poi entra in risoluzione arena.
5. Dopo la risoluzione, il RunManager non apre subito INTERMEDIATE_CHOICE: mette in coda `[removed_post_bet_phase]` (`[removed_post_bet_queue_step]`).
6. Solo al termine della coda messaggi (o fallback timer), apre `INTERMEDIATE_CHOICE` con `_open_intermediate_choice`.

## Cosa c'è "in mezzo"
Tra Sigilla e Intermediate Choice c'è:
- emissione `bet_selected` (UI),
- fase di risoluzione/rituale arena,
- fase `[removed_post_bet_phase]` (prima reazione / queue),
- callback `[removed_post_bet_queue_signal]` oppure fallback timeout,
- quindi transizione a `INTERMEDIATE_CHOICE`.

## Conclusione operativa
Il passaggio non è diretto per design di flow: c'è una pipeline intermedia guidata da RunManager (risoluzione + coda messaggi post-bet) prima della scelta gesto.
