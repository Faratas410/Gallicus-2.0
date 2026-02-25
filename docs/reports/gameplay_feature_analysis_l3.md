# GALLICUS L3 — Analisi strutturata Gameplay/Flow/Feature

**Status:** SUPPORTING (non canonico)
**Data:** 2026-02-25
**Obiettivo:** mappare in modo operativo le feature gameplay L3 con schema ripetibile: **cos'è / cosa fa / stato attuale / come migliorare**.

---

## 1) Metodo di analisi (vincolato al Canon)

- Fonti autoritative usate:
  - `docs/canon/PROCESS_AND_FREEZE.md`
  - `docs/canon/RUN_ARCHITECTURE_CANON.md`
  - `docs/canon/MECHANICS_UNIFIED.md`
  - `docs/canon/GLOSSARY_ENTITIES.md`
  - `docs/canon/LORE_UNIFIED.md`
  - `docs/canon/FOUNDATIONS.md`
- Fonti runtime usate per lo stato reale:
  - `scripts/systems/run_manager.gd`
  - `scripts/systems/run/*.gd` (flow, phase handlers, outcome, scar, policy)
  - `scripts/content/scar_catalog.gd`, `scripts/content/bet_catalog.gd`
  - `data/bets.gd`, `data/condanne.gd`, `data/verdict_lines.gd`

### Regola di lettura

Questa analisi **non ridefinisce** canon né architettura. Le proposte sono espresse come:
- **Hardening** (chiarezza / telemetria / validazioni)
- **Bilanciamento dati** (valori e tabelle)
- **Pulizia flexible zone** (senza cambiare authority/flow)

---

## 2) Flow gameplay L3 (vista sintetica)

1. **Main Menu** → nuovo run / continue.
2. **Run Init** → seed, payload base, arena context.
3. **Bet Present** → apertura offerte e selezione patto.
4. **Bet Signed / Checkpoint** → stato consolidato.
5. **Ritual Resolve** → risoluzione esito (favorevole / adverse / terminal).
6. **Intermediate Choice** (placa/provoca) se previsto.
7. **Push Your Luck** (cashout / condanna / double).
8. **Loop arena successiva** o **Run End** con verdict/registro.

---

## 3) Analisi ripetuta per feature gameplay

## 3.1 Scar System

### Cos'è
Sistema di cicatrici permanenti nella run che registra irreversibilità e modifica rischio/pressione.

### Cosa fa
- Applica modificatori runtime (heal/dodge) dalle scar attive.
- Costruisce payload narrativo/UI della scar.
- Usa policy separata per decidere **se tentare** scar evento (irreversible pact, refused closure, risk threshold).
- Traccia stato deterministico (`scar_rng_state`, `scar_roll_index`, contatori scar).

### Cosa abbiamo attualmente
- Modificatori compatti in `RunScarSystem.compute_modifiers`.
- Decisione idoneità scar evento in `ScarPolicy.should_try_scar` con soglie e intervallo arena.
- Catalogo scar centralizzato (`ScarCatalog`).
- Integrazione con outcome/flow attraverso `run_manager`.

### Come miglioriamo (senza violare freeze)
1. **Auditabilità:** emettere log tecnico standardizzato per ogni tentativo scar (`candidate`, `eligible`, `blocked_reason`, `rng_roll`).
2. **Bilanciamento data-driven:** spostare numeri di probabilità/soglia in tabella dati dedicata per tuning senza toccare authority.
3. **Copertura edge-case:** verificare esplicitamente comportamento con scars duplicate in input sporco (guardia difensiva).
4. **Telemetry pack:** aggregare metriche scar per run report (densità scar / distanza media tra scar).

---

## 3.2 Bet Offer & Selection System

### Cos'è
Motore che costruisce le offerte patto disponibili e riceve la scelta del giocatore.

### Cosa fa
- Filtra patti per unlock, scars richieste/bloccanti, regole anti-ripetizione.
- Costruisce payload UI e conserva storico offerte/scelte.
- Applica mutazioni via flow mutation registry (`BETP_PLACE_BET`, `INTRO_SELECT_BET`, `INTRO_CONFIRM`).

### Cosa abbiamo attualmente
- Pipeline separata policy/factory in `betting_policy.gd` + `betting_payload_factory.gd`.
- Catalogo patti consolidato in `bet_catalog.gd` (consumato da `data/bets.gd`).
- Handler fase dedicato (`PhaseBetPresentHandler`) con richieste validate.

### Come miglioriamo
1. **Spiegabilità lock:** payload UI con `lock_reason_code` normalizzato (non solo testo) per debug UX.
2. **Consistenza anti-loop:** metrica di diversità offerta (evitare cluster ripetitivi troppo frequenti).
3. **Validazione catalogo:** check statico su bet catalog (campi obbligatori + coerenza archetype/behavior).

