# Gallicus Layout Rules

Il caso del posto usa un foglio centrato e comandi nativi su ricevute: testo,
conto, scelte e rinvio devono restare leggibili alle risoluzioni supportate e
nelle tre lingue. Il focus non deve uscire dalle scelte visibili.
Il dialogo di campagna conserva le proporzioni del layout 1280x720 anche a
risoluzioni maggiori; la scala non aggiunge animazioni o nuove decisioni.

## Incasso/Rilancio dopo la revisione utente

Quietanza massima 360 x 180 px a 720p; testo con 24 px di margine laterale.
Rilancio su cartiglio distinto dal sigillo, con tutti gli effetti leggibili.
Importo a 42 px adattabile, Vessa e banco in un unico sprite poggiato sul
parapetto. Il timbro registrato ha spazio sotto le conseguenze. Dettagli:
`docs/support/verdict_review_2026-10-26.md`. Questa geometria supera il pass
precedente della posta; focus e click conservano i target fissi.

## Margini Banco dopo la revisione utente

Servizi centrati nella parte chiara: margini orizzontali 10 percento e
verticali 17 percento. Carta senza simboli estesa al centro tramite nine-slice;
nessuna deformazione dei marchi. Il titolo Banco ha un cartiglio dedicato e
centratura verticale, con altezza e font adattati alla viewport. Dorso e
lettering: `docs/support/banco_review_2026-10-26.md`.

## Banco e Incasso/Rilancio - 26 ottobre 2026

Il Banco chiuso conserva il libro a destra: apertura sulla copertina, bando
e tre ricevute a sinistra. Prezzo insieme al titolo, effetti completi, corpo
16 px alla base 720p; assicurazione su carta piu alta. Nessuno scroll.
La posta usa l'inset HUD di 128 px e testi nativi su carta/cera/ferro; Vessa
resta separata dai target. Focus e blocchi non spostano oggetti o scrittura.
Evidenze e geometrie correnti: `docs/support/pixel_banco_verdict_2026-10-26.md`.

## Tre rituali pixel art - 26 ottobre 2026

Patto, Gradinata e Rito usano la base 1280x592 sotto l'inset HUD di 128 px;
scala uniforme, preservata anche dal ripristino di motion e dai resize.
Il Patto ha una tavoletta centrale; la Gradinata due tessere con conseguenze
complete; il Rito separa sigillo e verbale, con comando ausiliario fuori dal
corpo scritto. Focus e lock non muovono i target. Corpo 18-20 px, comandi
23-24 px e insegne 23-26 px nella base 720p. Specifiche ed evidenze in
`docs/support/pixel_rituals_2026-10-26.md`; sostituisce le geometrie storiche
di queste tre viste riportate sotto.

## Registro volumetrico - 26 ottobre 2026

Sostituisce la geometria Registro del 9 ottobre: il libro occupa la scena
sotto la fascia comune, con inset di 128 px a 720p e scala coerente della
fascia a 1080p. Pagine e target nativi restano fermi; ruota solo la pelle
passiva del libro. Contratti compatti in RichTextLabel a inchiostro, senza
scorrimento o scrollbar: tutti i termini devono entrare nella pagina.
La lettura e' passiva; il focus resta sulle firme. Frecce destra/sinistra collegano
le due firme. Il focus usa una regola inchiostro, il blocco due barre.
Le offerte nuove azzerano l'animazione; Movimento ridotto apre
subito il libro. Il banco resta accessibile accanto alla copertina chiusa.
Dettagli: `docs/support/registry_volume_2026-10-26.md`.

Scrittura sulle pagine: Fondamento Regular 18/20/28 px per corpo, rubriche
e titoli; nota sulle condizioni in Italic 18 px, firma 24 px. Le rubriche non aggiungono
una riga vuota: le lettere calligrafiche hanno gia' un'interlinea generosa.
Il testo usa l'85% superiore della pagina, con separazione dalla firma.
Premessa atmosferica e preambolo della condanna non sono ripetuti; restano
probabilita', guadagno, perdita, effetto completo e condizioni correnti.
Niente riduzione automatica del font, clipping o ellissi. Il font e'
condiviso con l'eco della firma. Il fixture misura tutte le offerte attive.

