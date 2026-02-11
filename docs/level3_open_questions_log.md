# Gallicus — Level 3 Open Questions Log

Documento tecnico di rischio/ambiguità. Non definisce il canone: raccoglie elementi da verificare o isolare.

## SECTION A — Architectural Ambiguities

| File path | Why suspicious | Referenced in active scenes | Risk | Suggested action |
|---|---|---|---|---|
| `res://scripts/Arena.gd` | Contiene logica gameplay-like (wave loop, enemy spawn, aggro delay, player spawn, gestione nemici) e istanzia scene runtime. | **SÌ** (`RunManager` pre-carica `Arena.tscn`; `Main` istanzia `RunManager`). | HIGH | Refactor passive (visual-only hard guarantee) + verify manually. |
| `res://scripts/Player.gd` | Contiene input/combat state machine, timer di attacco/dodge, danno/morte locale e `request_fail_run` su morte. | **SÌ** (`RunManager` pre-carica `Player.tscn`). | HIGH | Keep visual only in Level 3 oppure separare runtime non-L3; verify manually. |
| `res://scripts/entities/enemy_basic.gd` | AI chase/touch damage/death + emissione `enemy_killed`; comportamento gameplay se attivo. | **SÌ** (`Arena.gd` lo istanzia da `EnemyBasic.tscn`). | HIGH | Refactor passive for Level 3 o confinare fuori path L3. |
| `res://scripts/systems/bet_manager.gd` | Sistema parallelo a RunManager: apre/chiude bet UI, valuta bet, può emettere `request_fail_run`; inoltre discovery dinamica di arena/player. | **NO in Main scene** (`Main.tscn` non istanzia `BetManager`), ma `RunManager` cerca `BetManager` con `get_node_or_null`. | HIGH | Remove oppure mantenere inattivo e verificare manualmente che non venga mai istanziato. |
| `res://scripts/pickups/PickupSpawner.gd` | Spawn loop con timer (`create_timer`) + instantiate dinamico di pickup. | **UNCERTAIN** (nessuna istanza trovata staticamente nelle scene principali). | MEDIUM | Verify manually; se non usato in L3 rimuovere dal runtime L3. |
| `res://scripts/pickups/Pickup.gd` | Effetti gameplay (heal/speed/coins request) su collisione; guardia `_is_level3_mode()` presente ma meccanica resta legacy. | **UNCERTAIN** (scene pickup esistono, istanziazione runtime non osservata nel flow principale). | MEDIUM | Keep out of Level 3 runtime oppure remove. |
| `res://scripts/legacy/player_legacy.gd` | Gameplay completo legacy + `request_fail_run` emesso fuori RunManager. | **NO** (non referenziato staticamente da scene principali). | MEDIUM | Remove o archivio esplicito non-runtime. |
| `res://scripts/legacy/enemy_legacy.gd` | AI/danno/morte legacy. | **NO** (non referenziato staticamente da scene principali). | LOW | Remove o archivio esplicito non-runtime. |
| `res://scenes/legacy/Enemy.tscn` | Scena legacy deprecata che può riaprire path non-L3 se riutilizzata. | **NO** (nessuna istanza statica rilevata). | LOW | Remove o mantenere in archivio fuori runtime. |

### Additional event-integrity notes (outside RunManager)
- `request_fail_run` è emesso anche da `Player.gd`, `legacy/player_legacy.gd` e `bet_manager.gd` (non solo da intent UI).
- `bet_*` (opened/closed/placed) può essere emesso anche da `bet_manager.gd` (path parallelo).
- Emissioni `run_started/run_failed/run_ended/run_finale_selected` fuori `RunManager`: **non rilevate staticamente**.
- Caricamenti dinamici esterni al repository/scenes non ispezionabili staticamente: **UNCERTAIN**.

## SECTION B — Flow Integrity Risks

- **Fallback/parzialità bet flow:** `RunManager` include compatibilità multipla (`bet_selected` e `request_place_bet`) e ricerca opzionale di `BetManager`; rischio di percorso non univoco se BetManager viene istanziato accidentalmente.
- **Discovery dinamica nodi:** uso diffuso di `get_first_node_in_group(...)`, `find_child(...)`, `get_node_or_null(...)` (es. spawn/player/camera/BetManager) può introdurre comportamento dipendente dalla composizione scena.
- **Path legacy ancora presenti:** sistemi legacy/pickup non rimossi possono riattivarsi se inclusi in scene future senza vincolo Level 3 esplicito.
- **Debug intents runtime:** eventi debug (`request_reset_run`, `request_set_run_seed`, `request_skip_arena_resolution`) sono collegati in UI; utile per tooling ma da segregare in release policy.

## SECTION C — UI-Level Risks

- `UIRoot` mantiene intent legacy/non-core (`request_next_bet`, debug seed/reset/skip): possibile mismatch semantico con un flow Level 3 strettamente lineare.
- Label/testi UI includono concetti legacy/misti (es. naming bet storici e mapping multipli) che possono non essere allineati a una nomenclatura canone unica.
- `MainMenu` contiene pannelli extra (archivio/credits/settings) non problematici di per sé, ma la coesistenza con intent gameplay multipli richiede verifica di coerenza UX con il canone Level 3.
- Verifica statica non garantisce assenza di wiring runtime da scene non caricate nel percorso principale: **UNCERTAIN**.
