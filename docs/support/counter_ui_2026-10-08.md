# Banco amministrativo - 8 ottobre 2026

## Candidato e perimetro

Implementazione locale richiesta dopo il confronto sui tre concept. Base:
prima composizione (banco scuro e arena); gerarchia editoriale del terzo
riferimento per il fascicolo. Il secondo informa lo spazio del luogo, senza
introdurre luce trionfale o decorazione celebrativa.

Branch main, HEAD da99a64c7d90341ac57f3ad0e4cad7444f6bfa02, working tree
gia' modificato. Nessun commit, branch, push o export. Il lavoro editoriale,
i cinque ritratti e le modifiche preesistenti a RunManager sono conservati.
Stato iniziale: `artifacts/banco_2026-10-08/status_before.txt`.
Snapshot dei file prima di questa revisione nella sottocartella before.

## Risultato

- Arena e piano di pietra continui; eliminate le cornici ripetute su HUD,
  Registro, gesti, rilancio e utility. Tavoletta, marchio e sigillo del
  giudizio conservano il loro materiale specifico e la funzione rituale.
- Posta a 44 px, azioni a 24 px, conseguenze a 17 px; titolo Libre Baskerville.
  Il corpo mantiene il sans Godot. Le label sono tutte native e localizzate.
- Bando, Gradinata e Segni nella stessa colonna. Rail stabile. Nomi dei Segni
  nello scroll; dettaglio e narrativa consultabili. Notifica breve con nome
  ed effetto. Nota Gradinata su una riga, testo completo nel tooltip.
- Firma e registrazione con traccia di cera trasparente. Target fermi tra
  normal, focus, pressed e disabled; nessuna scritta generata nei raster.
- Fascicolo su carta, lettura da sinistra, esito e posta prima delle tre
  colonne. Prosecuzione disponibile in evidenza, ritorno al menu subordinato.
  Stato chiuso resta scuro, con contrasto chiaro anche sulle utility.
- Nomi, effetti e testo dei sei Segni localizzati in IT/EN/ES. Nessuna nuova
  conseguenza, regola, probabilita', transizione, segnale o campo di save.

Il posizionamento usa offset rispetto agli anchor centrali; non modifica la
gestione delle fasi. RunManager conserva l'autorita', UI emette gli intenti
esistenti e rende lo stato ricevuto. La precedenza visiva delle route non
cambia disponibilita' o destinazione.

## Asset e licenza

Tre raster ImageGen, importati senza ritocco esterno: banco 1672x941, carta
1659x948, traccia RGBA 1254x1254. Carta in nine-slice a 12 px; gli altri stati
sono risorse native. Manifest e sidecar accompagnano i PNG.

