# Gallicus Art Direction

## Identita' scelta: Manifesto del Verdetto

Pacchetto 3, 9 ottobre: sigillo nativo in basalto, bronzo e cera con CTA
Manifesto 22 px; nessuna sostituzione con le incisioni del marchio. Verbale
e titolo su supporti inchiostro nella colonna sinistra, gesto e ausiliario
compatti nella destra. Geometria fissa fra testo iniziale, colpi e Segno.
Confronto e limiti: `docs/support/manifesto_judgment_2026-10-09.md`.

Pacchetto 2, 9 ottobre: Patto come tavoletta avorio con gesto in inchiostro;
Gradinata con spazio centrale per l'arena, intenzione separata e risposte
raccolte in basso. Carta per la misura, cera per l'esposizione, prezzi
allineati sotto il verbo. Selected non riempie l'impronta; validated del
Patto la riempie. Confronto e limiti:
`docs/support/manifesto_pact_crowd_2026-10-09.md`.

Implementazione condivisa dal 9 ottobre 2026: `scripts/ui/manifesto_kit.gd`
centralizza tipografia, spazi e adattatori dei comandi; pigmenti in
`scripts/ui/manifesto_palette.gd`, incisioni in
`scripts/ui/manifesto_primitives.gd`. Posta e route del fascicolo usano
`scripts/ui/manifesto_action_surface.gd`, con varianti carta, inchiostro e
cera. Non generare una nuova immagine del medesimo componente per ogni fase.
Estendere la libreria e il campionario prima di introdurre altri override
locali equivalenti. Composizioni e oggetti specifici restano di fase.
Copertura attuale e uso: `docs/support/ui_kit_2026-10-09.md`.

Pacchetto Registro del 9 ottobre: due documenti avorio dentro il supporto
inchiostro; titoli e intestazioni Manifesto, condizioni in corpo pulito.
Il banco mantiene Orvo e Vessa e usa carta per servizio/effetto/prezzo.
Cera concentrata nelle firme. La selezione aggiunge una regola laterale e
un'impronta vuota; solo signed riempie i tagli. Nessuna tinta sull'intero
testo, fascia della posta o numero gigante. Superfici native condivise in
`scripts/ui/manifesto_document_surface.gd`; confronto ispezionato e limiti
in `docs/support/manifesto_registry_2026-10-09.md`. Le descrizioni storiche
delle pagine scure sotto non definiscono il nuovo consumer del Registro.

Decisione dell'utente, 8 ottobre 2026: la terza proposta, nella rifinitura con
azioni raccolte in basso, fissa l'identita' UI. Grafica incisa, netta e rituale:
sfondi pittorici lasciano spazio al mondo, interfaccia a stampa da' peso alle
scelte, impronte ne conservano le conseguenze. Supera la sobria UI del banco
come riferimento di carattere, mantenendo la direzione spaziale gia' definita.

- Il carattere nasce da forme, proporzioni, posta dominante e lettere alte e
  strette. La ruvidita' si concentra ai margini; niente rumore dietro agli effetti.
- Nero: informazioni del Registro. Avorio: condizioni e risultati. Rosso:
  esposizione e impegno. Posta e seconda incisione condividono il rosso finche'
  il rischio resta aperto. Il colore non sostituisce testo, focus o disponibilita'.
- Titoli e verbi incisivi, grazie nette; descrizioni in un carattere pulito.
- Contrassegno del Registro predisposto, impresso dopo la conferma, conservato
  nel resoconto. I tre tagli sono un'identita' grafica fissa e non contano i
  Segni, che conservano numero e nomi espliciti, incluso Occhio perduto.
- Pressione 0: composizione ferma. A rischio crescente sono ammessi pochi
  accenti statici ai bordi, senza spostare comandi o sporcare testo e numeri.

La fascia laterale rossa con la posta appartiene alla decisione quietanza/
raddoppio. Non diventa un arredo obbligatorio di ogni fase. Registro: patto e
firma; arena: gesto e posta; Gradinata: pubblico e risposte ai margini; esito:
risultato impresso e continuazione distinta. Palette, tipografia e impronte
sono comuni, composizione e ambiente possono cambiare.

