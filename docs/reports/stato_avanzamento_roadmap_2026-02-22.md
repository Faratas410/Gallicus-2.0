# Gallicus — Stato avanzamento lavori e roadmap progressiva (snapshot tecnico)

Data: 2026-02-22  
Scope: assessment tecnico su codice + runtime, orientato alla pianificazione incrementale.

> Documento di report (non canon). Le decisioni autoritative restano nei file `docs/canon/*`.

## 1) Stato attuale sintetico

### 1.1 Runtime invariants (baseline)
Check automatici eseguiti:
- `python3 scripts/ci/check_runtime_invariants.py` → **OK**
- `python3 scripts/ci/check_no_legacy_references.py` → **OK**
- `python3 tools/ci/validate_gameevents_contract.py` → **OK** (19 segnali richiesti validati)
- `python3 tools/ci/verify_res_paths.py` → **OK**

L’architettura risulta coerente con i vincoli Level 3 (single RunManager authority + GameEvents contract + path `res://` validi).

### 1.2 Stato coding (strutturale)
- `RunManager` è ancora molto esteso (`~4656` righe): forte centralizzazione logica/flow.
- `UIRoot` è anch’esso grande (`~2416` righe): gestione reattiva ampia ma densa.
- Persistono segnali di contenuto incompleto lato betting legacy in `data/bets.gd` (`pact` con stringhe placeholder).
- `run_flow_catalog.gd` mantiene router eventi vuoto (`pass`) con registry mutation attivo: struttura presente, adozione parziale.

### 1.3 Stato runtime (verifica eseguibile)
- **Non verificato in questa snapshot**: avvio reale Godot 4.6 della scena `res://scenes/Main.tscn` e assenza warning editor/runtime.
- I check statici e di contratto passano, ma manca ancora una sessione di smoke runtime completa con evidenza registrata.

---

## 2) Cosa manca oggi (gap operativi)

## A) Gap di coding
1. **Completamento contenuti dati betting “storici”**
   - In `data/bets.gd` i campi `pact` sono ancora placeholder testuali.
   - Impatto: qualità/consistenza contenutistica; riduce percezione di “build pronta”.

2. **Riduzione rischio da concentrazione logica**
   - `RunManager` e `UIRoot` hanno elevata superficie di regressione per patch minime.
   - Impatto: manutenzione lenta, review più difficile, costo fix crescente.

3. **Allineamento documentazione di inventory**
   - Alcuni report storici citano ancora `legacy-runtime`, ma nello snapshot corrente la directory non risulta presente.
   - Impatto: rumore cognitivo e possibili decisioni basate su inventario non aggiornato.

## B) Gap di runtime/QA
1. **Smoke test end-to-end in engine non formalizzato nel report corrente**
   - Mancano prove aggiornate “boot Main -> run completa -> finale -> restart/continue” con log allegato.

2. **Validazione “warnings = errors” lato editor Godot**
   - I check Python passano, ma serve la verifica editor/headless Godot per chiudere il requisito operativo.

3. **Matrice regressione flow/UI non ancora serializzata come routine periodica**
   - Esiste copertura contrattuale, ma non una checklist E2E corta e ripetibile per ogni milestone.

---

## 3) Roadmap progressiva consigliata (incrementale)

## Fase 0 — Baseline verificabile (quick win, 1 ciclo)
**Obiettivo:** trasformare lo stato attuale in baseline tracciata.

- Raccogliere smoke log runtime Godot 4.6 su `Main.tscn` (new run + continue + finale).
- Registrare esito warning count = 0 in un report tecnico unico.
- Congelare output comandi CI già verdi nello stesso report.

**Done quando:** check statici + smoke runtime + warning zero sono tutti documentati insieme.

## Fase 1 — Chiusura gap contenutistici minimi (1-2 cicli)
**Obiettivo:** rimuovere indicatori espliciti di incompleto.

- Sostituire i placeholder `pact` in `data/bets.gd` con copy coerente al canon.
- Verificare che i nuovi testi siano riflessi correttamente nella UI betting.

**Done quando:** nessun placeholder utente-facing nelle entry bet L3 attive.

