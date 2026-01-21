# Gallicus — Repo Map (sintetica)

## 1) Repo Tree (alto livello)
```
res://
  assets/
    arenas/
    backgrounds/
    fonts/
    fx/
    sprites/
    tiles/
    ui/
  data/
    bets.gd
  scenes/
    Main.tscn
    UI.tscn
    Arena.tscn
    Player.tscn
    arenas/
      Arena_01_TrainingYard.tscn
      Arena_02_OwlSanctum.tscn
      Arena_03_SandPit.tscn
      Arena_04_IronCorridor.tscn
    enemies/
      EnemyBasic.tscn
    pickups/
      Pickup_Coins.tscn
      Pickup_Heal.tscn
      Pickup_SpeedBoost.tscn
    ui/
      BettingCircle.tscn
      EnemyHealthBar.tscn
    legacy/
      Enemy.tscn
  scripts/
    systems/
      run_manager.gd
      bet_manager.gd
      game_events.gd
      save_manager.gd
      constants.gd
    ui/
      ui_root.gd
      betting_circle_ui.gd
      enemy_health_bar.gd
    entities/
      enemy_basic.gd
    pickups/
      Pickup.gd
      PickupSpawner.gd
    Arena.gd
    Player.gd
    arena_tilemap.gd
    legacy/
      enemy_legacy.gd
      player_legacy.gd
```

## 2) Mappa dei sistemi (Responsibilities)

### RunManager
**Path:** `res://scripts/systems/run_manager.gd` (istanziato in `res://scenes/Main.tscn`, group `run_manager`)

**Owns:**
- Stato della run (seed, arena index, escalation, scars, bets, progressione).
- Creazione e wiring di Arena/Player (scene preloadate).
- Ciclo di gioco: start/run fail, arena start/complete, payout/ricompense.
- Emissione eventi globali (GameEvents) per UI e altri sistemi.
- Validazioni base su GameEvents e conteggio RunManager.

**Calls:**
- Istanzia `Arena.tscn` e `Player.tscn`.
- Chiama BetManager se presente (`get_node("BetManager")`).
- Legge/aggiorna dati da `GameConstants`.

**Emits (GameEvents):** run_started, run_failed, arena_started, arena_completed, bet_* (ui/open/close/place), coins_changed, tokens_changed, xp/level/difficulty_* e altri (vedi `game_events.gd`).

**Listens:** request_* signals da UI (request_place_bet, request_reset_run, request_retry_run, request_push_luck_*), bet_* signals (bet_placed, bet_selected, bet_confirmed), enemy_killed, modal_opened/closed.

---

### GameEvents (Event Bus)
**Path:** `res://scripts/systems/game_events.gd` (autoload)

**Owns:**
- Bus globale di segnali per run, UI e gameplay.
- Stato `gameplay_enabled` condiviso.

**Calls:**
- Nessuno: solo segnali e setter per `gameplay_enabled`.

**Emits (GameEvents):** Tutti i segnali dichiarati qui sono il contratto globale.

**Listens:**
- Nessuno (è l’hub).

---

### BetManager
**Path:** `res://scripts/systems/bet_manager.gd`

**Owns:**
- Caricamento dati scommesse da `res://data/bets.gd`.
- Stato scommessa attiva e valutazione esito.
- Wiring con player e arena (group `player`/`arena`).

**Calls:**
- RunManager (se presente) per `handle_bet_failed`.
- Arena/Player via segnali per danni/diff.

**Emits (GameEvents):** bet_ui_opened, bet_opened/closed, bet_placed, bet_ui_closed, run_failed (fallback).

**Listens:** player_damaged, request_place_bet, request_open_bet_ui.

---

### Arena
**Path:** `res://scripts/Arena.gd` (scene `res://scenes/Arena.tscn`)

**Owns:**
- Spawn player e nemici, gestione wave e conteggi.
- Applica scaling difficoltà ai nemici.
- Visuals di arena (background variant).

**Calls:**
- Spawna `Player.tscn` e `EnemyBasic.tscn`.
- Chiama metodi sugli enemy (`apply_difficulty`, `set_ai_locked`).

**Emits:** player_spawned, wave_started/cleared, enemy_spawned/ despawned, enemy_count_changed.

**Listens (GameEvents):** run_started, run_failed, difficulty_tier_changed.

---

### Player
**Path:** `res://scripts/Player.gd` (scene `res://scenes/Player.tscn`)

**Owns:**
- Input, movimento e attacchi.
- HP/ danni/ morte.
- Lock input via `gameplay_enabled`.

