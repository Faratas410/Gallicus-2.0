# Gallicus Layout Rules

## Baseline

Giudizio Manifesto, 9 ottobre: pannello trasparente `820x400`, offset
(-530, -180) dal centro. Inset 24 px; sinistra larga 356 px, titolo 26 px
e verbale 17 px nel supporto `356x264`. Destra: prompt 15 px con wrapping
nel supporto `360x84`, sigillo nativo `360x144` a y=108 e ausiliario
`300x60` a y=280. I testi non riallocano il target; hover/focus
dell'ausiliario non lo scalano. I tre incavi restano figli del sigillo.
Prove e limiti: `docs/support/manifesto_judgment_2026-10-09.md`.

Patto e Gradinata Manifesto, 9 ottobre: tavoletta avorio `660x390`,
titolo 38 px, corpo 17 px e gesto inchiostro `320x88` con testo 22 px.
Griglia trasparente `764x444`: voci in alto, spazio elastico per l'arena,
intenzione su fascia inchiostro, risposte in basso con minimo `350x180`
e separazione 16 px. Titolo della risposta 22 px e prezzo/corpo 17 px,
stesse coordinate per entrambi gli atti. Misura su carta, esposizione su cera;
selected vuoto e validated pieno restano distinti. Dettagli e prove:
`docs/support/manifesto_pact_crowd_2026-10-09.md`.

Registro Manifesto, 9 ottobre: documento `900x540`, due pagine affiancate
con medesima gerarchia titolo/condizioni/costo e firme stabili di circa
`333x51`. Corpo 17 px, titolo 22 px, intestazioni 15 px; nessuna tinta del
testo per selezionare. Il testo lungo scorre nel suo RichTextLabel, torna
all'inizio con una nuova offerta e mantiene la firma fuori dallo scroll.
I comandi del banco conservano tre righe semantiche e wrapping, corpo 15 px,
minimo `182x110` e padding verticale 8 px; il servizio piu' lungo porta la
riga a 148 px nel campione IT. Il banco ha spazio anche per la causa del
blocco e resta nel Registro chiuso. Nessun target scala in hover/focus.
Prove e perimetro: `docs/support/manifesto_registry_2026-10-09.md`.

Kit condiviso, 9 ottobre 2026: azioni della posta e route del fascicolo
consumano `scripts/ui/manifesto_kit.gd`. La variante estesa mantiene titolo,
conseguenza e marchio; quella compatta conserva i target del fascicolo
`280x64`, con font Manifesto 22 px e wrapping. Titoli 40/26 px,
conseguenze 17 px, caption 38 px e passo spaziature 8 px sono centralizzati.
I Button originali conservano focus, disponibilita', segnali e testo
semantico; superfici e label aggiunte ignorano input. Stati senza scala o
movimento. Catalogo e ricette in `docs/support/ui_kit_2026-10-09.md`.

Pass dell'8 ottobre 2026: Registro chiuso con Orvo accanto al bando e Vessa
accanto al banco; i ritratti ignorano mouse e focus. Servizio, effetto e
prezzo del banco occupano righe distinte, font 15 px e pulsanti con wrapping
e minimo 182x94. Le note di favore e bando sono almeno 15 px. Nell'Archivio
ogni presenza ha ritratto 112x168 e biografia localizzata da 18 px, separati
da 24 px. Le voci restano nello scroll esistente. La composizione della
biografia e' tradotta prima del rendering e non ritradotta dal Label.

La UI deve essere funzionale almeno a:

- 1280x720;
- 1920x1080.

Il layout deve tollerare italiano, inglese e spagnolo senza font scalato con la
larghezza viewport.

## Struttura

- L'oggetto attivo occupa il centro funzionale.
- Titolo, conseguenza e gesto appartengono alla stessa superficie.
- Pannelli di pagina non devono sembrare card flottanti.
- Vietate card dentro card.
- Dimensioni e aspect ratio degli oggetti critici sono stabili.
- Hover, focus, label e stato non devono ridimensionare il layout.
- Il Patto e le risposte adottano le dimensioni Manifesto descritte sopra.
  Il sigillo OF-09 conserva controllo `360x144` (5:2) nel pannello `640x420`.
  Gli stati di ogni oggetto conservano la propria geometria.

## Gerarchia

Ogni schermata gameplay mostra:

1. cosa e' davanti al soggetto;
2. quale stato porta;
3. quale gesto e' disponibile;
4. quale conseguenza produce;
5. cosa ha registrato il sistema dopo l'atto.