Prima applicazione e verifica: `docs/support/manifesto_verdict_2026-10-08.md`.
L'identita' e' scelta; l'estensione materiale a tutto il gioco resta lavoro
da completare e verificare in sequenza.

Conferma successiva dell'utente, 8 ottobre 2026: tenere Manifesto del
Verdetto come base e adattarlo al mood di Gallicus con rosso di cera piu'
spento, avorio sporco, nero d'inchiostro e incisioni asciutte. Le grandi
scritte hanno il peso di un atto del Registro: severo, pubblico, destinato
a restare. Conservare numero dominante, scelte nette e spazio per
l'ambiente. Tipografia, materiali e impronte sono comuni; ogni fase ha
la propria composizione. Valori colore e risultato integrato restano da
verificare nel gioco. Handoff operativo per Astra:
`docs/support/astra_manifesto_handoff_2026-10-08.md`.

## Tesi visuale

Primo adattamento materiale circoscritto alla posta:
`docs/support/manifesto_material_2026-10-08.md`. Pigmenti nativi condivisi
con l'impronta del fascicolo: inchiostro `191917`, avorio `e7ddc5`, cera
`792d26`. Bordi con poche incisioni statiche; centro delle azioni calmo.
Il raccordo delle altre fasi rimane aperto. Verifica visuale corrente
limitata all'italiano su richiesta dell'utente.

Gallicus e' un teatro amministrativo romano reso fisico: un'arena severa in
cui pietra, cera, bronzo e fascicoli registrano il comportamento del soggetto.
L'immagine non deve sembrare fantasy generico, horror demoniaco o interfaccia
moderna travestita.

Revisione del banco, 8 ottobre 2026: la composizione gameplay usa
`assets/ui/generated/registry_counter.png`, piano continuo di pietra opaca
con arena sullo sfondo. Le superfici condivise sono sobrie e native; bronzo
e cera restano sugli oggetti con una funzione rituale. Questo pass sostituisce
il precedente rivestimento generalizzato in `basalt_worked.png`.
La carta `registry_paper.png` distingue quietanza e fascicolo; la traccia
`registry_wax_trace.png` compare sugli stati registrati.
Prove: `docs/support/counter_ui_2026-10-08.md`.

Correzione di regia successiva richiesta dall'utente: identita' UI comune,
ma banco limitato al Registro, rischio sulla sabbia, Gradinata come cambio
di sguardo nello stesso luogo e resoconto nel portico dopo l'uscita.
La scelta quietanza/raddoppio rimane nell'arena. Quattro vedute provvisorie,
geografia e anteprima in `docs/support/spatial_sequence_2026-10-08.md`.
Le quattro immagini sono reference di geografia: il loro realismo e la loro
grana non sono il trattamento approvato per il runtime. Un primo campione
illustrato e' ora integrato sotto giudizio, gesto e scelta incasso/raddoppio:
`assets/ui/generated/arena_illustrated_sample.png`. Registro, patto e
fascicolo conservano per ora il banco precedente. Prova e differenze ancora
aperte: `docs/support/illustrated_arena_2026-10-08.md`.

## Mano comune tra ambienti

Il campione definisce una proposta da confrontare in gioco, non un'approvazione
artistica dell'intero set. Luoghi diversi condividono queste regole:

- Forme dipinte leggibili, silhouette selettive, due o tre piani di valore per
  materiale. Niente micrograna fotografica, riflessi PBR o effetti da obiettivo.
- Calcare e osso per la luce, terra e oliva scuro per le ombre, rosso spento
  per stoffa e cera. Bronzo circoscritto alla funzione degli oggetti.
- Una direzione di luce ampia; il cambio di ambiente cambia l'esposizione e
  l'inquadratura, non la tecnica pittorica o il contrasto dei comandi.
- Dettaglio concentrato sulle forme identificative. Piume, pietra e carta
  devono condividere la stessa semplificazione; evitare un ritratto fotografico
  sopra un fondale illustrato o una quietanza piena di fibre ad alto contrasto.