**Calls:**
- GameEvents.set_gameplay_enabled (solo listen/lock).
- Attacco verso nemici (hit / damage).

**Emits:** health_changed, took_damage, died.

**Listens (GameEvents):** gameplay_enabled_changed.

---

### Enemy (Basic)
**Path:** `res://scripts/entities/enemy_basic.gd` (scene `res://scenes/enemies/EnemyBasic.tscn`)

**Owns:**
- AI semplice (chase + touch damage).
- HP e morte.
- Scaling difficoltà.

**Calls:**
- GameEvents.enemy_killed (su death).
- Player `take_damage`.

**Emits:** health_changed, died.

**Listens:** Nessun GameEvents (solo chiamate da Arena/RunManager).

---

### UI Root
**Path:** `res://scripts/ui/ui_root.gd` (scene `res://scenes/UI.tscn`)

**Owns:**
- HUD, modali, overlay, debug tools.
- Binding di etichette/controlli UI.
- Presentazione scommesse e modali rituali.

**Calls:**
- Emissione *request_* via GameEvents (azioni utente).
- Spawna `BettingCircle.tscn` e `EnemyHealthBar.tscn` quando necessario.

**Emits (GameEvents):** request_* (purchase token, set seed, reset run, push luck, place bet).

**Listens (GameEvents):** run_started/failed, bet_* signals, coins/tokens/xp/level, special_arena_started, run_debug_state_updated, run_log_ready, etc.

---

### Pickups & Spawner
**Path:** `res://scripts/pickups/Pickup.gd`, `res://scripts/pickups/PickupSpawner.gd` (+ scenes `res://scenes/pickups/*`)

**Owns:**
- Pickup consumabili (coins/heal/speed) e loro spawn.

**Calls:**
- RunManager via group `run_manager` (per gating/logic di run).

**Emits/Listens (GameEvents):** da verificare.

---

### SaveManager (autoload)
**Path:** `res://scripts/systems/save_manager.gd`

**Owns:**
- Stub per salvataggi (attualmente vuoto).

**Emits/Listens:** da verificare.

---

### GameConstants
**Path:** `res://scripts/systems/constants.gd`

**Owns:**
- Costanti globali (valori base player/enemy/arena/run).

**Emits/Listens:** N/A.

## 3) Invariants & “Stop doing”

### Invariants (non negoziabili)
- Godot **4.5.1**, GDScript **strict typed**, **zero warnings**.
- **Un solo RunManager** autorevole in `res://scripts/systems/run_manager.gd`, presente nel group `run_manager`.
- **Entry point**: `res://scenes/Main.tscn` avvio pulito.
- **Eventi globali** solo tramite singleton `GameEvents`.
- **UI “reactive only”**: UI ascolta eventi, azioni utente passano tramite `request_*` su GameEvents.
- **Node groups standard**: `run_manager`, `arena`, `player`, `enemies`.

### Stop doing (anti-pattern)
- UI che modifica direttamente stato di run/player (bypassando GameEvents).
- Duplicare RunManager o introdurre manager legacy paralleli.
- Hardcoding di node path fragili fuori da `Main.tscn`/RunManager.
- Emissione di segnali globali fuori da `GameEvents`.

## 4) Entry points & wiring

- **Main scene:** `res://scenes/Main.tscn`.
  - Contiene `RunManager` (script `run_manager.gd`, group `run_manager`) e `UI` (istanza `UI.tscn`).
- **Autoloads (project.godot):**
  - `GameEvents` → `res://scripts/systems/game_events.gd`
  - `SaveManager` → `res://scripts/systems/save_manager.gd`
- **Arena/Player instantiation:** gestiti da RunManager tramite `arena_scene` e `player_scene`.

## 5) Debug playbook (super breve)

1. **Parse/type error (strict typing)**
   - Controlla `scripts/systems/run_manager.gd` e il file toccato di recente; verifica signature e tipi.
2. **API mismatch Godot 4.x**
   - Cerca usage di API legacy in `scripts/legacy/` o metodi deprecati.
3. **Signal signature mismatch**
   - Verifica `GameEvents` signals in `scripts/systems/game_events.gd` e connessioni in `run_manager.gd`/`ui_root.gd`.
4. **Group mismatch / node path resolution**
   - Verifica gruppi in `Main.tscn`, `Arena.gd`, `Player.gd`, `enemy_basic.gd`.
5. **Init order / null reference**
   - Controlla `_ready()` e `get_node_or_null` in `run_manager.gd` e `ui_root.gd`.
6. **GameEvents misuse**
   - Verifica che i trigger globali passino da `GameEvents` e non da segnali custom fuori dall’autoload.