Il testo secondario non deve competere con il gesto principale.

## Schermate

- **Menu:** Gallicus e soglia dell'arena nel primo viewport.
- **Registro:** due offerte confrontabili senza wrapping distruttivo.
- **Firma:** promessa, costo e sigillo sulla stessa tavola.
- **Patto:** vincolo leggibile e corpo non vuoto.
- **Gesto pubblico:** opzioni confrontabili e reazione della folla.
- **Rito:** oggetto centrale, conteggio colpi e responso.
- **Push-your-luck:** quietanza, marchio e incisione chiaramente distinte.
- **END_RUN:** fascicolo, esito, memoria e route disponibili.

Il fascicolo END_RUN usa un controllo fisso `1120x640`. La safe area interna
usa 70 px ai lati, 48 px sopra e 42 px sotto, con testo allineato a sinistra,
una riga di posta (Gloria, segni, pressione massima), tre
colonne compatte per patti firmati, nuove voci d'Archivio e ultima voce, e una
riga centrata `864x64`. Le linguette restano `280x64` anche quando
`PROSSIMA SCOMMESSA` non e' disponibile; non si espandono e non cambiano scala
tra focus, selected e disabled. La prosecuzione disponibile riceve il focus;
ritorno al menu e riavvio con prosecuzione disponibile sono subordinati.
- **Archivio:** consultazione, non griglia di achievement generica.
- **Assenza:** nessun residuo del normale HUD.

## Utility

Settings, lingua, volume, risoluzione, back e quit usano controlli familiari:

- slider per valori continui;
- checkbox/toggle per stati binari;
- option menu per insiemi;
- icone note con tooltip;
- focus order prevedibile.

Non forzare metafore diegetiche sulle utility.

## Testo

- Nessuna parola importante si spezza in modo illeggibile.
- Bottoni e oggetti interattivi supportano la stringa piu' lunga prevista.
- Font decorativo solo su titoli brevi.
- Corpo e conseguenze usano font ad alta leggibilita'.
- Non usare letter spacing negativo.
- Informazioni critiche non dipendono dal solo colore o da un'icona.

## Stati

- normal, hover/focus, pressed, disabled e registered devono essere distinti;
- disabled mostra causa quando rilevante;
- un elemento cliccabile non deve sembrare spento;
- focus da tastiera deve essere visibile quanto hover da mouse;
- route finali non possono essere ambigue.

## Motion

- Pulse, flash e transizioni confermano causa/effetto.
- I target cliccabili non si spostano.
- Il testo non viene coperto.
- Reduced motion sostituisce movimento con cambio di stato breve.
- Nessun effetto indispensabile dura solo un frame.

## QA

Una patch visibile richiede:

- screenshot viewport-only alle due risoluzioni;
- almeno una cattura nella lingua con stringa piu' lunga;
- controllo focus tastiera;
- controllo reduced motion se tocca animazioni;
- static test UI pertinenti.

## Geometrie della bonifica

La decisione sulla posta e' successivamente sostituita dalla composizione
Manifesto del Verdetto: fascia rossa a sinistra (188 px), colonna nera a destra
(306 px), azioni a 244 px dal fondo con altezza 158 px. Il contenitore di fase
copre il viewport ma ignora input; soltanto le aree dei comandi ricevono click.
Numero nativo adattato alla larghezza per poste a piu' cifre. Le note restano
entro l'area dipinta e ignorano input, lasciando attivo il pulsante sottostante.
Le righe sotto descrivono le geometrie precedenti delle altre fasi; dettagli
e matrice aggiornata in `docs/support/manifesto_verdict_2026-10-08.md`.

Rifinitura materiale successiva: geometrie esterne invariate, note della
posta allineate in alto a y=64 nella superficie del comando, almeno 8 px
liberi sotto l'ultima riga. Focus, hover e pressed non cambiano dimensioni.
Tre tagli pieni identificano la conferma; due barre nel margine sinistro
identificano il blocco insieme alla causa scritta. Dettagli e prove:
`docs/support/manifesto_material_2026-10-08.md`.

- Menu: marchio largo 740 px, frase senza cornice, soglia da 480x72 px,
  ripresa disponibile solo con save valido e utility in una riga da 480 px.
  Gli avvisi di salvataggio hanno una riga dedicata e wrapping. La colonna
  resta ferma; solo luce del marchio e fondale hanno moto ambientale.
- Registro: tavola 900x540 nel campo sinistro, due blocchi e firma per pagina.
  Anchor centrale, offset (-600, -255); a 720p parte da (40, 105).