## Fascia persistente comune - 24 ottobre 2026

Il trattamento GDR approvato il 26 ottobre sostituisce la fascia piatta qui
descritta: `ritual_status_header.gd` rende le insegne in posizioni fisse,
con la prima riga dei valori e il Bando/nota del Favore nella seconda.
Il Registro e l'eco della firma condividono `CONTENT_TOP = 128`; stemma e
tessera pendono oltre la fascia ai lati, fuori dai titoli centrali. La posta
riserva lo spazio sotto la fascia a titolo, importo e voce, e sopprime il
vecchio titolo ambientale che si sovrapponeva. Testo 15-19 px, numeri 30-34 px;
solo importi lunghi si adattano fino a 18 px, conservando il segno negativo.
Le dimensioni dei Label vengono ristabilite dopo gli aggiornamenti del font
al resize, senza conservare gli ingombri della risoluzione precedente.
La nota lunga del Favore ha copy compatto localizzato e tooltip completo.
Segni e' un Button nativo con regola di focus/hover, disabilitato a Registro
pulito; chiudere il dettaglio restituisce il focus alla tessera. Riferimento:
`docs/support/hud_insegne_2026-10-26.md`.

La precedente geometria del 24 ottobre manteneva Arena, Pressione a dieci tacche,
Catena, Favore, Denari e Segni nella prima riga (82 px complessivi a 720p),
Bando e spiegazione della fascia di Favore nella seconda. La geometria resta uguale nelle fasi attive; colonna
laterale e rail rimangono consumer dati interni, senza un secondo rendering.
Il fascicolo conserva il suo resoconto completo. Menu, dialoghi, Silenzio e
Assenza non ricevono la fascia sopra i loro overlay. Il dettaglio Segni
restituisce focus al comando di consultazione.

La posta mantiene oggetti bassi e numero dominante, senza duplicare l'HUD.
Con la fascia GDR Vessa usa un riquadro 140x154, con proporzioni preservate.
La notifica Segno ha uno spazio riservato fra voce
e oggetti (x520, y310, larghezza680, altezza100 nella composizione 1280x720),
con ripristino della geometria precedente all'uscita. Focus e barre di blocco
seguono il target fermo, anche quando la pelle passiva dell'oggetto si solleva.

Titoli 28/26 px, azioni compatte 22 px, corpo 17 px, servizio almeno 15 px:
serif regolare comune e sans di lettura. Il kit gestisce il wrapping del testo
semantico nativo senza cambiare il rettangolo interattivo. Le descrizioni
storiche della posta e dei contatori sotto sono sostituite da questo pass.
Prove: `docs/support/art_unification_2026-10-24.md`.

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

Eccezione Incasso/Rilancio, 22 ottobre 2026: la scena adotta una composizione
logica 1280x720 scalata uniformemente a 1920x1080. Gloria e dieci tacche di
Pressione sono nella scena; Arena, Bando, Favore, Denari e accesso ai Segni
occupano il bordo superiore. I precedenti HUD laterali sono nascosti soltanto
durante questa fase e ripristinati all'uscita. Quietanza e sigillo sono
oggetti pittorici separati; compare il Marchio quando l'incasso e' bloccato.
I target nativi restano fermi: si muove solo la pelle passiva dell'oggetto.
Note, cause dei blocchi e titoli hanno spazio riservato anche in EN/ES.
Questa eccezione sostituisce la precedente ricetta a colonne della posta,
senza propagare il layout alle altre fasi. Prove:
`docs/support/living_verdict_2026-10-22.md`.

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

## Atto a stampa - 10 ottobre 2026

- Un solo primario per schermata (ripresa nel menu, avanzamento nel
  prologo); utilita' e ritorni sono secondari compatti con target invariato.
- Hover/focus: nessuna scala o spostamento; la linea dello stilo non cambia
  la geometria. Premuto: tinta e contorno interno, margini costanti.
- Schede di lettura con margine 16 px; voci bloccate distinte per forma
  (inchiostro, ruolo muted) oltre che per colore.
- Scrollbar del kit larghe almeno 10 px.
