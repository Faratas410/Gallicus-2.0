# Handoff per Astra - Manifesto del Verdetto

8 ottobre 2026. Mandato: adattare al mood di Gallicus la base visiva
confermata dall'utente e completarne l'applicazione alla UI esistente.
Modello richiesto: GPT-6 Astra. Effort consigliato: high, rispettando la
selezione esplicita dell'utente. Questo documento prepara il lavoro;
non applica modifiche runtime e non invia il mandato a un'altra chat.

## DIAGNOSIS

Decisione confermata: **teniamo Manifesto del Verdetto come base**.
Non riaprire il confronto tra concept. Conservare numero dominante,
scelte nette e spazio per l'ambiente. Adattare rosso di cera piu' spento,
avorio sporco, nero d'inchiostro e incisioni asciutte. Le grandi scritte
devono avere il peso di un atto del Registro: severo, pubblico, destinato
a restare. Tipografia, materiali e impronte tengono insieme il gioco;
ogni fase ha la propria composizione.

La prima applicazione esiste nella scelta quietanza/raddoppio:
`docs/support/manifesto_verdict_2026-10-08.md`. Non ripartire da zero.
Il numero e' nativo e proviene dal payload; la fascia rossa, le azioni
basse e la colonna nera sono gia' integrate. La direzione e' approvata,
ma l'adattamento materiale e la coerenza dell'intera sequenza restano
da implementare e valutare in gioco.

Il campione illustrato dell'arena e' distinto dalle reference spaziali:
`docs/support/illustrated_arena_2026-10-08.md` e
`docs/support/spatial_sequence_2026-10-08.md`. Queste ultime fissano una
geografia di lavoro; il loro realismo non e' il trattamento runtime scelto.
Registro, cast, sigillo e fascicolo hanno ancora differenze di dettaglio
documentate. Non dichiarare approvata tutta l'art dal solo assenso al Manifesto.

## WORKFLOW

Repository: `C:/Users/dovig/Documents/GitHub/Gallicus-2.0`.
Snapshot prima di questo handoff: branch `main`, HEAD
`da99a64c7d90341ac57f3ad0e4cad7444f6bfa02`, 132 voci modificate o aggiunte
in `git status --porcelain=v1`. Il conteggio precede gli edit di questa
consegna documentale. Ricontrollare HEAD, status e diff all'avvio.
Le modifiche presenti comprendono UI, asset, cast, scrittura e runtime;
preservarle e distinguere nel report gli edit del nuovo pass.

Leggere `AGENTS.md`, `docs/README.md`, `docs/direction.md`,
`docs/development_plan.md`, `docs/development_workflow.md`, poi
`docs/art_direction.md`, `docs/object_grammar.md`, `docs/layout_rules.md`,
`docs/canon/UI_CANON.md`, `docs/asset_pipeline.md`, `docs/testing.md` e
`docs/code_quality.md` prima degli edit runtime. I canon restano owner dei
contratti; i report spiegano il candidato e non sostituiscono l'ispezione.

Punti di partenza da verificare sul working tree:

- `scripts/ui/manifesto_verdict.gd`: composizione e palette della scelta
  sulla posta; valori attuali INK `141513`, IVORY `f4e9cc`, RED `a51c12`.
- `scripts/ui/registry_imprint.gd`: impronta nativa e stati registrati.
- `assets/ui/fonts/font_manifesto.tres`: display Roboto Serif gia' integrato;
  sorgente e licenza in `assets/ui/official/typography/roboto_serif/`.
- `scripts/ui/ui_root.gd`, `scenes/UI.tscn` e
  `scenes/ui/BettingCircle.tscn`: consumer, fasi, HUD e oggetti esistenti.
- `assets/ui/official/objects/` e `assets/ui/official/styleboxes/`:
  famiglie degli stati, materiali e superfici condivise.
- `scripts/ui/main_menu.gd` e `scripts/ui/betting_circle_ui.gd`:
  menu, consultazione e superfici da raccordare alla stessa identita'.