---

## 3.3 Resolve Ritual / Outcome System

### Cos'è
Kernel che decide esiti arena e conseguenze meccaniche (favorable/adverse/terminal).

### Cosa fa
- Calcola probabilità da base + escalation + scars + profilo nemico.
- Produce outcome canonico con lessico rituale L3.
- Genera conseguenze loss (scar applicata, corruption gain, lock cashout, end_reason).
- Calcola reward coins per behavior/tier.

### Cosa abbiamo attualmente
- `RunOutcomeSystem.resolve_level3_arena` e `build_level3_loss_consequence` coprono i rami principali.
- Supporto a profili nemico (`TRICKSTER`, `EXECUTIONER`) e modificatori pressione.
- Contratto lessicale canonico presente nei commenti di migrazione (`Patch 9A`, rimozione alias legacy).

### Come miglioriamo
1. **Trasparenza probabilistica interna:** includere nel payload tecnico breakdown `base_win`, `scar_mod`, `escalation_mod`, `enemy_mod`.
2. **Tabella bilanciamento esterna:** valori numerici di reward/penalty in dataset, non hardcoded.
3. **Test determinismo:** smoke ripetibile seed-based per confermare stabilità output outcome.

---

## 3.4 Intermediate Choice (Placa / Provoca)

### Cos'è
Micro-fase post rituale che aggiunge rischio/controllo prima di push-your-luck.

### Cosa fa
- Espone scelta binaria.
- Applica mutazione di stato (`INTM_SELECT`) via flow registry.
- Aggancia effetti indiretti su penalità/percorsi successivi.

### Cosa abbiamo attualmente
- Handler dedicato (`PhaseIntermediateChoiceHandler`) con payload minimale e robusto.
- In `run_manager` esistono campi di stato dedicati (`intermediate_*`, `provoke_armed`).

### Come miglioriamo
1. **Semantica esplicita:** codificare outcome tecnico della scelta in enum stabile (evita dipendenza da index magic).
2. **Feedback chiuso:** aggiungere evento diagnostico `intermediate_choice_applied` con delta meccanico.

---

## 3.5 Push Your Luck (Cashout / Condanna / Double)

### Cos'è
Snodo principale di rischio iterativo L3.

### Cosa fa
- Offre tre azioni post-esito.
- Esegue mutazioni (`PYL_CASHOUT`, `PYL_CONDANNA`, `PYL_DOUBLE`).
- Aggiorna escalation, streak, contatori push-luck.

### Cosa abbiamo attualmente
- Handler fase chiaro (`PhasePushYourLuckHandler`), UI payload con glory/corruption.
- Stato dedicato in `RunState` (`push_luck_cashouts`, `push_luck_doubles`, `max_push_luck_chain`).
- In `run_manager` sono presenti costanti e copy supporto flow PYL.

### Come miglioriamo
1. **Guardrail anti-ambiguità:** validazione pre-mutazione su prerequisiti (es. double disabilitato una volta).
2. **Risk telemetry:** tracciare expected risk vs scelta reale per tuning del pacing.

---

## 3.6 Corruption System

### Cos'è
Indicatore di deterioramento sistemico della run (capped).

### Cosa fa
- Accumula da condanne/perdite in base alle conseguenze outcome.
- Influisce su finale/annotazioni/interpretazione del run profile.

### Cosa abbiamo attualmente
- Campo autoritativo in `RunState` + cap a livello run manager.
- Delta corruption derivato soprattutto da `build_level3_loss_consequence`.
- Presenza nei payload UI principali e nel game-over payload.

### Come miglioriamo
1. **Ledger del delta:** storico motivazionale per ogni incremento (`source`, `amount`, `arena`, `bet`).
2. **Saturazione leggibile:** trigger tecnico quando vicino al cap per facilitare bilanciamento.

---

## 3.7 Glory System

### Cos'è
Indicatore di performance/consenso/valore positivo nella run.

### Cosa fa
- Incrementa su successi.
- Entra nel payload UI e nella valutazione finale.

### Cosa abbiamo attualmente
- Campo `glory` in `RunState`.
- Costanti base/moltiplicatori in `run_manager` (`GLORY_PER_SUCCESS`, `GLORY_MULT_*`).
- Esposizione coerente in phase payload e game-over.

### Come miglioriamo
1. **Curve esplicite:** documentare tabella moltiplicatori e breakpoint runtime effettivi.
2. **Parità con corruption:** avere ledger simmetrico anche per guadagni glory.

---

## 3.8 Escalation & Enemy Pressure

### Cos'è
Sistema di aumento pressione legato alla profondità della run e al profilo nemico.

### Cosa fa
- Penalizza chance vittoria e aumenta chance danno con escalation.
- Applica varianti nemico su win/damage.

