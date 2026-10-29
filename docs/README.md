# Gallicus Documentation Operating System

Identita' e direzione per l'espansione: [l'anima di Gallicus](support/anima_gallicus_2026-10-29.md).

Obiettivo delle dieci ore in pausa: [stato e lavoro da completare](support/sospensione_10_ore_2026-10-29.md).

Revisione prima del commit: [perimetro, correzioni e decisioni aperte](support/revisione_pre_commit_10_ore_2026-10-29.md).

Revisione Incasso/Rilancio: [cinque correzioni, file e prove](support/verdict_review_2026-10-26.md).

Revisione dei sette commenti sul Banco: [correzioni, asset e prove](support/banco_review_2026-10-26.md).

Questo e' l'entrypoint operativo del progetto. Gallicus ha un solo target di
prodotto: **Gallicus 1.0**, una campagna rituale finita da pubblicare su Steam.

Reference UI approvata il 25 ottobre: Registro pixel art frontale, firma a
inchiostro e animazione, con Rito e Incasso/Rilancio come famiglia visiva.
Immagini e anteprima in [direzione artistica](art_direction.md#reference-approvata-per-la-revisione-ui---25-ottobre-2026).
Registro autorizzato in game il 26 ottobre e integrato nel candidato locale:
[integrazione e verifiche](support/registry_volume_2026-10-26.md).
Le altre schermate restano reference per le prossime revisioni.

Fascia GDR approvata e portata nel candidato locale il 26 ottobre:
[Insegne dell'arena](support/hud_insegne_2026-10-26.md).

Confronto aggiornato dopo l'approvazione di Registro e HUD:
[schermate ancora incoerenti e ordine di uniformazione](support/ui_coherence_2026-10-26.md).
Catture native e galleria locale; il redesign delle altre schermate resta da attuare.

Secondo seguito implementato: [Banco e Incasso/Rilancio pixel art](support/pixel_banco_verdict_2026-10-26.md).

Primo seguito implementato: [Patto, Gradinata e Rito pixel art](support/pixel_rituals_2026-10-26.md).
Restano aperti gli altri gruppi dell'inventario.

Uniformazione richiesta dopo l'audit del 24 ottobre: ambienti, cast, UI e
motion in [uniformazione artistica](support/art_unification_2026-10-24.md).
La consegna distingue il candidato locale dai gate Linux e umani.

Audit artistico e animazioni del 24 ottobre sul candidato locale corrente:
[coerenza trasversale, cast e motion](support/art_audit_2026-10-24.md).
Include catture nuove e difetti riprodotti; nessuna correzione runtime o
nuova approvazione artistica, gate di roadmap invariati.

Pass locale Incasso/Rilancio del 22 ottobre: riferimento, asset e prove in
[Arena viva](support/living_verdict_2026-10-22.md).

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

Studio HTML della fascia di stato superiore, 22 ottobre 2026: proposta
interattiva per Incasso/Rilancio, da valutare prima dell'integrazione in Godot.
Perimetro e prove in `docs/support/hud_html_study_2026-10-22.md`.

Verifica visiva Manifesto del 15 ottobre 2026, dopo il merge dei pacchetti
4-7 su `main`: correzioni locali a Archivio, schede di lettura, checkbox e
nota del banco. Prove con Godot 4.7.2 ufficiale, IT/EN/ES, 720p e 1080p:
`docs/support/manifesto_visual_review_2026-10-15.md`.
Questa verifica di compatibilita' locale non cambia la baseline CI 4.6.2.

Kit UI Manifesto riutilizzabile, 9 ottobre 2026: token, superfici e azioni
condivisi tra posta e comandi del fascicolo, con campionario interattivo.
API, perimetro e prove in `docs/support/ui_kit_2026-10-09.md`.

Preparazione dell'estensione alle schermate rimanenti, sul kit corrente:
`docs/support/manifesto_remaining_screens_2026-10-09.md`. Primo pacchetto:
Registro, banco e firma. Preparazione storica; prove visuali/runtime solo IT.
Pacchetto 1 implementato e verificato localmente:
`docs/support/manifesto_registry_2026-10-09.md`.
Pacchetto 2 implementato e verificato localmente:
`docs/support/manifesto_pact_crowd_2026-10-09.md`.
Pacchetto 3 implementato e verificato localmente:
`docs/support/manifesto_judgment_2026-10-09.md`. I pacchetti successivi
Fascicolo/HUD/Segni, utility, Archivio e narrativa sono integrati in `main`;
consegna storica in `docs/support/manifesto_atto_a_stampa_2026-10-10.md`.
Revisione umana e checkpoint Linux del candidato rimangono aperti.

Integrazione locale dei contesti del 7 e 8 ottobre 2026, con risoluzione dei
conflitti fra UI/editoriale e Lauro/benchmark:
`docs/support/merge_integration_2026-10-08.md`. Candidato verificato su Windows;
commit del merge e checkpoint Linux restano al successivo handoff.

Identita' UI scelta dall'utente: **Manifesto del Verdetto**. Regole comuni
in `docs/art_direction.md`, prima applicazione nella decisione sulla posta
in `docs/support/manifesto_verdict_2026-10-08.md`.

Base confermata con adattamento al mood di Gallicus: cera piu' spenta,
avorio sporco, inchiostro e incisioni asciutte. Handoff per Astra sulla
sequenza UI: `docs/support/astra_manifesto_handoff_2026-10-08.md`.

Catture correnti e progetto della prima patch circoscritta alla posta:
`docs/support/manifesto_scope_2026-10-08.md`. Diagnosi preparata, nessuna
nuova implementazione in questa consegna.

Prima implementazione del perimetro, con prove visuali/runtime solo IT:
`docs/support/manifesto_material_2026-10-08.md`.

Prova successiva di attraversamento: quattro vedute della stessa arena e
anteprima separata dal runtime in `docs/support/spatial_sequence_2026-10-08.md`.
Le reference spaziali non fissano il trattamento runtime: primo campione
illustrato nell'arena e criterio comune in `docs/support/illustrated_arena_2026-10-08.md`.

Banco amministrativo integrato dopo il confronto sui concept UI:
`docs/support/counter_ui_2026-10-08.md`. Composizione, materiali e verifiche locali.


Verifica del lavoro corrente e pass UI/cast dell'8 ottobre 2026:
`docs/support/claude_review_2026-10-08.md`. Prove locali e simulazioni restano
separate dal playtest umano e dal checkpoint Linux.

Handoff per il pass di scrittura richiesto all'Astra:
`docs/support/astra_writing_handoff_2026-10-08.md`.
Pass integrato successivo, con campione prima/dopo, matrice narrativa e
verifiche: `docs/support/writing_pass_2026-10-08.md`.

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
