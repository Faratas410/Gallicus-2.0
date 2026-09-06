# Gallicus Cinematic Direction

## Funzione

Le cinematiche collegano cambi di stato che una singola schermata non puo'
esprimere. Non sostituiscono gameplay, non spiegano il canon e non trasformano
Gallicus in una narrazione a personaggi.

Devono essere brevi, in-engine e object-first.

## Grammatica

Ogni sequenza dichiara:

```text
stato prima -> oggetto -> trasformazione -> stato dopo -> controllo restituito
```

- l'oggetto resta il soggetto della ripresa;
- il punto di vista rimane quello della persona nell'arena;
- nessuna sequenza introduce un personaggio guida;
- input e focus tornano in modo prevedibile;
- una variante reduced-motion conserva informazione e timing.

## Sequenze ammesse

### Apertura

- soglia dell'arena;
- primo contatto con il Registro;
- durata breve e skippabile dopo la prima visione;
- nessuna esposizione testuale lunga.

La reference operativa del gate `MV-03` e' in
`docs/support/media_vertical_slice/README.md`: durata target 6-8 secondi,
controller locale a `Main`, skip dopo 0,5 secondi e dissolvenza di circa un
secondo per reduced motion. Le reference e i layer in quella cartella non
entrano nel runtime prima della decisione go/no-go di `CP-03`.

### Firma e patto

- micro-sequenza integrata nel gesto;
- cera, stilo e sigillo;
- non blocca il player oltre il tempo necessario a leggere la conseguenza.

### Silenzio

- sottrazione dell'ambiente e della risposta;
- nessun annuncio di Era;
- transizione legata a una conseguenza registrata;
- non skippabile solo per il minimo intervallo necessario al cambio di stato.

### Ramp tra Ere

- non e' una cutscene autonoma;
- si manifesta per tre run tramite dettagli di materiale, suono e linguaggio.

### Assenza del Registro

- cessazione della superficie classificatoria;
- nessun vincitore, nemico sconfitto o discorso;
- frame nero terminale e singolo battito;
- accesso solo a uscita e crediti previsti dal finale canonico.

## Divieti

- trailer interno o montage;
- dialoghi esplicativi;
- camera action, combattimento o gore;
- Felix mostrato come protagonista;
- Gufi usati come narratori;
- glitch digitali pesanti;
- video prerender che duplica asset e stati gia' disponibili in-engine.

## Tecnica

- Le sequenze reagiscono a stato autoritativo e non mutano flow dalla UI.
- `RunManager` resta owner delle transizioni.
- Gli eventi cinematici devono essere osservabili e testabili.
- Il gioco non salva in uno stato intermedio non ripristinabile.
- Skip, resume e cambio lingua non devono lasciare overlay bloccati.

## Accettazione

- sequenza comprensibile senza lore esterna;
- durata proporzionata al gesto;
- skip e reduced motion verificati;
- nessun testo tagliato nelle tre lingue;
- nessun frame vuoto involontario;
- screenshot o video viewport-only per ogni sequenza modificata.

## Pass animazioni autorizzato del 6 settembre 2026

L'integrazione audiovisiva richiesta dall'utente supera il precedente freeze
operativo; i gate umani restano aperti. Questo pass lavora sulle micro-sequenze
esistenti e non dichiara completate intro, ramp audiovisiva o cutscene mancanti.
L'apertura del Registro usa drop 0,22 s, apertura 0,24 s, assestamento 0,12 s,
reveal 0,18 s e scrittura 0,35 s. La lettura non ha piu' un titolo pulsante.
Il sigillo richiama l'attenzione una volta per 0,60 s; il gesto produce il
feedback materico breve. Le entrate rituali usano 4 px e scala 0,99 per 0,22 s;
la variazione dello shade e' ridotta a 0,02 (0,03 sul fascicolo finale).
Controlli, intenti e proprieta' del flow rimangono invariati. Movimento ridotto
conserva testo, stati e focus senza introdurre attese VFX.

Entrata pannelli, backdrop e shade tengono un solo tween per superficie.
Movimento ridotto interrompe anche una transizione gia' iniziata e ripristina
subito geometria e alpha, senza un successivo rimbalzo al frame finale.