## Fase 2 — Hardening runtime operativo (2 cicli)
**Obiettivo:** rendere la regressione flow più difficile.

- Introdurre una checklist smoke corta e stabile (esecuzione obbligatoria pre-merge).
- Tracciare i passaggi di fase principali (MAIN_MENU → RUN_INIT → BET_PRESENT → …) con assert di coerenza.
- Consolidare in un report singolo la diagnostica flow (evitando frammentazione tra più report storici).

**Done quando:** ogni patch può dimostrare in modo rapido che il flow canonico non è regredito.

## Fase 3 — Riduzione rischio manutenzione (continuativa)
**Obiettivo:** abbassare il costo delle patch senza alterare authority.

- Pianificare micro-split progressivi su `RunManager`/`UIRoot` solo dove già previsto dal perimetro attuale (nessun cambio di authority, nessun refactor ampio in un colpo).
- Ogni split deve restare: minimale, reversibile, e coperto da check CI + smoke.

**Done quando:** diminuisce la superficie per patch (file/funzioni toccate) mantenendo invarianti invariati.

## Fase 4 — Igiene documentale (continuativa)
**Obiettivo:** evitare drift tra “stato reale repo” e report.

- Consolidare report obsoleti/doppi in `docs/reports/INDEX.md` con marcatura “storico/non più corrente”.
- Aggiornare inventory report quando cambia struttura reale cartelle.

**Done quando:** un nuovo contributor legge un solo percorso documentale e non trova conflitti operativi.

---

## 4) Priorità pratica (ordine di esecuzione)
1. **Fase 0** (blocca incertezza runtime).  
2. **Fase 1** (chiude gap visibili al player).  
3. **Fase 2** (stabilizza QA flow).  
4. **Fase 4** (riduce rumore documentale).  
5. **Fase 3** (riduzione rischio manutenzione nel medio periodo).

---

## 5) Nota decisionale
Lo snapshot mostra una base tecnica robusta lato invarianti/contratti, ma ancora incompleta lato “prove runtime tracciate” e pulizia di alcuni segnali di incompleto (placeholder + report storici non allineati). La roadmap sopra privilegia prima la verificabilità in engine, poi la rifinitura contenutistica, poi l’hardening di processo.

---

## 6) Task operative per macro-aree (step-by-step verso 100%)

Di seguito una backlog esecutiva in ordine di priorità, con task atomiche e criterio di chiusura.

### Macro-area A — Runtime baseline certificata (target: eliminare incertezza engine)

**A1. Preparare sessione smoke standard**
- Definire singola procedura: boot `res://scenes/Main.tscn` → New Run → almeno 1 ciclo bet/outcome → finale run → ritorno menu/continue.
- Allegare timestamp, commit hash e operatore nel report.
- **Done quando:** la procedura è descritta in modo ripetibile in un unico punto.

**A2. Eseguire smoke run completa in Godot 4.6**
- Eseguire la procedura A1 senza deviazioni.
- Registrare esito per ogni segmento di flow (menu, init run, presentazione bet, esito, chiusura).
- **Done quando:** tutti i segmenti risultano “pass” con evidenza testuale.

**A3. Certificare requisito “warnings = errors”**
- Acquisire evidenza warning count = 0 durante esecuzione/editor/headless.
- Salvare output nel report tecnico della baseline.
- **Done quando:** warning zero è esplicitamente documentato con comando e output.

**A4. Consolidare baseline tecnica unica**
- Unire in uno stesso report: check CI statici già verdi + smoke runtime + warnings zero.
- Pubblicare il report come riferimento “baseline corrente”.
- **Done quando:** esiste un solo documento di baseline richiamabile pre-merge.

### Macro-area B — Chiusura gap contenutistico betting (target: zero placeholder user-facing)

**B1. Inventario placeholder attivi**
- Elencare tutte le entry in `data/bets.gd` con campo `pact` non definitivo.
- Verificare quali entry sono effettivamente esposte nel flow L3 attivo.
- **Done quando:** lista placeholder completa e validata.

