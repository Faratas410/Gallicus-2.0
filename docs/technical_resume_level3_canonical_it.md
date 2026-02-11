# Gallicus — Technical Resume (ITALIANO) · Level-3 Canonical

## A) Come funziona il gioco (Level 3)

### Autorità e confini
- **Autorità unica della run**: `RunManager` in `res://scripts/systems/run_manager.gd`, con `add_to_group("run_manager")` in `_ready()`.  
- **Event bus globale unico**: `GameEvents` autoload (`project.godot`), usato per intent (`request_*`) e aggiornamenti di stato.  
- **UI reattiva**: `UIRoot` e `MainMenu` ascoltano eventi e inviano richieste; non decidono outcome di run.

### State machine / fasi (owner: RunManager)
Fasi dichiarate in `RunPhase`:
- `MAIN_MENU`
- `RUN_INIT`
- `BET_PRESENT`
- `BET_COMMITTED`
- `POST_BET_MESSAGES`
- `INTERMEDIATE_CHOICE`
- `PUSH_YOUR_LUCK`
- `NEXT_BET`
- (`PREP`, `LIVE`, `GAME_OVER` come stati operativi)

Flow Level-3 effettivo:
1. **Avvio run**
   - Intent UI: `request_new_run` / `request_continue_run`.
   - `RunManager._start_level3_run()` resetta stato run, emette `run_started`, aggiorna monete, imposta `PREP`, poi entra in `start_arena()`.
2. **Bet offer**
   - `RunManager._open_level3_bet_ui()` mette `BET_PRESENT`, emette `betting_opened`, `bet_ui_opened`, `bet_opened`.
3. **Scelta patto**
   - UI emette `bet_selected` (o `request_place_bet` in path compatibile).
   - `RunManager` registra il patto (`BET_COMMITTED`), chiude UI bet (`bet_ui_closed`, `bet_closed`, `betting_closed`), poi avvia rituali.
4. **Rituali post-firma**
   - `pact_sealed_opened` → timeout → `pact_sealed_closed`.
   - `resolve_ritual_opened(payload)` → timeout → `resolve_ritual_closed`.
5. **Risoluzione arena (authoritative)**
   - `RunManager` emette `arena_started`, calcola esito con `_resolve_level3_arena()`, poi emette `arena_completed`.
   - Applica reward/penalty/scars nel manager.
6. **Scelta intermedia + Push Your Luck**
   - `intermediate_choice_opened` → UI invia `request_intermediate_choice`.
   - `push_luck_opened(payload)` → UI invia `request_push_luck_cashout` o `request_push_luck_double`.
7. **Transizione finale della run**
   - Se cashout/fallimento/chiusura: `RunManager` entra in end flow (`GAME_OVER`) ed emette `run_finale_selected`, `run_ended`, `run_failed` (quando applicabile).

### Request GameEvents esistenti e chi le emette
> Nota: qui sono inclusi i `request_*` dichiarati in `GameEvents`; per quelli senza emitter nel repo corrente è segnato **UNCERTAIN**.

- `request_new_run`: emesso da `MainMenu`, `UIRoot`.
- `request_continue_run`: emesso da `MainMenu`.
- `request_retry_run`: emesso da `UIRoot`.
- `request_show_main_menu`: emesso da `UIRoot`.
- `request_place_bet`: emesso da `UIRoot`.
- `request_intermediate_choice`: emesso da `UIRoot`.
- `request_push_luck_cashout`: emesso da `UIRoot`.
- `request_push_luck_double`: emesso da `UIRoot`.
- `request_next_bet`: emesso da `UIRoot` (path non-L3 / fallback).
- `request_reset_run`: emesso da `UIRoot` (debug).
- `request_set_run_seed`: emesso da `UIRoot` (debug/tools).
- `request_clear_run_seed`: emesso da `UIRoot`.
- `request_skip_arena_resolution`: emesso da `UIRoot` (debug).
- `request_purchase_token`: emesso da `UIRoot`.
- `request_add_coins`: emesso da `Pickup` (solo path pickup, bloccato in L3 da `_is_level3_mode()`).
- `request_fail_run`: emesso da `legacy/player_legacy.gd` e `BetManager` legacy/fallback.
- `request_purchase_upgrade`: **UNCERTAIN** (segnale dichiarato, emitter non trovato nel repo).
- `request_open_bet_ui`: **UNCERTAIN** (segnale dichiarato, emitter non trovato nel repo).
- `request_consume_upgrade_shop`: **UNCERTAIN** (segnale dichiarato, emitter non trovato nel repo).