- Testi e numeri restano nativi. La superficie di lettura viene verificata
  a 720p con UI reale; la bellezza dell'immagine isolata non basta.
- Gerarchia, font, focus, stati e significato dei materiali restano comuni
  tra menu, Registro, arena, Archivio e fascicolo. Gli sfondi non contengono
  falsi pulsanti, testi o duplicati degli oggetti rituali interattivi.
- La Gradinata e' un diverso sguardo sulla stessa arena. Registro e portico
  riprendono arco e vessillo mantenendo scala e geografia riconoscibili.

Per estendere il trattamento, confrontare una sequenza con Registro, arena,
Gradinata, portico, cast e Archivio, includendo condizioni chiare/scure e
IT/EN/ES. Non considerare conclusa la coerenza dal solo campione dell'arena.

Vessa e Orvo hanno ritratti originali nella stessa luce e palette di Nerio,
rispettivamente con vassoio contabile e annuncio arrotolato. Completano il
cast visivo esistente, senza nuove specie, voci, personaggi o regole.
Prove e limiti: `docs/support/claude_review_2026-10-08.md`.

La scena primaria e' l'oggetto rituale. Cornici e decorazioni esistono solo per
stabilire gerarchia, stato o conseguenza.

## Palette

- Base: basalto, pietra grigia, nero caldo, cenere.
- Superfici leggibili: osso spento, calcare, carta sporca.
- Autorita': bronzo ossidato e oro pallido.
- Firma e costo: cera rossa, sangue scuro, ferro.
- Anomalia: verde ossidato o blu ferro, usati con parsimonia.
- Assenza: sottrazione progressiva, non un nuovo colore spettacolare.

Nessuna schermata deve essere dominata da un solo hue. Stato e gerarchia non
possono dipendere soltanto dal colore.

## Materiali

- Pietra intatta: procedura stabile.
- Pietra crepata: struttura sotto pressione.
- Cera liscia: promessa disponibile.
- Cera impressa: consenso registrato.
- Bronzo lucidato: valore riconosciuto.
- Bronzo ossidato: istituzione che persiste ma perde continuita'.
- Carta/fascicolo: memoria accumulata.
- Ferro/catena: vincolo avverso.
- Sabbia: esposizione al pubblico.
- Vuoto: ritiro dell'apparato.

Le texture devono rendere il materiale riconoscibile senza sporcare il testo.

## Oggetti principali

- soglia dell'arena;
- tavola del Registro;
- stilo e sigillo;
- tavoletta del patto;
- tessera o manciata di sabbia per il gesto pubblico;
- pietra del giudizio;
- quietanza;
- marchio o timbro di condanna;
- seconda incisione;
- fascicolo finale;
- armadio/Archivio.

Ogni oggetto ha stati coerenti: integro, disponibile, attivato, registrato,
consumato o assente.

Il fascicolo finale usa carta amministrativa leggibile, margini ampi e una
sola traccia di cera rossa; dorso e cerniere ornamentali sono rimossi. Open e updated conservano carta
chiara e inchiostro scuro; closed introduce una superficie scura e testo
chiaro senza alterare perimetro o safe area. Le linguette restano subordinate
al documento e non diventano card flottanti.

## Composizione

- L'oggetto attivo domina il centro funzionale della schermata.
- Arena e gradinata restano leggibili come luogo, non come wallpaper.
- Il testo vive su superfici fisiche con contrasto controllato.
- Evitare card flottanti annidate e pannelli decorativi senza ruolo.
- Lasciare respiro attorno al gesto principale.
- Il brand Gallicus deve essere evidente nel primo viewport del menu.

## Registro attraverso le Ere

Le Ere non vengono nominate o numerate in UI. Si percepiscono per deriva
materiale e compositiva.

### Era 0 - Intatto

- allineamenti stabili;
- pietra integra e bronzo leggibile;
- segni amministrativi completi;
- luce controllata.

### Era 1 - Rigido

