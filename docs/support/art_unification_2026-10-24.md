# Uniformazione artistica - 24 ottobre 2026

## Mandato e candidato

Pass completo richiesto dall'utente dopo `docs/support/art_audit_2026-10-24.md`.
Il mandato autorizza il raccordo delle superfici alla direzione recente della
posta, senza cambiare gioco, personaggi, flow, economia, segnali o save.
Si lavora su main, HEAD `b81a4fc00797be0b0f0b7dd68639e309f3db061c`, con le
modifiche locali gia' presenti preservate. Nessun commit, push o cambio ramo.

## Risultato

- Quattro ambienti originali della stessa arena: banco, sabbia, Gradinata e
  portico. Cancello, archi, vessilli aviani, materiali e luce condivisi.
  Il fascicolo torna al portico; menu, conversazioni e congedo ne conservano
  la geografia. Le sorgenti precedenti rimangono disponibili.
- Lauro ha un nuovo cutout coerente con i cinque ritratti, conservando specie,
  piumaggio macchiato, becco, drappo e ruolo. Vessa conserva busto e vassoio
  anche nella posta, senza un ritratto quadrato separato.
- Titoli, azioni e numeri condividono la serif regolare della scena recente;
  il corpo resta sans. Il font statico OFL e' derivato dalla Roboto Serif
  originale a 400/100/32, rinominato Gallicus Serif per distinguere il derivato.
- Arena, Bando, Pressione, Catena, Favore, Conto e Segni mantengono posizione
  nelle fasi attive. La fascia legge i consumer esistenti, senza nuova
  autorita'. La seconda riga conserva anche la spiegazione della fascia di
  Favore. Colonna e rail non producono un doppio rendering.
- Focus forte a regola inferiore e blocco con barre/causa anche sulle azioni
  pittoriche. Carta del kit raccordata al fascicolo. Notifica Segno fuori
  da posta, voce e azioni. Ritorno focus al comando Segni dopo la lettura.
- Niente shake della UI o entrate che muovano target gia' attivi. Impatti
  materici brevi, particelle limitate, dissolvenza comune; Movimento ridotto
  cancella gli effetti in corso e mostra subito i valori autorevoli.
- Folla rada con piedi ancorati, piccole reazioni e luce lenta sulle lampade
  gia' dipinte. Rimossa la seconda fiamma poligonale e il bob verticale.
- Tutti i fondali, compresi banco e atmosfera della posta, ricevono la stessa
  sottrazione/ossidazione dalla query del Registro. UI e focus non ricevono
  il trattamento ambientale. La progressione autorevole non e' modificata.
- Utility e crediti terminali raccordati al kit, preservando solo nero,
  crediti/uscita e tempi del congedo ammessi dal canon.

## Asset e riproducibilita'

I cinque PNG nuovi sono prodotti con lo strumento integrato ImageGen.
Prompt integrali, sorgenti di riferimento, output, dimensioni, alpha e SHA-256
sono in `assets/ui/generated/manifest.json`. I byte generati sono copiati
senza ritocchi successivi; gli originali precedenti sono conservati.

| File | Ruolo |
| --- | --- |
| `assets/ui/generated/arena_unified.png` | Sabbia del giudizio e della posta |
| `assets/ui/generated/crowd_unified.png` | Cambio di sguardo alla Gradinata |
| `assets/ui/generated/registry_counter_unified.png` | Banco e tavola contrattuale |
| `assets/ui/generated/portico_unified.png` | Soglia, lettura, fascicolo e congedo |
| `assets/ui/generated/dialogue_lauro_cutout.png` | Lauro nel Museo e nelle conversazioni |

Font derivato e ricevuta: `assets/ui/official/typography/roboto_serif/GallicusSerif-Regular.ttf`
e relativo JSON; licenza OFL adiacente. Rigenerazione con fontTools 4.67.0:
`python tools/build_ritual_font.py`. Il tool accetta `--fonttools-path` per
un'installazione locale separata; non serve fontTools al gioco o ai test CI.
Lo hash del derivato e' nella ricevuta. Nessun font di sistema entra nella build.

La verifica ha isolato un errore di shaping Godot 4.6.2 nel cambio della
faccia nativa invisibile delle azioni estese. Il kit lascia quella faccia
semantica invariata e rende il titolo con il font comune. Non si sopprime
il log e non si sostituisce il testo con una bitmap.

## File del pass

- UI condivisa: `scripts/ui/manifesto_kit.gd`, `manifesto_action_surface.gd`,
  `manifesto_document_surface.gd`, `impact_feedback.gd`, `ui_root.gd`.
- Posta e presenza: `scripts/ui/manifesto_verdict.gd`, `verdict_object.gd`,
  `verdict_atmosphere.gd`; nuovi `ritual_status_header.gd`,
  `ritual_environment.gd` e `assets/ui/official/ritual_aging.gdshader`.
