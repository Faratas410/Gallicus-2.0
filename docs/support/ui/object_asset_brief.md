# Object Asset Brief

Status: active supporting brief
Purpose: define the first object-first asset families required by the roadmap.

## Regole comuni

- Testo renderizzato da Godot.
- Materiali coerenti con `docs/art_direction.md`.
- Stati con geometria stabile.
- Safe area sufficiente per IT/EN/ES.
- Nessun watermark, arma, teschio o decorazione non funzionale.
- PNG trasparente per oggetti; background separati.

## Quietanza

Uso: route cashout.

- Foglio o tavoletta contabile con corda/segno di chiusura.
- Stati: normal, focus, taken, disabled.
- Il gesto e' prendere o marcare la quietanza.
- Deve comunicare chiusura prudente, non premio ricco.

### Scheda OF-01

```text
Intento del soggetto: chiudere il percorso e prendere quanto registrato.
Oggetto: quietanza contabile con legaccio e sigillo di chiusura.
Materiale: carta sporca, bronzo pallido, corda scura.
Gesto: prendere la quietanza e tirare il legaccio.
Stato prima: importo e conseguenza leggibili; quietanza disponibile o bloccata.
Stato dopo: quietanza ritirata, legaccio chiuso, fascicolo pronto.
Feedback visivo: breve presa verticale e chiusura del legaccio.
Feedback audio: carta asciutta seguita da un colpo breve di bronzo.
Feedback testuale: valore incassato e corruzione rimossa.
Registrazione prodotta: run end reason CASH_OUT.
Owner dati/flow: RunManager.
Segnale GameEvents: request_pyl_cashout, invariato.
Fallback accessibile: focus netto; stato registered immediato senza movimento.
Schermata o scenario QA: Phase_PUSH_YOUR_LUCK e ROUTE_CASHOUT.
```

Asset previsto:

- sorgente trasparente senza testo, rapporto `5:2`;
- safe area centrale libera per copy renderizzato da Godot;
- stati con geometria identica: normal, focus, taken, disabled;
- destinazione `assets/ui/official/objects/receipt/`;
- texture condivisa:
  `registry_receipt_base.png`;
- risorse:
  `sb_registry_receipt_normal.tres`,
  `sb_registry_receipt_focus.tres`,
  `sb_registry_receipt_pressed.tres` e
  `sb_registry_receipt_disabled.tres`;
- provenienza visuale: generazione originale built-in su chroma-key e
  rimozione locale dello sfondo; nessuna fonte third-party;
- cue originale procedurale:
  `res://assets/audio/sfx/registry_receipt_take.wav`;
- consumer:
  `Btn_PUSH_YOUR_LUCK_CASHOUT` dentro `res://scenes/UI.tscn`;
- nessuna modifica a payout, eleggibilita', payload o transizione;
- lo stato taken e' immediato e non richiede movimento;
- reduced motion riceve la stessa informazione tramite stato, contrasto, copy
  e cue.

Accettazione OF-01:

- oggetto riconoscibile senza leggere la label;
- valore e conseguenza restano leggibili in IT/EN/ES;
- disabled mostra la causa gia' fornita dal payload;
- mouse, tastiera e focus emettono lo stesso intento;
- screenshot viewport-only a 1280x720 e 1920x1080;
- `ROUTE_CASHOUT` e ritual-loop contract verdi.

## Marchio

Uso: route condanna.

- Timbro, ferro o sigillo avverso.
- Stati: normal, focus, heated, registered.
- Il gesto e' esporre la superficie e ricevere l'impronta.
- Nessun gore esplicito.

### Scheda OF-02