- griglie piu' severe;
- spazi ridotti;
- incisioni piu' profonde;
- minore ambiguita' nel focus.

### Era 2 - Instabile

- asimmetrie localizzate;
- micro-fratture e ossidazione;
- rare interruzioni interpretative;
- nessuna distorsione che comprometta il testo.

### Era 3 - Terminale

- superfici rarefatte;
- commento visivo ridotto;
- oggetti piu' isolati;
- pressione percepita tramite sottrazione.

### Era 4 - Assenza

- nessuna nuova interfaccia del Registro;
- nessun simbolo celebrativo;
- spazio privo di funzione classificatoria;
- nero terminale conforme al canon.

Le transizioni usano una ramp di tre run: nessun cambio visuale istantaneo.

## Background e arena

- I background mostrano il luogo reale e sostengono l'azione.
- Le varianti cambiano luce, materiali, folla e stato del Registro.
- Il centro funzionale resta libero.
- Niente blur permanente dietro contenuto importante.
- Niente immagini atmosferiche generiche che nascondono l'arena.

## Personaggi e presenza

- Nella trama non esistono esseri umani. L'architettura e il lessico rituale
  non autorizzano figure o anatomie umane, neppure anonime o sullo sfondo.
- Il soggetto e' implicito attraverso segni, respiro e punto di vista.
- Felix resta precedente d'archivio e non appare come avatar.
- I Gufi sono apparato e presenza amministrativa, non mascotte o menu.
- La folla si manifesta con massa, suono, ombre e reazione, non con ritratti
  ripetuti che rubano il centro alla scelta.

## VFX e motion

- Firma: cera compressa, breve impulso, particelle minime.
- Colpo: impatto, crepa controllata, polvere e riverbero.
- Quietanza: presa, corda o segno contabile che si chiude.
- Marchio: calore breve, annerimento, impronta persistente.
- Rilancio: incisione aggiuntiva e riapertura della cera.
- Fascicolo: timbro, chiusura e ritiro.
- Silenzio: sottrazione di elementi, non glitch spettacolare.

Motion serve a confermare causa ed effetto. Non deve muovere target cliccabili,
coprire testo o impedire un equivalente reduced-motion.

## Tipografia e simboli

- Testo breve, con gerarchia netta e letter spacing neutro.
- Libre Baskerville per titoli brevi e posta; corpo nel sans incorporato di
  Godot. Font e licenza SIL OFL in `assets/ui/official/typography/`.
- Corpo leggibile anche in inglese e spagnolo.
- Icone come segni amministrativi, non illustrazioni decorative.
- Nessun simbolo privo di ruolo, lore o stato.

## Divieti

- gradienti neon o glossy;
- bokeh, orbs e decorazione astratta;
- parchment fantasy, spellbook e wood UI nelle superfici finali;
- gore esplicito usato come scorciatoia;
- demoni, teschi o armi senza funzione canonica;
- testo gameplay o localizzabile baked nelle immagini runtime; il marchio
  invariabile GALLICUS e' l'unica eccezione di identita';
- asset pack incompatibili mescolati nella stessa schermata;
- effetti RGB/glitch moderni come linguaggio principale.

## Accettazione

- leggibile a 1280x720 e 1920x1080;
- oggetto, gesto e stato identificabili senza copy lunga;
- informazioni non affidate al solo colore;
- asset runtime-ready e con licenza tracciata;
- screenshot viewport-only delle schermate modificate;
- nessun path o texture mancante.

## Famiglia originale adottata nella bonifica

La richiesta del 4 settembre 2026 adotta 15 raster ImageGen originali; manifest
in `assets/ui/generated/manifest.json`. Una camera del Registro collega menu
e rituali; basalto, bronzo, cera rossa e dossier di carta condividono materiali
e luce. Le pagine del Registro usano testo osso su basalto scuro; il fascicolo
aperto conserva inchiostro scuro su carta e linguette scure con testo chiaro.
Corpo 16-18 px, note almeno 15 px, font incorporato di Godot. I pannelli interni
sono vuoti: la superficie esterna basta a definire l'oggetto.