**B2. Sostituzione copy pact conforme al canon**
- Aggiornare i testi placeholder con copy coerente a tono/lessico canonico.
- Mantenere invariata la struttura dati (nessun cambio schema).
- **Done quando:** nessuna entry L3 attiva contiene placeholder.

**B3. Verifica rendering UI betting**
- Eseguire controllo end-to-end che i nuovi testi siano visibili e non troncati nei punti critici.
- Annotare eventuali mismatch testuali.
- **Done quando:** tutti i pact aggiornati sono leggibili nel percorso UI attivo.

### Macro-area C — Hardening QA flow canonico (target: regressione rapida intercettabile)

**C1. Definire checklist smoke corta pre-merge**
- Formalizzare una checklist minima (5–10 passaggi) obbligatoria su ogni patch runtime.
- Mappare ogni passaggio a una fase canonica del flow.
- **Done quando:** checklist breve esiste e viene richiamata nei report patch.

**C2. Aggiungere assert/coerenza sui passaggi di fase principali**
- Validare transizioni chiave (es. `MAIN_MENU -> RUN_INIT -> BET_PRESENT -> OUTCOME/APPLY -> NEXT`).
- Bloccare passaggi illegali o fuori ordine con log diagnostico.
- **Done quando:** le transizioni canoniche hanno verifica esplicita.

**C3. Report diagnostico flow unificato**
- Convogliare esiti checklist + assert + smoke in un unico report operativo.
- Ridurre frammentazione di evidenze in documenti sparsi.
- **Done quando:** per ogni milestone esiste una sola evidenza flow aggiornata.

### Macro-area D — Igiene documentale operativa (target: ridurre drift documenti/repo)

**D1. Audit report correnti vs storici**
- Classificare i report in: correnti, storici, deprecati.
- Evidenziare conflitti con stato reale repository.
- **Done quando:** ogni report ha stato esplicito.

**D2. Aggiornare `docs/reports/INDEX.md`**
- Inserire etichette “autorevole operativo” vs “storico/non corrente”.
- Definire percorso di lettura consigliato per contributor nuovi.
- **Done quando:** INDEX guida a una singola traccia di consultazione.

**D3. Manutenzione inventory allineata ai cambi struttura**
- Ogni modifica strutturale repo deve riflettersi nei report inventory pertinenti nello stesso ciclo.
- **Done quando:** nessun riferimento strutturale obsoleto rimane aperto.

### Macro-area E — Riduzione rischio manutentivo (target: patch più piccole e sicure)

**E1. Mappare zone ad alta densità in `RunManager`/`UIRoot`**
- Identificare blocchi funzionali candidati a micro-split non architetturali.
- Prioritizzare per rischio regressione e frequenza modifica.
- **Done quando:** backlog micro-split ordinata per impatto/rischio.

**E2. Eseguire micro-split incrementali (uno per patch)**
- Estrarre solo porzioni locali con interfaccia invariata.
- Vietato alterare authority/flow ownership.
- **Done quando:** ogni split è reversibile, testato e senza drift di invarianti.

**E3. Misurare effetto su superficie patch**
- Tracciare metriche semplici: file toccati, righe modificate, tempo review.
- Confermare riduzione progressiva della complessità patch.
- **Done quando:** trend migliorativo documentato su più cicli.

---

## 7) Sequenza esecutiva consigliata (task-by-task)

1. **A1 → A2 → A3 → A4** (baseline runtime certificata).
2. **B1 → B2 → B3** (chiusura immediata segnali di incompleto player-facing).
3. **C1 → C2 → C3** (hardening regressione flow).
4. **D1 → D2 → D3** (riduzione rumore documentale).
5. **E1 → E2 → E3** (riduzione rischio manutentivo continuativa).

### Gate di completamento “100% operativo”
Per considerare Gallicus al 100% su questa roadmap, devono risultare chiusi contemporaneamente:
- baseline runtime certificata e aggiornata (Macro A);
- zero placeholder betting attivi nel percorso L3 (Macro B);
- checklist e diagnostica flow adottate come rito pre-merge (Macro C);
- documentazione operativa senza conflitti correnti/storici (Macro D);
- trend di riduzione superficie patch su manager ad alta densità (Macro E).
