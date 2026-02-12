# Codex 1.0 Gap Report

**Status:** REPORT  
**Scope:** Historical gap analysis snapshot for Codex 1.0 alignment and verification gaps.  
**Source of truth:** docs/CODEX_GOLDEN_CHECKLIST.md, docs/canon/RUN_ARCHITECTURE_CANON.md  
**Last updated:** 2026-02-11  
**Notes:** This is historical; not canon.

Overlaps with: docs/level3_integrity_audit_report.md, docs/level3_open_questions_log.md.

## Overlap
- Overlaps with: docs/level3_integrity_audit_report.md, docs/level3_open_questions_log.md.

## Build status
- Main.tscn avvia? **Non verificato** (richiede run in Godot 4.6).
- Warning count: **Non verificato** (atteso 0, serve apertura in editor).

## Flow checklist
- Onboarding chiudibile? **Non verificato** (UI aggiornata per blocker/focus, serve run).
- Bet selection sempre? **Non verificato** (UI aggiornata, serve run).
- Push choices sempre? **Non verificato** (UI aggiornata, serve run).
- Scars apply + UI? **Non verificato** (logica presente, serve run).
- Ending screen completa? **Non verificato** (UI aggiornata, serve run).

## Percezione completezza (1.0)
1) **Transizioni tra modal e gameplay troppo “secche”.**
   - Impatto: la run può sembrare “incompleta” perché manca un ritmo visivo consistente.
   - È dentro 1.0? **Sì**.
   - Fix minimo consigliato: aggiungere una breve dissolvenza (0.15–0.25s) già nel layer UI.

2) **Feedback di stato quando un’azione è bloccata (oltre al tooltip).**
   - Impatto: player non capisce a colpo d’occhio perché un bottone è disabilitato.
   - È dentro 1.0? **Sì**.
   - Fix minimo consigliato: un breve testo “Disponibile dopo …” sotto i pulsanti disabilitati.

3) **Dimensioni testo non uniformi tra modals e HUD.**
   - Impatto: percezione di interfaccia “non finita”.
   - È dentro 1.0? **Sì**.
   - Fix minimo consigliato: riallineare le dimensioni base dei font nei pannelli principali.

4) **Spaziatura verticale in alcuni pannelli (Bet/Push) ancora densa.**
   - Impatto: lettura più lenta nei momenti critici.
   - È dentro 1.0? **Sì**.
   - Fix minimo consigliato: aumentare separazione tra blocchi testo e pulsanti.

5) **Dati riepilogo ending poco contestualizzati (“Arene: X | Cashout: Y”).**
   - Impatto: epilogo forte, ma metriche fredde e poco integrate.
   - È dentro 1.0? **Sì**.
   - Fix minimo consigliato: riga di testo che lega numeri all’epilogo (senza nuove feature).

## Legacy remnants
- Presenza cartella `scripts/legacy/` (non verificato se referenziata nelle scene runtime).

## Stop list
- Verifica avvio `Main.tscn` e warning count: richiede esecuzione di Godot 4.6.
- QA runtime completo del flusso (8–15 min) per confermare checklist.