### UI flow (reattiva) — cosa appare e trigger
- **Main menu**: visibile all’avvio; i pulsanti emettono intent (`request_new_run`, `request_continue_run`).
- **HUD run**: si aggiorna su `run_started`, `coins_changed`, `escalation_changed`, `arena_theme_changed`, ecc.
- **Bet modal/panel**: appare su `bet_ui_opened`/`betting_opened`; si chiude su `bet_ui_closed`/`bet_closed`.
- **Pact sealed modal**: appare su `pact_sealed_opened`, sparisce su `pact_sealed_closed`.
- **Resolve ritual modal**: appare su `resolve_ritual_opened(payload)`, sparisce su `resolve_ritual_closed`.
- **Intermediate choice modal**: appare su `intermediate_choice_opened`, invia `request_intermediate_choice`.
- **Push-luck modal**: appare su `push_luck_opened(payload)`, invia `request_push_luck_cashout` / `request_push_luck_double`, si chiude su `push_luck_closed`.
- **End/Verdetto**: UI aggiornata da `run_finale_selected`, `run_ended`, `run_log_ready`, `run_failed`.

---

## B) Legacy / Suspect systems

| File | Perché viola/è sospetto rispetto a Level-3 | Referenziato ora? | Azione suggerita |
|---|---|---|---|
| `scripts/systems/bet_manager.gd` | Sistema bet parallelo (`group bet_manager`), valuta outcome e può emettere `request_fail_run` fuori da RunManager. Invariante “single authority” indebolita. | **Parzialmente**: RunManager cerca nodo `BetManager`, ma `Main.tscn` non lo istanzia. | **Refactor a passive helper** o **delete** se non usato. |
| `scripts/Arena.gd` | Contiene spawn wave/nemici, aggro delay, reset arena, quindi decisioni gameplay runtime locali (non solo visual). | **Sì**: `scenes/Arena.tscn` + `RunManager` preloaded `arena_scene`. | Ridurre a **view-layer passivo**; lasciare solo visual/fx e comandi ricevuti da RunManager. |
| `scripts/Player.gd` | Contiene input combattimento, danno, attacchi, morte locale. In L3 viene disattivato (`_is_level3_mode`), ma il codice resta decisionale. | **Sì**: `scenes/Player.tscn` + `RunManager` preloaded `player_scene`. | Mantenere solo visual in L3 o separare runtime non-L3. |
| `scripts/entities/enemy_basic.gd` | AI chase + touch damage + morte/exp; in L3 process viene spento ma resta gameplay attivo nel file. | **Sì**: `scenes/enemies/EnemyBasic.tscn`, `Arena` lo istanzia. | Versione **passiva/visual-only** per L3 oppure branch separato non-L3. |
| `scripts/pickups/PickupSpawner.gd` | Sistema spawn periodico con timer (`create_timer`) e logica gameplay pickup. | **No evidente**: non instanziato in scene principali. | Se non previsto in L3: **delete** o archivio legacy. |
| `scripts/pickups/Pickup.gd` | Effetti gameplay (heal/speed/coins via request). Ha guardia L3 ma resta meccanica legacy. | **Indiretto**: usato da scene pickup, ma pickup scene non risultano instanziate nel flow principale. | Tenere solo fuori L3 o rimuovere dal build L3. |
| `scripts/legacy/player_legacy.gd` | Player completo legacy, emette `request_fail_run` fuori view-layer. | **No**: non referenziato in scene correnti. | **Delete** o congelare come archivio. |
| `scripts/legacy/enemy_legacy.gd` | Enemy legacy gameplay completo (AI/damage/exp). | **No**: non referenziato in scene correnti. | **Delete** o congelare come archivio. |
| `scenes/legacy/Enemy.tscn` | Scena legacy deprecata; può reintrodurre path gameplay vecchio. | **No** (nessuna istanza trovata). | **Delete** (o mantenere solo archivio non runtime). |

### Check specifico “run_* emessi fuori RunManager”
- **Non rilevati** emitter `GameEvents.run_started/run_failed/run_ended/run_finale_selected` fuori da `run_manager.gd` nel codice corrente.
- **UNCERTAIN**: eventuali scene/tool esterni non indicizzati o script caricati dinamicamente non osservati da ricerca statica.
