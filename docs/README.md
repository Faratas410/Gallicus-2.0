# Gallicus Documentation Operating System

Questo e' l'entrypoint operativo del progetto. Gallicus ha un solo target di
prodotto: **Gallicus 1.0**, una campagna rituale finita da pubblicare su Steam.

La documentazione attiva non usa versioni intermedie per descrivere il
progresso. Le fasi di lavoro hanno nomi operativi e gate verificabili.

## Ordine di lettura

1. `docs/direction.md` - anima, voci, lessico unico e regole di stile UI.
2. `docs/design_skeleton.md` - promessa di prodotto, stato reale e Definition of Done.
3. `docs/development_plan.md` - roadmap sequenziale verso 1.0 e prossimo step.
4. `docs/development_workflow.md` - ciclo di sviluppo con Astra e consegna locale.
5. `docs/game_design.md` - esperienza, loop e campagna completa.
6. `docs/object_grammar.md` - grammatica obbligatoria per le azioni gameplay.
7. `docs/testing.md` - verifiche statiche, runtime, visuali e manuali.
8. `docs/code_quality.md` - ownership e disciplina prima di cambiare runtime.
9. Documento di dominio pertinente; `docs/steam_release.md` per la distribuzione.
10. Canon owner pertinente, se la patch cambia una regola o un contratto.

## Owner documentali

| Domanda | Owner |
| --- | --- |
| Che anima ha il gioco e come deve sentirsi? | `docs/direction.md` |
| Che gioco stiamo finendo? | `docs/design_skeleton.md` |
| Qual e' il prossimo blocco implementabile? | `docs/development_plan.md` |
| Come lavora Astra e come consegna? | `docs/development_workflow.md` |
| Come funziona l'esperienza? | `docs/game_design.md` |
| Quale oggetto rende reale un'azione? | `docs/object_grammar.md` |
| Come appare? | `docs/art_direction.md` e `docs/layout_rules.md` |
| Come suona? | `docs/audio_direction.md` |
| Quando usa una sequenza cinematica? | `docs/cinematic_direction.md` |
| Come parla e quali contenuti contiene? | `docs/content_bible.md` |
| Come sono strutturati dati e save? | `docs/data_schema.md` |
| Come si producono asset runtime? | `docs/asset_pipeline.md` |
| Come si verifica? | `docs/testing.md` |
| Cosa blocca la release? | `docs/release_checklist.md` |
| Come arriviamo alla pubblicazione Steam? | `docs/steam_release.md` |
| Come si conduce un playtest? | `docs/playtest_guide.md` |
| Quali requisiti hanno accessibilita' e lingue? | `docs/accessibility_localization.md` |
| Quali rischi di tono vanno controllati? | `docs/ethics_and_representation.md` |

## Autorita'

Rework di prodotto del 6 ottobre 2026: direzione in `docs/direction.md`,
gap e piano in `docs/support/rework_audit_2026-10-06.md`. Revisione del game
loop dello stesso giorno (posta, quietanza, patti, gesto, campagna, ritmo):
`docs/support/game_loop_review_2026-10-06.md`. Arena attiva (sigillo a colpi,
scambi con la gradinata e favore), dopo il playtest "troppo passivo":
`docs/support/arena_attiva_2026-10-06.md`.

Racconti, 7 ottobre 2026 (otto con il bando): cinque scene illustrate in piu' (conto di Vessa,
sabbia, richiamo, posti in vendita, riga che resta) fra la prima copia e la
meta' della campagna, e dodici nuove voci dell'arena; canone in
`docs/canon/LORE_UNIFIED.md`, copy in `docs/content_bible.md`. Pannelli e libro
del Registro restano ancorati al centro (UI_CANON, Motion Contract).