Il menu usa solo il fondale originale con drift lento; torce, bandiere,
nebbie e statue separate sono rimosse. La deriva ambientale e' graduale;
testo e focus mantengono contrasto costante. Messa in scena completa delle
Ere e montaggio finale restano gate audiovisivi, non certificati dalla
campagna accelerata.

## Identita del menu

Il titolo usa `assets/ui/generated/gallicus_wordmark.png`: iscrizione originale
ImageGen in pietra chiara e bronzo, RGBA trasparente, senza pannello di fondo.
Il marchio e' invariabile in IT/EN/ES e ha nome accessibile GALLICUS; le frasi,
i comandi e gli stati restano testo nativo. La famiglia comprende ora 16 PNG.
Il titolo domina la gerarchia; segue una sola riga: "L'arena dimentica. Il
Registro no." La schermata invita all'ingresso senza un riquadro Obiettivo.

## VFX materici del 6 settembre 2026

La texture originale `assets/ui/generated/ritual_dust.png` e' prodotta con
ImageGen: polvere chiara di calcare e minuscoli granelli di bronzo, alpha reale.
Il manifest registra il prompt integrale. Nessun alone magico, flash o fumo
persistente. Il source rimane intatto; Godot limita l'import a 256 px.

`scripts/ui/ritual_feedback.gd` presenta al massimo due sprite da 90-160 px,
per 0,41 s, al bordo inferiore dell'oggetto: scala 0,92-1,06, salita di 5 px,
alpha massima 0,42. Il movimento non sposta target, glyph o focus. Cambi fase,
fine run e attivazione di Movimento ridotto cancellano subito il feedback.
Gli effetti non intercettano input e non usano RNG di gameplay.

## Congedo del Registro - 12 settembre 2026

registry_departure e' il diciottesimo raster originale: derivazione ImageGen
della stessa registry_chamber, con arena vuota e senza figure umane o
oggetti amministrativi sul primo piano. PNG opaco copiato senza ritocchi;
provenienza e hash nel manifest degli asset. Il solo quadro aggiunto serve
il congedo terminale di sei secondi; non introduce un'altra famiglia visiva.
La presentazione usa un avvicinamento minimo e dissolvenza; Movimento ridotto
conserva il fermo immagine. Non e' un video. La prima variante con figure
umane era un errore interpretativo, corretto su indicazione dell'utente:
non e' parte della trama e non entra nella build corrente. Il quadro finale
mostra la cessazione della consultazione attraverso lo spazio vuoto.

## Ritratti e terminale rituale - 12 settembre 2026

Il pass richiesto introduce art originali pittoriche per Nerio, Rugo e Dima:
anatomia aviana, sagoma leggibile, luce calda laterale, nessun essere umano.
Il Registro assume la forma di un terminale antico in basalto e bronzo, vetro
scuro con segnale ambrato e ingresso per tavolette. Nessun volto o ologramma.
I ritratti 2:3 sono asset senza testo; nomi, stato e dialogo sono resi da Godot.
Le superfici rituali restano materiali, collegate all'apparato del terminale.

Dettaglio e prove: `docs/support/illustrated_dialogues_2026-09-12.md`.

## Ritratti integrati - 8 ottobre 2026

Nerio, Rugo, Dima, Vessa e Orvo usano varianti `dialogue_*_cutout.png`
con alpha reale, derivate dai ritratti esistenti attraverso ImageGen.
Sagome, anatomia aviana e oggetti mantengono la stessa identita' pittorica.
Il fondo della superficie resta visibile tra le piume: nessuna cartella nera,
cornice aggiunta o ombra rettangolare. Il materiale `portrait_grounding.tres`
sfuma soltanto l'ultimo 10 percento inferiore del busto, senza animazioni.
Archivio, banco e conversazioni condividono questi asset. Le sorgenti opache
restano nel manifest per provenienza; i cataloghi runtime usano i cutout.
Prove e limiti nel report `docs/support/claude_review_2026-10-08.md`.