- `tools/counter_layout_capture.gd`: matrice locale da riusare e aggiornare
  per le superfici effettivamente cambiate, senza perdere gli stati limite.

Perimetro: presentazione della UI e raccordo delle superfici esistenti.
La revisione parte dalla scelta sulla posta e attraversa Registro/firma,
Gradinata/gesto, giudizio, esito/fascicolo, menu e Archivio. Conservare
ordine e tempi funzionali delle fasi. Nessuna nuova meccanica, scena
narrativa, riscrittura, colonna sonora o riprogettazione completa del cast.
Eventuali asset necessari a questo raccordo seguono l'asset pipeline;
il rifacimento integrale degli ambienti e dei ritratti e' un pacchetto distinto.

RunManager mantiene il flow; GameEvents mantiene gli eventi; la UI osserva
stato pubblico ed emette gli intenti gia' previsti. Conservare payload,
segnali, save, RNG, economia, ricompense, regole e ordine degli sblocchi.
L'impronta compare solo dopo una conferma autorevole esistente e resta
nella superficie di memoria prevista; non decide un esito. I tre tagli
identificano il Registro e non contano i Segni.

Un solo agente responsabile, direttamente su `main`. Nessun branch,
commit, push, PR o pubblicazione. Non alterare modello o impostazioni
dell'app. Non riprendere il playtest visibile interrotto senza richiesta:
usare verifiche mirate con profili isolati e audio Dummy.

## NEXT ACTION

1. Catturare la sequenza corrente con UI reale e annotare per ogni fase
   oggetto dominante, gesto, gerarchia, materiale e spazio dell'ambiente.
   Separare difetti osservati da proposte. Confrontare la scelta sulla
   posta con la reference approvata e con le fasi adiacenti.
2. Integrare il primo adattamento nella scelta sulla posta: rosso piu'
   spento, avorio sporco, nero d'inchiostro, tagli essenziali. Scegliere
   i valori colore confrontando catture sul fondale reale a 720p; riportare
   i valori finali. Conservare proporzioni, numero dominante e comandi
   netti. Usare il display esistente come prima base: peso, spaziatura
   e gerarchia devono sostenere l'atto pubblico senza comprimere
   artificialmente i glifi o sacrificare le descrizioni.
3. Portare lo stesso linguaggio attraverso la sequenza, con composizioni
   specifiche secondo la tabella. Il campione serve a fissare il criterio;
   completare il pass integrato, non fermarsi a un mockup o a una specifica.
4. Aggiornare gli owner di art, layout e asset; aggiornare UI_CANON solo
   per il comportamento di presentazione realmente cambiato. Raccordare
   le regole operative di colore e collocazione HUD in `docs/direction.md`
   se necessario, senza ridefinire meccaniche o informazioni visibili.
   Aggiornare la roadmap con perimetro, prove e limiti del candidato.

| Fase | Composizione da sviluppare | Punto da preservare |
| --- | --- | --- |
| Registro e firma | Documento o tavola in primo piano, autorita' nell'allineamento e nella scritta; cera nel punto del consenso | Oggetto, patto, costo e firma leggibili sullo stesso supporto; banco confinato al Registro |
| Gradinata e gesto | Pubblico e ambiente leggibili; risposte nette ai margini o in basso | Intento della folla e prezzo delle risposte espliciti; nessun banco sovrapposto all'arena |
| Giudizio | Sigillo e gesto centrali, scritte severe subordinate all'atto | Cera, stati e input riconoscibili; effetto gia' deciso dall'autorita' esistente |
| Quietanza / rilancio | Numero della posta dominante, scelte basse distinte, arena aperta | Terza azione del marchio quando prevista; blocchi, motivazioni e focus leggibili |
| Esito e fascicolo | Risultato impresso, carta di memoria e prosecuzione distinta; riferimento al portico | Traccia confermata e contenuti del percorso; gerarchia diversa dalla decisione di rischio |
| Menu e Archivio | Titolo pubblico nel menu, consultazione ordinata nell'Archivio | Stessa famiglia tipografica e materiale, con navigazione e scroll prevedibili |