```text
Intento del soggetto: accettare il costo e chiudere il percorso senza premio.
Oggetto: ferro-timbro amministrativo di condanna.
Materiale: ferro annerito, bordo consumato, calore rosso smorzato, rivetti di bronzo.
Gesto: ricevere il marchio.
Conseguenza leggibile prima del gesto: perdita della posta e chiusura del percorso.
Stato prima: marchio disponibile, focus o bloccato senza sembrare gia' registrato.
Stato dopo: marchio registrato e oggetto spento dal lock esistente.
Feedback visivo: ferro caldo/registered immediato, senza movimento obbligatorio.
Feedback audio: colpo basso di ferro con coda termica smorzata.
Feedback testuale: perdita della posta e Registro chiuso.
Registrazione prodotta: route condanna invariata.
Owner dati/flow: RunManager.
Segnale GameEvents: request_pyl_condanna, invariato.
Fallback accessibile: focus netto; stato registered immediato senza movimento.
Schermata o scenario QA: Phase_PUSH_YOUR_LUCK e ROUTE_CONDANNA.
```

Asset previsto:

- sorgente trasparente senza testo, rapporto `5:2`;
- safe area centrale libera per copy renderizzato da Godot;
- stati con geometria identica: normal, focus, heated/pressed, registered,
  disabled;
- destinazione `assets/ui/official/objects/condemnation_mark/`;
- texture condivisa:
  `registry_condemnation_mark_base.png`;
- risorse:
  `sb_registry_condemnation_mark_normal.tres`,
  `sb_registry_condemnation_mark_focus.tres`,
  `sb_registry_condemnation_mark_pressed.tres`,
  `sb_registry_condemnation_mark_registered.tres` e
  `sb_registry_condemnation_mark_disabled.tres`;
- provenienza visuale: generazione originale built-in su chroma-key e
  rimozione locale dello sfondo; nessuna fonte third-party;
- cue originale procedurale:
  `res://assets/audio/sfx/registry_condemnation_mark.wav`;
- consumer:
  `Btn_PUSH_YOUR_LUCK_CONDANNA` dentro `res://scenes/UI.tscn`;
- nessuna modifica a reward, eleggibilita', payload o transizione;
- lo stato registered e' immediato e non richiede movimento;
- reduced motion riceve la stessa informazione tramite stato, contrasto, copy
  e cue.

Accettazione OF-02:

- oggetto riconoscibile senza leggere la label;
- costo e conseguenza restano leggibili in IT/EN/ES;
- disabled non sembra una condanna gia' scelta;
- mouse, tastiera e focus emettono lo stesso intento;
- screenshot viewport-only a 1280x720 e 1920x1080;
- `ROUTE_CONDANNA` e ritual-loop contract verdi.

## Seconda incisione

Uso: route double.

- Tavoletta gia' firmata con spazio per una seconda linea.
- Stati: normal, focus, pressed/incised, sealed, disabled.
- Il gesto e' incidere nuovamente.
- Deve mostrare pressione e continuita', non un generico moltiplicatore.

### Scheda OF-03

```text
Intento del soggetto: rifiutare la chiusura e aumentare la posta registrata.
Oggetto: tavoletta di cera gia' firmata con una seconda linea di incisione.
Materiale: basalto, bronzo pallido, cera rossa compressa.
Gesto: incidere nuovamente e sigillare la continuita'.
Conseguenza leggibile prima del gesto: prossima posta e Pressione +1 dal payload.
Stato prima: prima incisione presente; seconda incisione disponibile, in focus o bloccata.
Stato dopo: seconda incisione sigillata e oggetto spento dal lock esistente.
Feedback visivo: incisione calda e stato sealed immediato, senza movimento obbligatorio.
Feedback audio: graffio asciutto nella cera seguito da un breve colpo di bronzo.
Feedback testuale: RADDOPPIA con prossima posta e incremento di pressione.
Registrazione prodotta: rilancio invariato.
Owner dati/flow: RunManager.
Segnale GameEvents: request_pyl_double, invariato.
Fallback accessibile: focus netto; stato sealed immediato senza movimento.
Schermata o scenario QA: Phase_PUSH_YOUR_LUCK e ROUTE_DOUBLE.
```

Asset previsto:

- sorgente trasparente senza testo, rapporto `5:2`;
- safe area centrale libera per copy renderizzato da Godot;
- stati con geometria identica: normal, focus, pressed/incised, sealed,
  disabled;
- destinazione `assets/ui/official/objects/second_incision/`;
- texture condivisa:
  `registry_second_incision_sealed.png`;
