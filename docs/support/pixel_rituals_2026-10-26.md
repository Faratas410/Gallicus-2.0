# Patto, Gradinata e Rito nella famiglia del Registro

## Mandato e perimetro

L'utente approva di procedere dopo l'inventario del 26 ottobre. Questo primo
pacchetto uniforma le tre schermate prioritarie: Patto, Gradinata e Rito.
Stage invariato: Core Playable Candidate. Candidato locale su main, HEAD
b81a4fc00797be0b0f0b7dd68639e309f3db061c con modifiche preesistenti preservate.
Nessun commit, push o cambio di ownership. Le restanti voci dell'inventario
restano aperte; questo pass non dichiara uniformato l'intero gioco.

## Oggetti e resa

| Intento | Oggetto e gesto | Conseguenza e registrazione | Owner / intento |
| --- | --- | --- | --- |
| Riconoscere il patto | Tavoletta in cuoio, carta e sigillo; mostrare | Convalida visiva dopo l'atto; nessuna seconda firma | RunManager / request_ritual_advance("pact") |
| Esporsi alla folla | Tessera in bronzo o cuoio rosso; indicare | Prezzo completo scritto prima del gesto; traccia laterale sulla selezione | RunManager / request_intermediate_choice |
| Forzare o arrestare il responso | Sigillo su basalto e verbale su tavola; colpire o alzare la mano | Tre incavi riempiti dai colpi, crepa solo dopo cedimento; esito, costo del Segno e rilancio completi | RunManager / request_ritual_advance, seal_strike_resolved |

L'arena aviana pixel art del Registro, la luce calda, l'insegna rossa e l'HUD
sono condivisi. Il cast realistico sovrapposto dal vecchio strato di folla
non viene aggiunto a queste tre vedute. L'invecchiamento ambientale resta
guidato dalla query di presentazione del manager anche su questo fondale.

La nuova grafica e passiva: i Button nativi conservano testi semantici,
focus, segnali, disponibilita e blocco contro invii ripetuti. L'avanzamento
automatico del Patto appreso non cambia. Nessun testo, valore o comando e
stampato nel raster. Su carta si usa Fondamento seppia; insegna e pietra
conservano il serif leggibile. Corpi 18-20 px, atti 23-24 px, insegne 23-26 px
nella base 1280x720. Il verbale del Rito contiene tutte le conseguenze.

Focus/hover = regola sul supporto; blocco = doppia barra. La selezione della
tessera e la convalida del Patto hanno tracce distinte. I target rimangono
fermi; dissolvenza, colpi, suoni e movimento ridotto usano il percorso
esistente. Le crepe non vengono disegnate sui colpi che reggono.

## Geometria e integrazione

- `ritual_pixel_stage.gd`: adattatore locale delle tre scene, con base
  1280x592 sotto CONTENT_TOP 128 e scala uniforme al resize. Label e Button
  rimangono nei percorsi della scena. I tre contenitori di impaginazione
  passano a Control per il posizionamento sugli oggetti.
- `ritual_pixel_object.gd`: atlas, iscrizioni native, focus e stato della
  pelle; non emette intenti e non calcola outcome.
- `ui_root.gd`: installazione, preservazione della geometria al ripristino
  della motion, aggiornamento della pelle del sigillo, soppressione del
  titolo ambientale duplicato, esclusione della folla realistica sovrapposta.
- `manifesto_kit.gd`: gli adattatori riconoscono gli oggetti pixel gia
  installati, aggiornandone il copy senza ricreare il vecchio pannello.
- `ritual_environment.gd`: include il fondale pixel nel trattamento comune.
- `scenes/UI.tscn`: stessi nodi e azioni; tre container diventano Control.

## Asset e provenienza

`assets/ui/generated/ritual_objects_pixel.png`, RGBA 1254x1254, atlas 2x2
originale creato con lo strumento built-in ImageGen. Riferimenti: arena del
Registro e concept del Rito approvati. L'alpha originale e preservato;
quadranti e porzione di carta vengono letti a runtime senza ritocchi raster.
Prompt completo, source, licenza e hash in `assets/ui/generated/manifest.json`.
SHA-256: 723a6e40ef2f7d5a0f0ee1945e966792ba0ebf723cad28c53bdc5ab8f65beb42.

## Verifica ed evidenze locali

`tools/pixel_ritual_capture.gd` riusa il capture nativo ed esegue la matrice
IT/EN/ES a 1280x720 e 1920x1080, movimento ridotto e normale, tre intenzioni
della folla, colpi 1/2/3, Catena, bando e offerta del Segno. Verifica testo
entro carta/target, separazione del verbale dai comandi, geometria sotto HUD,
scala coerente e ritorno a 720p. A seguire attraversa con input nativo il
percorso firma -> Patto -> tre scambi -> Rito -> posta col manager reale.
Le risposte sintetiche della matrice sono fixture, non una prova economica.

Profili isolati in `artifacts/pixel_ritual/`. Catture e summary nella
sottocartella `final/`; log di matrice, smoke e art contract nella radice.
Le PNG sono evidenze locali ignorate da Git, non asset di distribuzione.

Esiti finali: matrice renderer reale, 66 catture e zero fallimenti; contratti
OF-07/08/09 superati; KEYBOARD_FULL_RUN superato; art uniformity 253 controlli
e zero fallimenti; riferimenti documentali, mojibake e diff check puliti.
Ispezionate le tre viste italiane e gli stati densi del Rito in inglese,
oltre alla Gradinata spagnola a 720p/1080p. Le 66 catture non equivalgono a
66 revisioni umane. [Confronto prima/dopo](../../artifacts/pixel_ritual/index.html).
La validazione Windows non sostituisce Linux canonico, controller fisico,
ritmo o playtest.

## File del pacchetto

- Nuovi: `scripts/ui/ritual_pixel_stage.gd`, `ritual_pixel_object.gd` e uid;
  `tools/pixel_ritual_capture.gd` e uid; atlas PNG e import; questo report.
- Modificati: `scripts/ui/ui_root.gd`, `manifesto_kit.gd`,
  `ritual_environment.gd`; `scenes/UI.tscn`; manifest dell'asset.
- Documenti: README, art_direction, layout_rules, testing, development_plan
  e aggiornamento dell'inventario ui_coherence_2026-10-26.

Prossimo gruppo dell'inventario: Banco e Incasso/Rilancio, seguiti dalle
schermate di consultazione e ingresso. Registro aperto e HUD restano il
campione approvato. Il vuoto del finale va preservato.
