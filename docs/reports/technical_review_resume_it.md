# Gallicus 2.0 — Review tecnico (resume per presentazione)

**Status:** SUPPORTING  
**Scope:** Italian technical review snapshot of architecture, systems, and status.  
**Source of truth:** docs/canon/RUN_ARCHITECTURE_CANON.md, docs/repo_map.md  
**Last updated:** 2026-02-11  
**Notes:** Overlaps with: docs/technical_resume_level3_canonical_it.md, docs/repo_map.md.
- Candidate for archive after consolidation patch if merged into one maintained summary.

## Overlap
- Overlaps with: docs/technical_resume_level3_canonical_it.md, docs/repo_map.md.
- Candidate for archive after consolidation patch if merged into one maintained summary.

## 1) Cos’è il progetto in pratica
Gallicus è un action/arena game in Godot 4.6 costruito intorno a un loop di **scommessa → arena → giudizio → scelta di continuazione**, dove il cuore non è l’ottimizzazione ma il rischio crescente. L’autorità del flow è centralizzata nel `RunManager`, mentre UI e scene visuali reagiscono agli eventi senza decidere la logica. 

## 2) Architettura in 30 secondi
- **Entry point**: `res://scenes/Main.tscn`.
- **Nodi chiave all’avvio**:
  - `RunManager` (unico, group `run_manager`) 
  - `UI` (`UI.tscn`)
  - `MainMenu`
- **Bus eventi globale**: `GameEvents` autoload, usato per collegare sistemi e UI.

## 3) Game loop (operativo, non teorico)
### Fase A — Menu
Il giocatore parte dal menu e invia intent (`new run` o `continue`).

### Fase B — Start run
`RunManager` inizializza stato run, resetta progressione run-based, emette `run_started`, prepara la prima arena e l’offerta di patto/scommessa.

### Fase C — Bet / Patto
Il giocatore firma una scommessa (patto), che definisce condizione + rischio. Questo atto alimenta storico, condanne e checkpoint autosave.

### Fase D — Ritual layer
Il flow passa nei due rituali (`pact sealed` e `resolve ritual`) che fungono da cerniera narrativa/UX prima della risoluzione arena.

### Fase E — Arena resolve
La run processa l’arena, applica outcome (reward/penalty/scars), aggiorna stato pubblico/escalation e prepara scelta post-arena.

### Fase F — Scelta post-arena + Push Your Luck
Il giocatore sceglie gesto intermedio e poi decide:
- **Cashout**: chiude la run
- **Double**: rilancia e torna a nuova arena/bet offer

### Fase G — End run
Il sistema seleziona finale coerente con pattern della run, emette verdict/log, e pulisce il save di run (`clear_run`).

## 4) Sistemi principali (mappa rapida)
- **RunManager (`scripts/systems/run_manager.gd`)**
  - Autorità unica del flow e dello stato run.
  - Gestione fasi, betting Level 3, rituali, arena progression, push-luck, scars, finali, log.
- **GameEvents (`scripts/systems/game_events.gd`)**
  - Event bus centrale: segnali request_* (intent UI) e segnali di stato/outcome (run, arena, modali, progressione).
- **SaveManager (`scripts/systems/save_manager.gd`)**
  - Persistenza profilo (unlock/settings) + save run con backup/migrazione schema.
- **Arena (`scripts/Arena.gd`)**
  - Gestione ondate/spawn nemici/aggro; in modalità visual-only non governa il flow.
- **UIRoot + MainMenu (`scripts/ui/*.gd`)**
  - UI reattiva: mostra stato, invia richieste, non prende decisioni gameplay.

## 5) Feature attive rilevanti (presentabili)
- **Flow Level 3 ufficiale** con sequenza canonica e checkpoint autosave.
- **Sistema patti/scommesse ad archetipi** (debito/ego/tempo ecc. a livello dati e runtime L3).
- **Push Your Luck** come snodo decisionale centrale (cashout vs rilancio).
- **Scar/Cicatrici e Condanne** come memoria diegetica della run.
- **Registro** (voce amministrativa) che annota pattern e guida la chiusura narrativa.
- **Arene tematiche** e contesto “folla” (mood/linee contestuali).
- **Ending system** basato su classificazione della run, non su “vittoria classica”.
- **Archivio/Menu esteso** con sezioni condanne e “museo” contenuti sbloccati.

## 6) Personaggi / entità narrative e gameplay
### Gameplay entities
- **Player**: avatar giocabile in arena (`Player.tscn`).
- **EnemyBasic**: nemico base attuale (`EnemyBasic.tscn`).
- **Folla**: non personaggio fisico, ma sistema di pressione narrativa (linee/mood).

### Entità diegetiche
- **Il Registro**: autorità impersonale che classifica atti di rischio.
- **Felix Gallicus**: anomalia d’archivio; non appare in scena, emerge come precedente non classificabile.

## 7) “Cosa abbiamo aggiunto” (stato repo recente)
Dalla cronologia recente emerge un blocco di lavoro sull’**UI ufficiale**:
1. Fondazione tema/font/stile ufficiale.
2. Organizzazione asset in cartella `UI Official`.
3. Pilot patch del Main Menu con stylebox/pulsanti ufficiali.

In parallelo, il progetto mantiene il flow Level 3 e i documenti canonici di design (risk-driven, registro, flow contract).

## 8) Come spiegare il progetto in presentazione (script breve)
> “Gallicus è un’arena game dove non stiamo cercando di far diventare il giocatore più forte tra le run, ma di metterlo davanti a scelte di rischio irreversibile. Il `RunManager` è il cervello unico della run; UI e arena visualizzano, non decidono. Ogni ciclo è: firmi un patto, combatti, accetti conseguenze, poi scegli se incassare o rilanciare. Questo costruisce un profilo letto dal Registro, che chiude la run con un verdetto narrativo coerente. Il mistero di Felix Gallicus rappresenta il caso-limite: il sistema che continua a funzionare ma non riesce più a classificare completamente.”

## 9) Rischi tecnici da ricordare in review
- Evitare flow misti con sistemi legacy bet.
- Verificare sempre open/close rituali e modali per prevenire softlock.
- Mantenere la regola: UI emette intent, RunManager decide outcome.
- Preservare invarianti (single RunManager, GameEvents autoload, strict typing).