- Consumer: `scripts/ui/betting_circle_ui.gd`, `main_menu.gd`,
  `opening_prologue.gd`, `registry_terminal_view.gd`,
  `scripts/content/arena_characters.gd`, `campaign_dialogues.gd`,
  `scripts/scenes/arena/arena.gd`.
- Scene: `scenes/Main.tscn`, `scenes/UI.tscn`, `scenes/ui/BettingCircle.tscn`.
- Asset: cinque PNG con import, manifest, due wrapper font,
  TTF statico/ricevuta/import e shader/UID.
- Verifiche: `scripts/ci/art_uniformity_runtime_contract.gd`,
  `run_art_uniformity_contract.py`, `run_testing_playbook.py`,
  `generated_art_contract.py` (font ammesso con licenza, ricevuta e hash),
  `tools/build_ritual_font.py`, cleanup di `tools/living_verdict_capture.gd`.
- Owner: art direction, layout, UI canon, cinematic direction, asset pipeline, testing,
  README e development plan. Audit precedente conservato come diagnosi.

RunManager, GameEvents, save ed economia non sono cambiati dal pass.
Il working tree contiene anche modifiche precedenti in quelle aree:
la consegna non le attribuisce a questa uniformazione.

## Verifiche ed evidenze

Radice locale: `artifacts/art_unification_2026-10-24/`.
`diff_before.txt` e `status_before.txt` identificano la base dirty.
I tentativi diagnostici intermedi sono separati dagli output finali.

Contratto dedicato: 253 verifiche PASS su trasformazione canvas, arresto
degli effetti tramite l'opzione reale, gauge/conteggio, particelle, stabilita'
della fascia nelle tre lingue e trattamento dei fondali nelle tre run di
ogni ramp, con UI e focus esclusi dalla deriva ambientale.
Profili usa e getta, Godot 4.6.2 ufficiale, Windows; audio Dummy.

Evidenze finali in `artifacts/art_unification_2026-10-24/delivery/`:

- 276 PNG: counter 138, utility 62, posta 50, cast/terminale/movimento/deriva
  26. Matrice UI in IT/EN/ES, viewport logiche 1280x720 e 1920x1080.
  Le catture sono verificate anche con sonde di contenimento del testo e
  posizione dei target; non equivalgono a una sessione fisica DPI/fullscreen.
- `capture_manifest.json`: dimensioni e SHA-256 dei PNG.
  `candidate.json`: HEAD, main dirty, hash delle sorgenti e confronto dei
  diff precedenti di autorita' del gioco, driver, fixture CP-02 e CSV locale.
  I sei diff protetti risultano invariati; anche gli hash degli 87 file di
  `scripts/systems/` e `assets/i18n/` coincidono con il candidato dell'audit.
- `checks/testing_playbook_summary.json`: tutti i nove passi runtime PASS:
  CP-02, audit runtime, uniformazione, audiovisivo, campagna con riavvio
  terminale e KEYBOARD_FULL_RUN/ROUTE_CASHOUT/ROUTE_DOUBLE/ROUTE_CONDANNA.
  La prima esecuzione ha segnalato il vecchio elenco dei font ammessi nel
  solo controllo statico textual_style; il contratto e' stato aggiornato
  per validare anche ricevuta, sorgente, assi e hash del derivato.
- `static_final/testing_playbook_summary.json`: tutti i 45 passi statici
  PASS dopo l'allineamento del contratto e dei documenti. Riferimenti docs,
  scansione mojibake e `git diff --check` ripetuti alla consegna.
- Import editor separato: `import_authorized.log` nella radice delle prove,
  PASS senza errori di risorsa o script. La sandbox impediva SafeSave su file
  editor: l'import e' stato ripetuto con autorizzazione automatica e profilo
  temporaneo, poi il playbook ha riusato gli import con `--skip-import`.

La fixture della campagna riporta un warning ObjectDB alla chiusura, pur
passando il percorso e il riavvio senza errori runtime. CP-02 conserva la
prova intenzionale di JSON malformato; l'audit conserva la prova di save
assente. Questi log non vengono presentati come assenza assoluta di warning.

[Galleria locale con gli originali](../../artifacts/art_unification_2026-10-24/delivery/review.html).
Gli artifact ignorati da Git restano una consegna locale; i PNG di gioco,
la provenienza, il font, i contratti e questo documento sono nel working tree.

![Confronto prima e dopo](../../artifacts/art_unification_2026-10-24/delivery/prima-dopo.jpg)

![Sequenza uniformata](../../artifacts/art_unification_2026-10-24/delivery/sequenza.jpg)

## Limiti di accettazione

Questa patch uniforma il candidato locale. Le fixture non sostituiscono una
campagna umana, la valutazione del comfort visivo o il checkpoint Linux.
Nessuna pubblicazione Steam, esportazione o accettazione CP-03 e' implicita.
Stage Core Playable Candidate invariato. Non si aggiungono nuove meccaniche,
nuovi personaggi, rig completo del cast o nuove regole di evoluzione.