- risorse:
  `sb_registry_second_incision_normal.tres`,
  `sb_registry_second_incision_focus.tres`,
  `sb_registry_second_incision_pressed.tres`,
  `sb_registry_second_incision_sealed.tres` e
  `sb_registry_second_incision_disabled.tres`;
- provenienza visuale: generazione originale built-in su chroma-key con
  quietanza e marchio come riferimenti stilistici, seguita da rimozione
  locale dello sfondo; nessuna fonte third-party;
- cue originale procedurale:
  `res://assets/audio/sfx/registry_second_incision.wav`;
- consumer:
  `Btn_PUSH_YOUR_LUCK_DOUBLE` dentro `res://scenes/UI.tscn`;
- CTA canonica `RADDOPPIA`, con traduzioni `DOUBLE` e `DOBLA`;
- nessuna modifica a reward, eleggibilita', payload o transizione;
- lo stato sealed e' immediato e non richiede movimento;
- reduced motion riceve la stessa informazione tramite stato, contrasto, copy
  e cue.

Accettazione OF-03:

- oggetto riconoscibile senza leggere la label;
- prossima posta e Pressione +1 restano leggibili in IT/EN/ES;
- disabled non sembra una seconda incisione gia' sigillata;
- mouse, tastiera e focus emettono lo stesso intento;
- screenshot viewport-only a 1280x720 e 1920x1080;
- `ROUTE_DOUBLE` e ritual-loop contract verdi.

## Pietra del giudizio

Uso: resolve ritual.

- Pietra o sigillo centrale con tre stati di impatto.
- Stati: intact, strike_1, strike_2, resolved.
- Crepe leggibili ma controllate.
- Il testo istruttivo resta su una superficie associata.

## Fascicolo

Uso: END_RUN.

- Dossier con timbro e sezioni per patto, condanna e verdetto.
- Stati: open, updated, closed.
- Route successive devono apparire come nuova tavola, pagina o uscita.

## Soglia

Uso: menu e inizio campagna.

- Porta o limite dell'arena leggibile nel primo viewport.
- Nessun pannello marketing.
- Il gesto e' entrare.
- Il brand Gallicus resta evidente.

### Scheda OF-04

```text
Intento del soggetto: accettare l'esposizione e iniziare una nuova run.
Oggetto: soglia fisica dell'arena vista appena prima dell'attraversamento.
Materiale: basalto scuro, bronzo pallido consumato e sabbia rossa compressa.
Gesto: oltrepassare la soglia.
Conseguenza leggibile prima del gesto: ingresso nell'arena e avvio della run.
Stato prima: soglia disponibile, in focus o bloccata.
Stato dopo: soglia crossed e menu ritirato dal flow esistente.
Feedback visivo: bronzo caldo e bordo di sabbia riconoscibile, senza spostare il target.
Feedback audio: sfregamento di pietra e passo sulla sabbia con breve risposta di bronzo.
Feedback testuale: ENTRA NELL'ARENA con traduzioni esistenti.
Registrazione prodotta: nuova run avviata dal flow invariato.
Owner dati/flow: RunManager.
Segnale GameEvents: request_new_run, invariato.
Fallback accessibile: focus netto e stato crossed immediato senza movimento obbligatorio.
Schermata o scenario QA: menu principale e BET_PRESENT.
```

Asset previsto:

- sorgente trasparente senza testo, rapporto `5:2`;
- safe area centrale scura per copy renderizzato da Godot;
- stati con geometria identica: normal, focus, pressed, crossed e disabled;
- destinazione `assets/ui/official/objects/arena_threshold/`;
- texture condivisa `arena_threshold_base.png`;
- risorse `sb_arena_threshold_normal.tres`,
  `sb_arena_threshold_focus.tres`, `sb_arena_threshold_pressed.tres`,
  `sb_arena_threshold_crossed.tres` e `sb_arena_threshold_disabled.tres`;
- provenienza visuale: generazione originale built-in su chroma-key con menu
  e quietanza come riferimenti stilistici, seguita da rimozione locale dello
  sfondo; nessuna fonte third-party;