Bando, scala e catena, 7 ottobre 2026 ("Perche' scommettere? Perche'
continuare?"): ogni percorso ha un bando di Gloria da chiudere entro un'arena,
la scala dei bandi paga i dieci racconti (quattro sul posto vuoto) e tre pagine di
patti, i sigilli retti di fila moltiplicano la posta. Canone in
`docs/canon/MECHANICS_UNIFIED.md`, numeri in `docs/support/motivazione_2026-10-07.md`.

Lauro il cantastorie, 7 ottobre 2026 ("Aggiungiamo un personaggio? Un
cantastorie, colui che racconta le gesta degli eroi"): uno storno della
gradinata canta in fondo al fascicolo la gesta del percorso e ricorda la gesta
piu' alta; due racconti suoi aprono la scala dei bandi e il filo del posto
vuoto. Scheda, prove e prompt del ritratto in
`docs/support/cantastorie_2026-10-07.md`.

Consegna precedente: tre scene illustrate, art di Nerio/Rugo/Dima e Registro
come terminale rituale impersonale. Specifica e prove in `docs/support/illustrated_dialogues_2026-09-12.md`.

Personaggi e dialoghi: `docs/support/arena_cast_2026-09-12.md`.
Ai Gufi Nerio, Vessa e Orvo si aggiungono il gallo Rugo e la gallina Dima,
con scambi e schede IT/EN/ES.

Pass end-to-end corrente: `docs/support/campaign_completion_2026-09-12.md`.
Include boot, campagna reale, quattro checkpoint, epilogo e build pre-umana.

Ultima implementazione di coerenza e prologo:
`docs/support/consistency_fix_2026-09-08.md`. L'audit precedente
`docs/support/screen_audit_2026-09-08.md` conserva i difetti e le prove del
candidato precedente. I report non sostituiscono checkpoint Linux o CP-03.

- `docs/canon/` contiene le regole canoniche e prevale sui documenti operativi.
- `docs/contracts/` contiene superfici tecniche controllate anche dalla CI.
- `docs/support/` contiene inventari e procedure subordinate agli owner.
- `docs/archive/` contiene sola lineage storica non operativa.
- `RunManager` resta l'unica autorita' del flow.
- `GameEvents` resta il bus eventi.
- La UI emette intenti e reagisce a payload; non decide outcome.

## Regole di aggiornamento

- Una feature player-facing parte da
  `intento -> oggetto -> gesto -> feedback -> registrazione`.
- Un cambio di flow aggiorna `docs/canon/RUN_ARCHITECTURE_CANON.md`.
- Un cambio di regola aggiorna `docs/canon/MECHANICS_UNIFIED.md`.
- Un cambio di contratto UI aggiorna `docs/canon/UI_CANON.md`.
- Un cambio a dati o save aggiorna `docs/data_schema.md` e i contratti.
- Un cambio visuale aggiorna art direction, layout o asset pipeline.
- Un cambio audio aggiorna `docs/audio_direction.md`.
- Un cambio di copy o contenuto aggiorna `docs/content_bible.md`.
- Un cambio di workflow aggiorna `docs/development_workflow.md` e le regole agent pertinenti.
- Un cambio di distribuzione aggiorna `docs/steam_release.md` e la release checklist.
- Ogni blocco concluso aggiorna `docs/development_plan.md`.

## Affidabilita'

- Audit trasversale del 4 settembre 2026: `docs/support/audit_2026-09-04.md`.
  Contiene prove locali, lacune e priorita'; non sostituisce i gate della roadmap.

- I path citati dalla documentazione attiva devono esistere.
- I documenti non possono dichiarare completato un gate senza prova.
- I nomi tecnici legacy non definiscono lo stato del prodotto.
- Nessun documento attivo puo' reintrodurre milestone di versione superate.
- Verifica riferimenti:

```powershell
python scripts/ci/check_docs_active_refs.py
```

- Verifica encoding:

```powershell
python scripts/ci/test_no_mojibake.py
rg -n -P "\x{00C3}|\x{00C2}|\x{FFFD}" .
```

## Bonifica successiva all'audit

`docs/support/bonifica_2026-09-04.md` raccoglie modifiche, prove locali,
inventario dei file e limiti ancora aperti del nuovo tema e della campagna.

La revisione del titolo, delle frasi e della ripresa del menu e' documentata
in `docs/support/menu_identity_2026-09-05.md`.
