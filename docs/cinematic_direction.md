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