- cue originale procedurale
  `res://assets/audio/sfx/arena_threshold_cross.wav`;
- consumer `NewGameButton` dentro `res://scenes/Main.tscn`;
- CTA canonica `ENTRA NELL'ARENA`, con traduzioni `ENTER THE ARENA` e
  `ENTRA EN LA ARENA`;
- nessuna modifica a flow, payload, save o transizione;
- lo stato crossed precede l'intento e non attende motion;
- reduced motion riceve la stessa informazione tramite stato, contrasto, copy
  e cue.

Accettazione OF-04:

- soglia riconoscibile senza leggere la label;
- brand e CTA leggibili in IT/EN/ES nel primo viewport;
- disabled non sembra una soglia gia' attraversata;
- mouse, tastiera e focus emettono lo stesso intento;
- 24 screenshot viewport-only a 1280x720 e 1920x1080;
- `BET_PRESENT` e ritual-loop contract verdi.

## Tavola del Registro

Uso: apertura e consultazione delle due offerte in `BET_PRESENT`.

- Tavola amministrativa a due foglie, non spellbook fantasy o modal generico.
- Stati: closed normal, focus, pressed, disabled e open persistente.
- Il gesto e' aprire; la firma delle offerte resta il gesto del pacchetto successivo.
- La conseguenza e' l'esposizione delle due offerte gia' preparate dal flow.

### Scheda OF-05

```text
Intento del soggetto: aprire il Registro e consultare le due offerte esposte.
Oggetto: tavola del Registro chiusa da sigillo e apribile in due foglie.
Materiale: basalto intatto, bronzo consumato, calcare chiaro e cera rossa spezzata.
Gesto: aprire la tavola.
Conseguenza leggibile prima del gesto: due offerte comparabili diventano consultabili.
Stato prima: tavola chiusa disponibile, in focus, premuta o bloccata.
Stato dopo: tavola aperta con due superfici leggibili e geometria invariata.
Feedback visivo: focus dorato, pressione calda, sigillo diviso e foglie esposte.
Feedback audio: scorrimento di lastra, cerniera di bronzo e assestamento grave.
Feedback testuale: APRI IL REGISTRO con traduzioni IT/EN/ES.
Registrazione prodotta: offerte esposte; nessuna decisione gameplay al solo gesto di apertura.
Owner dati/flow: RunManager.
Segnale GameEvents: nessuno per l'apertura; request_place_bet resta invariato per la firma.
Fallback accessibile: stato chiuso/aperto, focus e copy restano leggibili senza motion.
Schermata o scenario QA: BET_PRESENT, Registro chiuso e Registro aperto.
```

Asset previsto:

- due sorgenti trasparenti senza testo, rapporto `3:2` e dimensioni identiche;
- safe area centrale scura nello stato chiuso e due safe area chiare nello stato aperto;
- destinazione `assets/ui/official/objects/registry_table/`;
- texture `registry_table_closed.png` e `registry_table_open.png`;
- risorse `sb_registry_table_closed_normal.tres`,
  `sb_registry_table_closed_focus.tres`,
  `sb_registry_table_closed_pressed.tres`,
  `sb_registry_table_closed_disabled.tres` e `sb_registry_table_open.tres`;
- provenienza visuale: generazione originale built-in su chroma-key con soglia,
  quietanza e schermata Registro come riferimenti, seguita da rimozione locale
  dello sfondo; nessuna fonte third-party;
- cue originale procedurale `res://assets/audio/sfx/registry_table_open.wav`;
- consumer `ClosedBookBg`, `SpellbookBg` e `Btn_Open_Book` dentro
  `res://scenes/ui/BettingCircle.tscn`;
- CTA `APRI IL REGISTRO`, con traduzioni `OPEN THE REGISTRY` e
  `ABRE EL REGISTRO`;
- nessuna modifica a flow, payload, save, offerte o transizione;
- reduced motion riceve la stessa informazione tramite stato, contrasto, copy
  e cue.

Accettazione OF-05:

- tavola chiusa e aperta riconoscibili senza leggere la label;
- due offerte confrontabili senza wrapping distruttivo;
- CTA e intro leggibili in IT/EN/ES;
- focus, pressed, disabled e open non cambiano geometria;
- 24 screenshot viewport-only a 1280x720 e 1920x1080;
- `BET_PRESENT`, motion, i18n e ritual-loop contract verdi.

## Cartiglio della promessa

Uso: scelta e firma dell'offerta in `BET_PRESENT`.

- Cartiglio amministrativo di cera inserito nell'incavo di ciascuna foglia.
- Stati: normal, focus, pressed, selected, signed e disabled.
- Il gesto e' incidere la promessa scelta con lo stilo e registrarne
  l'impressione.
- La selezione resta confrontabile prima della firma; la geometria non cambia.

### Scheda OF-06

```text
Intento del soggetto: scegliere una promessa e vincolarsi all'offerta esposta.
Oggetto: cartiglio di cera con stilo, incastonato nella foglia del Registro.
Materiale: basalto intatto, bronzo consumato e cera rossa liscia o impressa.
Gesto: incidere la promessa e premere il segno amministrativo.
Conseguenza leggibile prima del gesto: offerta, condanna, condizione e patto restano sulla stessa foglia.
Stato prima: cartiglio blank disponibile, in focus, premuto, selezionato o bloccato.
Stato dopo: incisione e impressione signed persistono fino alla chiusura del modal.
Feedback visivo: cera selezionata calda, incisione e impronta immediate senza spostare il target.
Feedback audio: graffio asciutto dello stilo seguito da breve impressione di cera e bronzo.
Feedback testuale: FIRMA con traduzioni SIGN e FIRMAR.
Registrazione prodotta: patto scelto tramite request_place_bet invariato.
Owner dati/flow: RunManager.
Segnale GameEvents: request_place_bet, invariato.
Fallback accessibile: focus netto, stato signed e lock leggibili senza motion.
Schermata o scenario QA: BET_PRESENT, Registro aperto e matrice 03_promise_*.
```

Asset previsto:

- due sorgenti RGBA senza testo, rapporto `4:1`, dimensioni `1024x256` e alpha
  silhouette identica;
- destinazione `assets/ui/official/objects/promise_signature/`;
- texture `registry_promise_signature_blank.png` e
  `registry_promise_signature_signed.png`;
- risorse `sb_registry_promise_signature_normal.tres`,
  `sb_registry_promise_signature_focus.tres`,
  `sb_registry_promise_signature_pressed.tres`,
  `sb_registry_promise_signature_selected.tres`,
  `sb_registry_promise_signature_signed.tres` e
  `sb_registry_promise_signature_disabled.tres`;
- provenienza visuale: generazione originale built-in su chroma-key con tavola
  del Registro, soglia e seconda incisione come riferimenti, rimozione locale
  e normalizzazione della silhouette; nessuna fonte third-party;
- cue originale procedurale
  `res://assets/audio/sfx/registry_promise_sign.wav`;
- consumer `Btn_Sign_Left` e `Btn_Sign_Right` dentro
  `res://scenes/ui/BettingCircle.tscn`;
- nessuna modifica a flow, offerte, payload, save o transizione;
- signed precede lock, cue ed emissione dell'intento e non attende motion;
- reduced motion riceve la stessa informazione tramite stato, contrasto, copy
  e cue.

Accettazione OF-06:

- cartiglio blank, selected, signed e disabled riconoscibili senza variazione
  di geometria;
- CTA leggibile in IT/EN/ES e costo/promessa sulla stessa tavola;
- mouse, tastiera e focus emettono lo stesso intento;
- WAV mono PCM16 44,1 kHz, 0,45-0,70 s e picco massimo -3 dBFS;
- 30 screenshot viewport-only a 1280x720 e 1920x1080;
- `BET_PRESENT`, i18n, motion e ritual-loop contract verdi.

## Tavoletta del patto

Uso: convalida del patto nella fase `FIRST_REACTION`.

- Tavoletta amministrativa sigillata, integra e leggibile come oggetto fisico.
- Stati: normal, focus, pressed, validated e disabled.
- Il gesto e' mostrare e convalidare la tavoletta gia' sigillata.
- Tutti gli stati mantengono silhouette, margini e target invariati.

