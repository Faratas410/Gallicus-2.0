# Gallicus 2.0 - Repo Review (Ottimizzazione/Tweak)
Data: 2026-03-04

## Scope e metodo
- Review statica su `scripts/`, `ui/`, `scenes/`.
- Focus: bug/rischi comportamentali, robustezza wiring eventi, rumore runtime/logging, micro-ottimizzazioni.
- Nota: in questo ambiente non e presente `python`, quindi i test in `scripts/ci/test_*.py` non sono stati eseguiti.

## Findings (ordinati per severita)

### 1) [Alta] `FlowLogger` bypassa livello log e buffer nei metodi piu usati
- File: `scripts/systems/run/flow_logger.gd:49`, `scripts/systems/run/flow_logger.gd:52`, `scripts/systems/run/flow_logger.gd:55`
- Problema:
  - `log_phase`, `log_request`, `log_ui` usano `print(...)` diretto.
  - Non rispettano `level == OFF`.
  - Non passano da `_append(...)`, quindi `dump_last(...)` non contiene queste righe.
- Impatto:
  - Rumore log in runtime/release.
  - Diagnostica incompleta proprio nei path di fase/request/UI che servono durante incident analysis.
- Tweak consigliato:
  - Far convergere questi tre metodi su `log(...)` (o helper interno unico) per avere gating + buffering uniforme.

### 2) [Media] Validazione segnali e wiring non allineati (rischio regressioni silenziose)
- File: `scripts/systems/run_manager.gd:1037`, `scripts/systems/run_manager.gd:1150`
- Problema:
  - `_connect_gameevents()` prova a collegare ~30+ segnali.
  - `_validate_game_events_signals()` ne valida solo un sottoinsieme ridotto.
  - In `_connect_gameevents`, diversi binding con `requires_has_signal = false` possono degradare silenziosamente se un segnale manca/renaming.
- Impatto:
  - Possibili regressioni non intercettate a boot (feature che smette di reagire senza fail esplicito).
- Tweak consigliato:
  - Unificare sorgente di verita dei segnali richiesti (es. derivare validation dalla tabella `bindings`).
  - Per i segnali core, fallire con errore esplicito invece di skip silenzioso.

### 3) [Bassa] Doppio reset consecutivo in `_on_run_started`
- File: `scripts/ui/ui_root.gd:743`, `scripts/ui/ui_root.gd:744`
- Problema:
  - `_reset_bet_confirmation()` e invocato due volte di fila.
- Impatto:
  - Overhead minimo, ma indica possibile refactor incompleto e rende il flusso meno chiaro.
- Tweak consigliato:
  - Mantenere una sola chiamata.

### 4) [Bassa] Logging non condizionato in bootstrap/runtime
- File: `scripts/ui/ui_root.gd:488`, `scripts/systems/run_manager.gd:992`
- Problema:
  - `print(...)` sempre attivi in init (`UI ready`, `RunManager ready`) e altri punti runtime.
- Impatto:
  - Log noise e costo I/O evitabile nelle run normali.
- Tweak consigliato:
  - Spostare su `print_debug(...)` o guardia `OS.is_debug_build()`.

## Ottimizzazioni pragmatiche (quick wins)
1. Normalizzare logging (`FlowLogger`) in un singolo path con:
   - rispetto `level`,
   - append su buffer,
   - output condizionato debug.
2. Consolidare contratto segnali:
   - unica tabella segnali,
   - check esplicito dei mandatory a boot.
3. Pulizia micro-debiti:
   - rimuovere reset duplicato in `ui_root.gd`,
   - ridurre `print` non essenziali.

## Proposta di priorita implementativa
1. Fix `FlowLogger` (alto valore su osservabilita e noise).
2. Allineamento validation/wiring segnali in `RunManager`.
3. Cleanup minori (`_reset_bet_confirmation` duplicato + log bootstrap).
