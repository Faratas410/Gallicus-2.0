# Manifesto del Verdetto - prima applicazione, 8 ottobre 2026

## Decisione

L'utente sceglie la proposta 3 e allega la rifinitura: numero dominante nella
fascia rossa, due azioni basse avorio/rosso, colonna nera del Registro, arena
aperta. Questa e' l'identita' comune della UI, non una nuova meccanica.
Regole complete in `docs/art_direction.md`.

## Oggetti e autorita'

La quietanza chiude il dovuto; la seconda incisione mantiene il rischio;
il marchio conserva la via di uscita quando l'incasso e' bloccato. I controlli
esistenti mantengono intenti, focus, disabilitazione, feedback e recupero.
Il nuovo livello di presentazione legge soltanto payload e metadati esistenti.
Nessuna modifica di questo pass a RunManager, salvataggi o ricompense.

## Applicazione

`scripts/ui/manifesto_verdict.gd` compone la decisione nella scena UI esistente:
fascia della posta, aree delle azioni basse, nero sotto la colonna informativa.
Le forme e i tagli sono geometria nativa deterministica, senza RNG di gioco,
texture animate o testo rasterizzato. Le descrizioni conservano superfici calme.
Il fondale pittorico esistente rimane visibile senza il gradiente scuro di
lettura globale durante questa fase.

La posta numerica viene dal payload, separata dal titolo tradotto IT/EN/ES.
Non viene estratta dal testo. La composizione deve sostenere anche tre azioni
quando compare il marchio, valori a piu' cifre e blocchi con motivazione.
Le posizioni HUD precedenti vengono ripristinate all'uscita dalla fase.

Font display: Roboto Serif, peso 900, larghezza 62.5, dimensione ottica 48.
La condensazione usa l'asse reale del font, senza comprimere solo i contorni
dei glifi. File originale distribuito con la relativa licenza
[SIL OFL](https://github.com/google/fonts/blob/main/ofl/robotoserif/OFL.txt)
in `assets/ui/official/typography/roboto_serif/`; descrizioni nel font UI esistente.

La direzione comune e' adottata, ma questa prima applicazione non dichiara
uniformati Registro, Gradinata, menu e Archivio. Il corvo decorativo della
reference non e' aggiunto come icona o personaggio. Il pubblico resta nel mondo.

## Evidenze locali

`artifacts/manifesto_2026-10-08/` conserva snapshot prima del pass, fixture,
reference scelta, log e catture Godot. La verifica usa profili isolati,
audio Dummy e finestra minimizzata. Fixture mantenuta in
`tools/counter_layout_capture.gd`.

- Import Godot: exit 0.
- Suite statica: PASS, inclusi contratti degli oggetti e localizzazione.
- KEYBOARD_FULL_RUN: PASS, esecuzione diagnostica Windows.
- Matrice: 126 catture IT/EN/ES a 720p e 1080p, zero errori di contenimento
  o sovrapposizione rilevati. Include pressione 9, posta 1234, blocchi,
  impronte, focus, dettaglio Segni e passaggio al fascicolo.
- Ispezione visiva di stati rappresentativi: scelta, tre azioni, lingue,
  conferma e resoconto. I test geometrici non sostituiscono questa revisione.
- Riferimenti docs, scansione mojibake del repository e diff verificati.

Il font e i bordi sono una realizzazione nativa della direzione scelta;
non una riproduzione pixel per pixel del raster. A 1080p font e target restano
in pixel logici, con maggiore apertura sull'arena. I precedenti fondali del
Registro e del fascicolo restano da uniformare. La nuova identita' non chiude
l'accettazione dell'intero gioco, il checkpoint Linux o un gate di release.

## File di questo pass

- `scenes/UI.tscn` e `scripts/ui/ui_root.gd`: collegamento alla presentazione,
  geometrie della decisione, titoli HUD e impronta nel fascicolo.
- `scripts/ui/manifesto_verdict.gd` e `scripts/ui/registry_imprint.gd`, con
  UID importati: nuova presentazione nativa e contrassegno fisso.
- `assets/ui/fonts/font_manifesto.tres` e la cartella
  `assets/ui/official/typography/roboto_serif/`: font, import e licenza.
- `assets/i18n/it.csv`, `assets/i18n/en.csv`, `assets/i18n/es.csv` e le
  rispettive risorse translation: didascalia della posta separata dal numero.
- `scripts/ci/generated_art_contract.py`: font autorizzato con licenza.
- `scripts/ci/test_condemnation_mark_object_contract.py` e
  `scripts/ci/test_second_incision_object_contract.py`: altezza del nuovo target.
- `tools/counter_layout_capture.gd`: geometrie, stati e matrice aggiornati.
- `docs/README.md`, `docs/art_direction.md`, `docs/development_plan.md`,
  `docs/canon/UI_CANON.md`, `docs/layout_rules.md`, `docs/asset_pipeline.md`,
  `docs/testing.md` e questo report: identita', applicazione e verifiche.

Lavoro locale su main, senza commit, push o pubblicazione. Preesistenti
modifiche di scrittura, cast e UI conservate.