### Cosa abbiamo attualmente
- Funzioni dedicate in `RunOutcomeSystem` (`get_escalation_win_penalty`, `get_escalation_damage_penalty`).
- Supporto enemy profile data-driven (win_mod/damage_mod).

### Come miglioriamo
1. **Readability tecnico-design:** estrarre curva escalation in tabella unica consultabile.
2. **Sanity checks:** assert su range finali già clampati per prevenire regressioni tuning.

---

## 3.9 Condanne, Verdict e Finale Registro

### Cos'è
Layer narrativo-meccanico di chiusura run con classificazione finale.

### Cosa fa
- Registra condanne run-based.
- Costruisce linee di verdetto e payload finale.
- Emissione unlock archivio/achievement correlata a ending.

### Cosa abbiamo attualmente
- Dataset `condanne.gd` e `verdict_lines.gd`.
- In `run_manager` sono presenti ending keys, archive mapping e annotation flow phase.
- `PhaseGameOverHandler` espone payload ricco (stats, scars, condanne, crowd line).

### Come miglioriamo
1. **Normalizzazione taxonomy:** codice univoco per condanna + copy separata per localizzazione.
2. **Finale explainability:** aggiungere breakdown tecnico non diegetico (debug-only) per capire perché ending X.

---

## 3.10 Save/Checkpoint Flow

### Cos'è
Persistenza progressiva della run su checkpoint canonici.

### Cosa fa
- Autosave su momenti chiave (bet signed, intermediate/pyl boundaries).
- Continue boundary separato.

### Cosa abbiamo attualmente
- Moduli dedicati (`save_system.gd`, `save_continue_boundary.gd`, `run_save_boundary_helper.gd`).
- In `RunState` presenti campi `run_save_flow_step`, `run_save_flow_bet_id`.

### Come miglioriamo
1. **Recovery deterministico:** testare ripresa su ogni checkpoint con seed invariato.
2. **Checksum payload:** hash leggero per verificare integrità save runtime.

---

## 3.11 Seed Determinism & RNG Contracts

### Cos'è
Garanzia che run e scar rolls siano riproducibili a parità di stato.

### Cosa fa
- Deriva seed runtime dal contesto run.
- Gestisce RNG stato per scar separatamente (`scar_rng_state`, `scar_roll_index`).

### Cosa abbiamo attualmente
- Funzioni dedicate in `run_manager` (`_compute_level3_seed`, `_initialize_scar_rng_state`, `_scar_roll`).
- Persistenza dei campi RNG in run state.

### Come miglioriamo
1. **Replay mini-harness:** script smoke che confronta due run identiche e verifica eventi/roll.
2. **Determinism snapshot:** dump compatto degli input RNG prima di ogni tiro.

---

## 3.12 UI Reactivity Gameplay-Side

### Cos'è
Strato UI che reagisce allo stato gameplay senza decision authority.

### Cosa fa
- Riceve payload da phase handlers/run manager.
- Mostra pannelli bet, scars, push-luck, game over.

### Cosa abbiamo attualmente
- `ui_root.gd` con wiring esteso eventi GameEvents.
- `run_ui_payload.gd` e factory dedicata per formare payload coerenti.

### Come miglioriamo
1. **Payload contract tests:** validare shape minima per ogni fase (campo obbligatorio/mancante).
2. **Riduzione coupling copy/UI:** spostare copy statiche in risorse dedicate.

---

## 4) Gap trasversali prioritari (ordinati)

1. **Osservabilità gameplay bassa**: molte decisioni valide ma poco tracciabili con cause numeriche.
2. **Hardcoded di tuning diffusi**: numeri in più file rendono lento il bilanciamento.
3. **Mancanza ledger delta (glory/corruption)**: difficile audit run post-mortem.
4. **Contratti payload non formalizzati**: rischio regressioni silenziose UI/flow.

---

## 5) Backlog operativo consigliato (freeze-safe)

### Lotto A — Diagnostica (Flexible/Tooling, non-behavioral)
- Standardizzare log tecnico outcome/scar/pyl.
- Aggiungere snapshot seed+rng per replay debug.

### Lotto B — Data hardening (Flexible)
- Estrarre curve numeriche (reward/escalation/scar chances) in tabelle dati.
- Introdurre validatore cataloghi (bet/scar/condanne/verdict).

### Lotto C — Contratti e test (Tooling)
- Test payload fase per fase.
- Test determinismo su smoke run replicate.
- Test resume checkpoint.

---

## 6) Template riutilizzabile per prossime feature

Per ogni nuova feature gameplay usare sempre:
1. **Cos'è** (ruolo nel sistema)
2. **Cosa fa** (input/output/eventi)
3. **Stato attuale** (file owner + invarianti)
4. **Rischi** (authority, determinismo, flow)
5. **Miglioria minima** (solo se freeze-safe)