### Scheda OF-07

```text
Intento del soggetto: mostrare il patto appena registrato e proseguire nel rito.
Oggetto: tavoletta sigillata con ampio incavo centrale per la CTA.
Materiale: basalto intatto, bronzo consumato e cera rossa chiusa.
Gesto: assestare la tavoletta e convalidarne il sigillo.
Conseguenza leggibile prima del gesto: il patto e' gia' chiuso e pronto per la convalida.
Stato prima: tavoletta disponibile, in focus, premuta o bloccata.
Stato dopo: validated persiste fino alla chiusura o al cambio di fase.
Feedback visivo: bronzo e cera si scaldano senza scala o spostamento del target.
Feedback audio: assestamento grave, compressione breve della cera e colpo di bronzo.
Feedback testuale: MOSTRA IL PATTO con traduzioni SHOW THE PACT e MUESTRA EL PACTO.
Registrazione prodotta: avanzamento pact tramite request_ritual_advance invariato.
Owner dati/flow: RunManager.
Segnale GameEvents: request_ritual_advance("pact"), invariato.
Fallback accessibile: focus netto, stato validated e lock leggibili senza motion.
Schermata o scenario QA: FIRST_REACTION e matrice 04_pact_*.
```

Asset previsto:

- sorgente RGBA senza testo, rapporto `5:2`, dimensioni `1280x512` e alpha
  validato; il soggetto occupa 88-96% della larghezza e 82-92% dell'altezza;
- destinazione `assets/ui/official/objects/pact_tablet/`;
- texture `registry_pact_tablet_sealed.png`;
- risorse `sb_registry_pact_tablet_normal.tres`,
  `sb_registry_pact_tablet_focus.tres`,
  `sb_registry_pact_tablet_pressed.tres`,
  `sb_registry_pact_tablet_validated.tres` e
  `sb_registry_pact_tablet_disabled.tres`;
- provenienza visuale: generazione originale built-in su chroma-key con
  Registro aperto, cartiglio firmato e soglia come riferimenti, rimozione
  locale e validazione alpha; nessuna fonte third-party;
- cue originale procedurale
  `res://assets/audio/sfx/registry_pact_validate.wav`;
- consumer `Btn_FIRST_REACTION_NEXT` dentro `res://scenes/UI.tscn`;
- controllo `320x128` dentro pannello `660x390`; gli StyleBoxTexture usano
  margini texture a zero per conservare il rapporto 5:2 senza nine-slice;
- titolo, due righe di corpo, CTA, `SEGNI` e stato del Registro sono tradotti
  integralmente in IT/EN/ES;
- nessuna modifica a flow, payload, save o transizione;
- validated precede lock, cue ed emissione dell'intento e non attende motion;
- apertura, nuovo payload, chiusura, cambio fase, recovery e watchdog
  ripristinano stato e lock;
- reduced motion riceve la stessa informazione tramite stato, contrasto, copy
  e cue.

Accettazione OF-07:

- normal, focus, validated e disabled riconoscibili senza variazione di
  geometria;
- CTA leggibile in IT/EN/ES a 1280x720 e 1920x1080;
- mouse, tastiera e focus emettono lo stesso intento una sola volta;
- WAV mono PCM16 44,1 kHz, 0,55-0,80 s e picco massimo -3 dBFS;
- 24 screenshot viewport-only nella matrice `04_pact_*`;
- contratto OF-07, i18n, path e import Godot verdi.

## Tessere del gesto davanti alla gradinata

Uso: scelta `placa`/`provoca` nella fase `INTERMEDIATE_CHOICE`.

- Due tessere gemelle rendono fisica la scelta pubblica senza cambiare esito,
  pressione o flow.
- Stati: normal, focus, pressed, selected e disabled.
- La silhouette resta identica; cambia soltanto la sabbia nell'incavo.

### Scheda OF-08