- Push Your Luck: 900x414, offset (-600, -145) dal centro; posta 44 px,
  azioni 24 px, note 17 px. Oggetti alti 104 px. La colonna del marchio non
  lascia vuoti quando nascosta. Nessuna cornice nei pannelli testuali.
- Bando, Gradinata e Segni: colonna destra larga 270 px, offset x=338 dal
  centro; offset y=-134, 24, 162 e altezze 156, 136, 108. Nota della Gradinata
  su una riga con ellissi e tooltip completo. Segni: numero e nomi nello
  scroll; effetti e racconto nel dettaglio. Nessuna altezza dinamica.
- Patto e giudizio usano le dimensioni Manifesto correnti descritte sopra.
  Il giudizio conserva il proprio oggetto di cera e gli incavi.
  Il patto conserva il banco; il giudizio usa
  il campione di arena illustrata, condiviso da gesto e incasso/raddoppio.
  Un gradiente nativo comune protegge la lettura senza cambiare geometrie,
  target o focus. Il gradiente ignora input e resta sotto tutti i controlli.
- Pressione: rail 1216x60, offset (-608, 284) dal centro; a 720p resta a
  16 px dal bordo inferiore. A 1080p il gruppo resta centrato; font e target
  non scalano. Tutti i figli devono rientrare nel viewport.
- Fascicolo: geometria 1120x640 invariata, carta e inchiostro; route primaria
  scura, utility subordinate con linea semplice.
- Assenza: nero full viewport sopra HUD, menu e luminosita', senza CTA.

La matrice Opzioni cambia lingua attraverso il selettore reale e ripristina
lingua, risoluzione e reduced motion al termine.

## Presentazione leggera del 6 settembre 2026

Il pass audiovisivo mantiene fermi hit area e focus. La polvere VFX compare
sul bordo dell'oggetto, senza overlay opaco o testo coperto; due sprite al
massimo, invisibili dopo 0,41 s. Il titolo di lettura del Registro e' fermo,
le entrate rituali sono ridotte a 4 px. Movimento ridotto cancella subito i
VFX attivi. Limiti e accettazione in `docs/art_direction.md` e `docs/testing.md`.

## Chiusura della coerenza UI - 8 settembre 2026

Archivio e Crediti usano la stessa superficie utility senza cornici interne
ridondanti; titoli 24 px, corpo 18 px. Crediti: colonna 640 px e corpo con
altezza minima 220 px; ritorni utility 280x52 centrati. Tab Archivio sempre
navigabili, selezione come stato premuto, mai disabled. Le voci non ancora
registrate restano leggibili (alpha 0,78). Il Museo non espone livelli interni.
Popup, radio, slider e scrollbar ereditano bronzo e focus dal tema ufficiale.
Le forme geometriche dei controlli sono risorse native, senza nuovi raster.

Cicatrici: dettaglio 440x360, testo scrollabile, CHIUDI sempre accessibile;
overlay sopra la fase attiva, blocker separato, Escape e focus confinato al
dettaglio. La chiusura conserva il rito sottostante. Notifica non modale con
superficie basaltica, lettura 3,5 s e scadenza anche con movimento ridotto.
Il fascicolo aggiornato/chiuso usa una sola traccia RGBA di cera, separata
dalla carta e priva di fondo nero; il documento aperto non la mostra. Silenzio: ritorno 320x52 centrato in basso, offset
relativi agli anchor; Assenza conserva superficie senza CTA.

## Finestra di conversazione - 12 settembre 2026

Stage 1160x620 centrato, ritratto 400x600 a sinistra, testo a destra su pannello
scuro 768x430. Corpo 24 px, nome 34 px, ruolo 18 px; font identici a 720p e
1080p. Due azioni accessibili: avanzamento e skip. Nessuna scelta di risposta.
La finestra copre il rito e ne intercetta tutti gli input finche' viene chiusa.

Dettaglio e prove: `docs/support/illustrated_dialogues_2026-09-12.md`.

I cinque ritratti aviani sono sagome trasparenti sulle superfici esistenti.
Nei dialoghi il ritratto parte da x=20 e copre 28 px del bordo sinistro del
pannello, davanti alla pietra e prima del testo che parte da x=432. La base
del busto sfuma nell'ultimo 10 percento; nessun pannello proprio del ritratto.
Archivio e Registro conservano dimensioni e target del pass precedente.
Le figure ignorano input; la finitura e' statica anche con movimento ridotto.
