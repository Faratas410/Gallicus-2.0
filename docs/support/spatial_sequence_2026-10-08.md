# Attraversare la soglia - prova di regia, 8 ottobre 2026

## Richiesta e perimetro

Il testo fornito dall'utente corregge l'estensione del banco a tutte le fasi:
identita' comune della UI, luoghi e inquadrature diversi secondo l'esperienza.
Il pass richiesto e' una prima sequenza di quattro viste provvisorie, leggibile
anche senza etichette. Questa consegna e' una prova artistica separata dal
runtime: nessuna modifica a scene, script di gioco, segnali, dati o salvataggi.

Il banco integrato nel pass precedente resta il candidato giocabile locale.
La direzione da sviluppare sposta il rischio sulla sabbia e il documento dopo
l'uscita. La nuova geografia e' uno schema di lavoro, non un fatto narrativo
aggiunto al canon.

## Geografia e inquadrature

Il vestibolo e il portico affiancano il lato ovest dell'arena. L'apertura
riconoscibile e' un arco basso con tre conci scuri e un vessillo rosso spento.
La luce diffusa proviene dallo spazio aperto a est.

| Veduta | Posizione | Riferimento | Composizione |
| --- | --- | --- | --- |
| 01 Registro | vestibolo, verso l'arena | rovescio del vessillo a sinistra | banco laterale, passaggio libero, documento vicino |
| 02 Arena | sabbia, dopo la soglia | arco di scorcio sul lato sinistro | sabbia in primo piano, supporto rituale basso, spazio aperto |
| 03 Gradinata | stessa area dell'arena, sguardo rialzato | arco e parete curva ancora riconoscibili | gradoni dominanti, fascia di sabbia in basso |
| 04 Portico | nicchia presso l'uscita | arco visto dall'interno, arena a destra | spazio raccolto, carta vicina, arena periferica |

Le vedute 02 e 03 condividono il luogo. Il montaggio non aggiunge un viaggio
tra rito e Gradinata. L'ordine di gioco rimane firma -> scambi -> giudizio ->
scelta di proseguire o incassare; i numeri delle tavole sono ordine di revisione,
non nuovi identificatori di fase.

## Conseguenze spaziali

- Raddoppio: permane la vista dell'arena; torna l'attenzione al rito.
- Quietanza confermata: passa al portico, poi il documento diventa centrale.
- La decisione incasso/raddoppio avviene sulla sabbia.
- I Segni non richiedono una nuova scena.
- Un abbassamento dello sguardo e una risposta sostenuta alla Gradinata sono
  direzioni di motion da rifinire; il prototipo usa solo passaggi brevi.
- Tre condizioni sonore (Registro ravvicinato, arena aperta, uscita raccolta)
  restano proposte di regia. Nessun audio o narratore e' stato aggiunto.

## Consegna locale

Cartella: `artifacts/attraversamento_2026-10-08/`.

- `01_registro.png`
- `02_arena.png`
- `03_gradinata.png`
- `04_portico.png`
- `index.html`: sequenza sfogliabile, geografia SVG, UI campione disattivabile,
  movimento ridotto e comandi per confrontare permanenza e uscita.
- `prompts.json`: prompt completi, riferimenti, sorgenti e SHA-256 dei quattro PNG.
- Copie locali di font Libre Baskerville, OFL.txt e carta esistente per rendere
  l'anteprima apribile anche direttamente da file, senza dipendenze esterne.

Generazione con ImageGen integrato. Primo riferimento: registry_counter
esistente, usato per materiali e architettura. Le altre tre vedute derivano
dalla prima nuova immagine per continuita'. Nessun ritocco esterno ai PNG.
Testi, controlli e mappa sono HTML/CSS/SVG separati.

Il prototipo usa una sola offerta e valori campione tratti dal linguaggio
corrente: non e' una simulazione delle tre risposte, dei colpi o delle ricompense.
Non introduce un nuovo flusso nel gioco. La UI campione e' solo italiana;
la futura integrazione resta soggetta alla matrice IT/EN/ES del progetto.

## Verifica e lettura critica

Quattro immagini aperte e ispezionate: banco assente nelle due viste interne,
sabbia visibile in primo piano, arco e vessillo ricorrenti, portico ripreso di
scorcio. Nessuna figura umana, scritta generata o sigillo aggiunto al personaggio.

Anteprima aperta nel browser locale e controllata con UI nascosta/visibile.
Verificati firma -> Gradinata, rito -> scelta, raddoppio -> stessa arena,
quietanza -> portico. Il resoconto lascia visibile l'apertura laterale.
Riferimenti docs, diff ed encoding verificati alla consegna.
Nessuna suite Godot ripetuta: questo pass non modifica il runtime.

La prova sostiene la separazione spaziale; non dimostra ancora una regia
definitiva. Il pubblico e' rarefatto e provvisorio, l'architettura conserva
piccole differenze fra generazioni e le superfici hanno ancora una grana
abbondante. Prima della produzione occorre uniformare dettaglio e scala
sull'asset set selezionato, poi verificare transizioni e suono in gioco.

## File documentali toccati

- `docs/README.md`: accesso alla prova.
- `docs/art_direction.md`: distinzione tra candidato corrente e nuova regia.
- `docs/development_plan.md`: prossimo passo di revisione della sequenza.
- `docs/support/spatial_sequence_2026-10-08.md`: questo report.

Lavoro lasciato in locale su main, modifiche precedenti conservate. Nessun
commit, push, export, pubblicazione o nuova chiusura di gate.