```text
Intento del soggetto: scegliere come esporsi davanti alla gradinata.
Oggetto: coppia di tessere gemelle con incavo di sabbia.
Materiale: basalto, bronzo e sabbia d'arena.
Gesto: deporre la tessera composta oppure incidere quella di sfida.
Conseguenza leggibile prima del gesto: Pressione -1 oppure Pressione +1.
Stato prima: tessere disponibili, in focus, premute o bloccate.
Stato dopo: selected persiste fino al cambio di fase o al recovery.
Feedback visivo: sabbia composta per placa; sabbia calda e incisa per provoca.
Feedback audio: assestamento e folla che cala; graffio, colpo e reazione breve.
Feedback testuale: ABBASSA LO SGUARDO / SFIDA LA GRADINATA con copy IT/EN/ES.
Registrazione prodotta: scelta 0/1 tramite request_mid_choice_select invariato.
Owner dati/flow: RunManager.
Segnale GameEvents: request_mid_choice_select(0/1), invariato.
Fallback accessibile: forma, copy, contrasto e stato selected; nessuna scala.
Schermata o scenario QA: INTERMEDIATE_CHOICE e matrice 05_gesture_*.
```

Asset previsto:

- `arena_gesture_tile_placa.png` e `arena_gesture_tile_provoca.png`, RGBA
  `768x512`, rapporto 3:2, senza testo e con silhouette coincidenti;
- destinazione `assets/ui/official/objects/arena_gesture/`;
- cinque StyleBoxTexture per tessera, geometria identica e margini texture a
  zero;
- consumer `Btn_MID_CHOICE_SELECT_0/1` in controlli fissi `336x224`, dentro
  pannello `764x430`, separazione `14 px`;
- cue originali procedurali `arena_gesture_placa.wav` e
  `arena_gesture_provoca.wav`;
- provenienza visuale: generazione built-in su chroma-key con tavoletta,
  soglia e Registro come riferimenti, rimozione locale e validazione alpha;
- selected precede lock, cue ed emissione; emissione fallita e watchdog
  ripristinano entrambe le tessere;
- nessuna modifica a flow, payload, save, segnale o transizione.

Accettazione OF-08:

- normal, focus, selected e disabled distinguibili senza scala o spostamento;
- CTA, pressione, registrazione e otto messaggi payload leggibili in IT/EN/ES;
- WAV mono PCM16 44,1 kHz, 0,55-0,85 s e picco massimo -3 dBFS;
- 36 screenshot viewport-only nella matrice `05_gesture_*`;
- contratto OF-08, i18n, motion, ritual loop, path e import Godot verdi.

### Scheda OF-09

Intento del soggetto: chiudere il giudizio del patto.
Oggetto: sigillo su pietra.
Materiale: basalto, bronzo consumato e cera rossa.
Gesto: tre colpi sullo stesso sigillo.
Stato prima: intact/normal, con focus dorato e pressed caldo.
Stato dopo: strike_1, strike_2 e resolved persistente prima dell'avanzamento.
Feedback visivo: crepe e chiusura del sigillo senza cambio di geometria.
Feedback audio: `registry_judgment_seal_strike` per i primi due colpi e
`registry_judgment_seal_resolve` per il terzo.
Registrazione prodotta: avanzamento resolve tramite
`request_ritual_advance("resolve")`, invariato.
Owner dati/flow: `RunManager`.
Segnale GameEvents: `request_ritual_advance("resolve")`, invariato.
Schermata o scenario QA: `Phase_RESOLUTION` e matrice `06_judgment_*`.

Accettazione OF-09:

- sigillo RGBA 5:2, senza testo, con silhouette stabile;
- stati normal, focus, pressed, strike_1, strike_2, resolved e disabled;
- CTA, corpo e prompt leggibili in IT/EN/ES a 1280x720;
- WAV mono PCM16 44,1 kHz con picco massimo -3 dBFS;
- 30 screenshot viewport-only nella matrice `06_judgment_*`;
- contratto OF-09, i18n, motion, ritual loop, path, import Godot e checkpoint
  CI verdi prima della chiusura formale.

## Verifica

Ogni famiglia richiede:

- brief compilato;
- path e licenza;
- import Godot;
- scene consumer;
- screenshot viewport-only;
- test focus, disabled e reduced motion.