Libre Baskerville: [repository ufficiale Google Fonts](https://github.com/google/fonts/tree/main/ofl/librebaskerville).
TTF e licenza SIL OFL sono in `assets/ui/official/typography/`. La risorsa
vive fuori dalle esclusioni degli asset ritirati. La verifica del pacchetto
distribuito e delle relative licenze rimane nel gate release, non eseguito
da questo pass locale.

Brief di generazione conservati nel manifest:

**registry_counter**

Bare Roman administrative counter before arena; matte charcoal stone, neutral daylight, quiet lower 72 percent, no lettering, UI, seals, gold trim or marble veins. Based on user composition reference; architecture and empty work surface only.

**registry_paper**

Orthographic 7:4 full-bleed plain used ivory rag paper; subtle fibres and handling at corners; quiet central 95 percent; no frame, seals, symbols, letters, stains or decorative ageing.

**registry_wax_trace**

Isolated red wax registry impression, three incisions joined by a base, no letters. Remove metal and stone from the existing registry emblem, genuinely transparent background. Small confirmed signature and archive trace, no decoration.

## Verifiche locali

- Import Godot 4.6.2, audio Dummy: PASS.
- Testing playbook statico: 45/45 PASS sul candidato di runtime.
- KEYBOARD_FULL_RUN: PASS, ritorno al menu; profilo temporaneo.
- Matrice renderer Compatibility: 108 catture viewport, IT/EN/ES a 1280x720 e
  1920x1080. Banco senza/con fondi, firma, registrazione, patto, giudizio,
  gesto e focus, quietanza e notifica, rilancio in focus, opzioni bloccate,
  dettaglio Segni, tre esiti, utility in focus e fascicolo chiuso.
- Ingombri e sovrapposizioni verificati dal fixture; viste rappresentative
  ispezionate direttamente, inclusi i testi spagnoli e gli stati affollati.
- Riferimenti documentali, encoding e diff ricontrollati alla consegna.

Le catture sono fixture di presentazione, non sessioni giocate. Lo stato
campione viene costruito separatamente dal flow ed e' marcato come tale nel
report JSON. Non prova bilanciamento, ritmo, comfort, resa audio o accettazione
artistica. Reduced motion e' attivo nel fixture; lo smoke usa il flow normale.
Nessun checkpoint Linux, export, Content Lock o CP-03 viene dichiarato chiuso.

Prove: `artifacts/banco_2026-10-08/` contiene import_result.json,
static/testing_playbook_summary.json, keyboard_summary.json, layout/summary.json
e le catture PNG. candidate_manifest.json identifica i file effettivi tramite
SHA-256. Il renderer segnala il riavvio forzato fra fixture: e' intenzionale.

## Revisione in gioco

Avviare `artifacts/banco_2026-10-08/review.cmd`: usa il progetto locale con
un profilo nuovo separato dai salvataggi personali. Il launcher e' interattivo;
le verifiche automatiche sono state eseguite minimizzate e con audio Dummy.

Controllare continuita' Registro -> gesto -> giudizio -> quietanza -> fascicolo,
lettura della posta, peso dei due gesti, contrasto sul piano e naturalezza delle
superfici. Queste restano valutazioni umane sul candidato locale.

## File di questo pass

Lista separata dalle modifiche gia' presenti all'inizio; inclusi i sidecar e le
traduzioni rigenerate. Il report stesso e' `docs/support/counter_ui_2026-10-08.md`.

- `assets/i18n/en.csv`
- `assets/i18n/en.en.translation`
- `assets/i18n/es.csv`
- `assets/i18n/es.es.translation`
- `assets/i18n/it.csv`
- `assets/i18n/it.it.translation`
- `assets/ui/fonts/font_title_outline.tres`
- `assets/ui/generated/manifest.json`
- `assets/ui/generated/registry_counter.png`
- `assets/ui/generated/registry_counter.png.import`
- `assets/ui/generated/registry_paper.png`
- `assets/ui/generated/registry_paper.png.import`
- `assets/ui/generated/registry_wax_trace.png`
- `assets/ui/generated/registry_wax_trace.png.import`
- `assets/ui/official/objects/arena_gesture/sb_arena_gesture_placa_disabled.tres`
- `assets/ui/official/objects/arena_gesture/sb_arena_gesture_placa_focus.tres`
- `assets/ui/official/objects/arena_gesture/sb_arena_gesture_placa_normal.tres`
- `assets/ui/official/objects/arena_gesture/sb_arena_gesture_placa_pressed.tres`
- `assets/ui/official/objects/arena_gesture/sb_arena_gesture_placa_selected.tres`
- `assets/ui/official/objects/arena_gesture/sb_arena_gesture_provoca_disabled.tres`
- `assets/ui/official/objects/arena_gesture/sb_arena_gesture_provoca_focus.tres`
- `assets/ui/official/objects/arena_gesture/sb_arena_gesture_provoca_normal.tres`
- `assets/ui/official/objects/arena_gesture/sb_arena_gesture_provoca_pressed.tres`
- `assets/ui/official/objects/arena_gesture/sb_arena_gesture_provoca_selected.tres`
- `assets/ui/official/objects/final_dossier/sb_registry_final_dossier_closed.tres`
- `assets/ui/official/objects/final_dossier/sb_registry_final_dossier_open.tres`
- `assets/ui/official/objects/final_dossier/sb_registry_final_dossier_tab_disabled.tres`
- `assets/ui/official/objects/final_dossier/sb_registry_final_dossier_tab_focus.tres`
- `assets/ui/official/objects/final_dossier/sb_registry_final_dossier_tab_normal.tres`
- `assets/ui/official/objects/final_dossier/sb_registry_final_dossier_tab_pressed.tres`
- `assets/ui/official/objects/final_dossier/sb_registry_final_dossier_tab_selected.tres`
- `assets/ui/official/objects/final_dossier/sb_registry_final_dossier_updated.tres`
- `assets/ui/official/objects/promise_signature/sb_registry_promise_signature_disabled.tres`
- `assets/ui/official/objects/promise_signature/sb_registry_promise_signature_focus.tres`
- `assets/ui/official/objects/promise_signature/sb_registry_promise_signature_normal.tres`
- `assets/ui/official/objects/promise_signature/sb_registry_promise_signature_pressed.tres`
- `assets/ui/official/objects/promise_signature/sb_registry_promise_signature_selected.tres`
- `assets/ui/official/objects/promise_signature/sb_registry_promise_signature_signed.tres`
- `assets/ui/official/objects/receipt/sb_registry_receipt_disabled.tres`
- `assets/ui/official/objects/receipt/sb_registry_receipt_focus.tres`
- `assets/ui/official/objects/receipt/sb_registry_receipt_normal.tres`
- `assets/ui/official/objects/receipt/sb_registry_receipt_pressed.tres`
- `assets/ui/official/objects/registry_table/sb_registry_table_closed_disabled.tres`
- `assets/ui/official/objects/registry_table/sb_registry_table_closed_focus.tres`
- `assets/ui/official/objects/registry_table/sb_registry_table_closed_normal.tres`
- `assets/ui/official/objects/registry_table/sb_registry_table_closed_pressed.tres`
- `assets/ui/official/objects/registry_table/sb_registry_table_open.tres`
- `assets/ui/official/objects/second_incision/sb_registry_second_incision_disabled.tres`
- `assets/ui/official/objects/second_incision/sb_registry_second_incision_focus.tres`
- `assets/ui/official/objects/second_incision/sb_registry_second_incision_normal.tres`
- `assets/ui/official/objects/second_incision/sb_registry_second_incision_pressed.tres`
- `assets/ui/official/objects/second_incision/sb_registry_second_incision_sealed.tres`
- `assets/ui/official/styleboxes/sb_button_primary_disabled.tres`
- `assets/ui/official/styleboxes/sb_button_primary_hover.tres`
- `assets/ui/official/styleboxes/sb_button_primary_normal.tres`
- `assets/ui/official/styleboxes/sb_button_primary_pressed.tres`
- `assets/ui/official/styleboxes/sb_counter_empty.tres`
- `assets/ui/official/styleboxes/sb_counter_section.tres`
- `assets/ui/official/styleboxes/sb_counter_utility.tres`
- `assets/ui/official/styleboxes/sb_mid_choice_panel.tres`
- `assets/ui/official/styleboxes/sb_panel_main.tres`
- `assets/ui/official/styleboxes/sb_pressure_rail.tres`
- `assets/ui/official/styleboxes/sb_register_slab.tres`
- `assets/ui/official/styleboxes/sb_register_slab_closed.tres`
- `assets/ui/official/styleboxes/sb_scars_dossier.tres`
- `assets/ui/official/styleboxes/sb_settings_header.tres`
- `assets/ui/official/typography/LibreBaskerville.ttf`
- `assets/ui/official/typography/LibreBaskerville.ttf.import`
- `assets/ui/official/typography/OFL.txt`
- `docs/README.md`
- `docs/art_direction.md`
- `docs/asset_pipeline.md`
- `docs/canon/UI_CANON.md`
- `docs/content_bible.md`
- `docs/development_plan.md`
- `docs/layout_rules.md`
- `docs/testing.md`
- `scenes/UI.tscn`
- `scenes/ui/BettingCircle.tscn`
- `scripts/ci/generated_art_contract.py`
- `scripts/ci/test_push_luck_counter_contract.py`
- `scripts/ui/betting_circle_ui.gd`
- `scripts/ui/ui_root.gd`
- `tools/counter_layout_capture.gd`
- `tools/counter_layout_capture.gd.uid`