La fascia rossa della posta resta propria della decisione di rischio.
Il numero dominante guida quella scelta; nelle altre fasi domina l'oggetto
pertinente. Non aggiungere un numero, un'impronta o una fascia senza funzione.

Incisioni e ruvidita' restano ai margini, con aree di lettura calme.
Niente micrograna fotografica, testo rasterizzato, ornamenti aggiunti per
riempire lo spazio o pannelli opachi estesi per nascondere un contrasto
irrisolto. Colore e materiale devono mantenere il significato dei gesti;
focus, disponibilita' e conseguenza restano espliciti anche senza colore.
I titoli acquistano peso attraverso forma e composizione: non aggiungere
nuove frasi del Registro per ottenere solemnita'.

## EXPECTED HANDOFF

Consegnare una patch locale giocabile e una sequenza prima/dopo, con lo
stesso stato di prova, lingua e risoluzione. Il report deve contenere:

- mappa delle fasi toccate, scelte di composizione, palette finale,
  font/materiali/impronte e file cambiati dal pass;
- screenshot Godot delle fasi e dei passaggi adiacenti, percorso dei log,
  elenco delle immagini realmente ispezionate e difetti risolti;
- HEAD e stato dirty del candidato; per nuovi raster, provenienza,
  licenza quando pertinente e SHA-256 nel manifest previsto;
- verifiche eseguite, risultati e problemi residui, separando il lavoro
  conservato da quello nuovo e gli asset da uniformare in un pass successivo.

Verifiche richieste per il candidato implementato:

1. Import Godot 4.6.2 e playbook statico completo secondo `docs/testing.md`.
   Verificare contratti UI/oggetti, localizzazione e path pertinenti.
2. Matrice IT/EN/ES a 1280x720 e 1920x1080 sulle superfici cambiate:
   normal, focus, pressed, disabled e registrato/selected dove applicabili.
   Includere posta a quattro cifre, pressione 0 e 9, tre azioni,
   motivazioni di blocco, testi lunghi, dettaglio Segni e fascicolo.
3. Ispezionare contenimento, contrasto, gerarchia, spazio dell'ambiente,
   target cliccabili anche sotto le note, tastiera, ordine del focus e scroll.
   Controllare transizioni: niente residui della fascia, perdita del focus
   o HUD spostato nelle fasi successive. Verificare motion normale e ridotto:
   hover e pressione non spostano i comandi.
4. Eseguire KEYBOARD_FULL_RUN sul candidato e le route pertinenti agli
   oggetti toccati. Le fixture visuali non sostituiscono il flow reale.
   Classificare warning e controllare anche teardown ed exit.
5. Chiudere con riferimenti docs, scan mojibake del repository e
   `git diff --check`. Non abbassare contratti o gate per rendere verdi
   le prove; aggiornare fixture solo se riflettono il nuovo comportamento
   di presentazione autorizzato.

Usare profili temporanei nel workspace sotto `artifacts/`; su questa
macchina isolare anche APPDATA, LOCALAPPDATA e TEMP/TMP per import e test.
Il Python disponibile e' quello bundled Codex: verificarne il percorso
prima di invocare i runner. Confrontare le prove dei report precedenti,
senza trasferirne i PASS al nuovo candidato.

Gate di ritorno: revisione umana della sequenza renderizzata per verificare
peso pubblico delle scritte, tono dei materiali, chiarezza delle scelte
e continuita' fra fasi. La conferma del Manifesto autorizza l'adattamento
della base; non certifica questi risultati prima di vederli.
Stage invariato: Core Playable Candidate. Checkpoint Linux, CP-03,
Audiovisual Lock e pubblicazione Steam restano gate distinti.
