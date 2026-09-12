# Gallicus Cinematic Direction

## Funzione

Le cinematiche collegano cambi di stato che una singola schermata non puo'
esprimere. Non sostituiscono gameplay e non spiegano la cosmologia. Il pass
autorizzato del 12 settembre aggiunge conversazioni illustrate circoscritte.

Devono essere brevi, in-engine e object-first.

## Grammatica

Ogni sequenza dichiara:

```text
stato prima -> oggetto -> trasformazione -> stato dopo -> controllo restituito
```

- l'oggetto resta il soggetto della ripresa;
- il punto di vista rimane quello del soggetto nell'arena;
- nessuna sequenza introduce un personaggio guida;
- input e focus tornano in modo prevedibile;
- una variante reduced-motion conserva informazione e timing.

## Sequenze ammesse

### Apertura

La finestra illustrata a lettura manuale sostituisce il prologo automatico
descritto nelle reference storiche sotto. Specifica corrente in `docs/support/illustrated_dialogues_2026-09-12.md`.

- soglia dell'arena;
- primo contatto con il Registro;
- lettura manuale, skippabile anche alla prima visione dopo 0,5 secondi;
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

## Prologo dell'8 settembre 2026 - storico, sostituito il 12 settembre

Richiesta dell'utente: valutare un'apertura che renda comprensibile la lore.
Raccomandazione: prologo in-engine di circa 8 secondi, centrato sulla premessa
del Registro. L'utente ha approvato proposta e correzioni dell'audit.
Controller locale: `scripts/ui/opening_prologue.gd`, sotto Main.

| Tempo | Immagine e funzione | Copy IT proposto |
| --- | --- | --- |
| 0-3 s | Soglia dell'arena, avvicinamento minimo; chiarisce il luogo | Ogni rischio accettato lascia un segno. |
| 3-6 s | Registro chiuso, dettaglio di cera e bronzo; chiarisce cosa permane | Il Registro conserva le tue scelte. |
| 6-8 s | Dissolvenza nella schermata esistente; controllo al primo gesto | APRI IL REGISTRO, come controllo nativo gia' presente |

Bozza EN: "Every accepted risk leaves a mark." / "The Registry preserves your
choices." Bozza ES: "Cada riesgo aceptado deja una marca." / "El Registro
conserva tus decisiones." Il copy deriva dalla premessa in
`docs/canon/LORE_UNIFIED.md`; non introduce giudizi morali, personaggi guida,
nuove regole, rivelazioni su Felix o anticipazioni del finale.

Riutilizzare registry_chamber e registry_closed come base; eventuali dettagli
ImageGen devono mantenere camera, luce, pietra e bronzo del tema approvato.
Il testo resta nativo e localizzato. Bastano ambiente, cue di soglia e musica
del Registro: niente voce narrante o nuova traccia obbligatoria. Un solo cue
per l'ingresso, evitando di duplicare quello del pulsante del menu.

Contratto implementato: solo avvio della prima campagna,
mai ripresa di un save o ripetizione a ogni run; skip visibile e da tastiera
dopo 0,5 s anche alla prima visione; restituzione del focus ad APRI IL REGISTRO;
nessun blocco in caso di skip, cambio lingua, resize o chiusura. Movimento
ridotto conserva le due frasi e il tempo di lettura su immagini ferme:
la dissolvenza ridotta a un secondo della vecchia bozza MV non basta se si
aggiunge questo testo. Nessuna nuova fase autoritativa o salvataggio intermedio.

Prova di valore in CP-03: dopo il prologo, il player sa dire dove si trova,
cosa conserva il Registro e quale gesto deve fare. Se non migliora queste
risposte, rivedere il copy prima di aggiungere durata o spiegazioni.

Il primo ingresso esplicito dal menu prepara la presentazione; run_started
la mostra dopo l'avvio autoritativo. L'overlay intercetta input durante gli
otto secondi, senza ritardare un intento di gameplay. Escape, Invio o click
su SALTA terminano dopo 0,5 s e restituiscono il focus al Registro. Ritorno
al menu, Continue e run_ended annullano overlay e processing. Il cambio
lingua aggiorna le frasi, il resize mantiene gli anchor. Movimento ridotto
mantiene otto secondi e immagini ferme, senza dissolvenza.

La preferenza booleana settings.opening_prologue_seen, default false,
persistita da SaveManager al primo avvio, evita replay anche se si esce
prima di firmare. Nessuna fase cinematica nel run save. Profili preesistenti
con save, pressione, Era o campioni di campagna bypassano il prologo.
Nessun timer o processing del prologo resta attivo dopo la chiusura.

Scheda object-first: intento = comprendere la soglia; oggetto = arena e
Registro chiuso; materiale = pietra, bronzo, cera; gesto = attraversare poi
aprire; feedback = due frasi, immagini e score esistente; registrazione =
solo preferenza di presentazione vista. RunManager conserva decisioni e
campagna; skip e testo fermo sono i fallback accessibili. Prove: ingresso,
skip anticipato respinto, Escape, fine automatica, resize, lingua, reduced
motion, ripresa e nessun replay, documentate nel report di coerenza.

## Congedo terminale - 12 settembre 2026

La richiesta di completamento pre-umano autorizza la messa in scena mancante.
L'Assenza presenta sei secondi nella stessa arena vuota, senza esseri umani,
protagonista, commento o oggetto da interrogare. Il
quadro termina nel nero con il battito esistente. Movimento ridotto conserva
il quadro fermo e i sei secondi, senza dissolvenza. Nessun input opera sul
fascicolo coperto. Sul nero sono disponibili soltanto crediti e uscita.

Il profilo terminale e' scritto da RunManager prima del congedo. Un riavvio
apre direttamente il nero; richieste duplicate non ripetono la sequenza.
Nessuna preferenza cinematica o nuova fase salvata. La UI non emette nuove
richieste di gameplay; l'uscita e il dialogo crediti sono utility locali.

Scheda object-first: intento = cessazione della consultazione; oggetto =
assenza del Registro; gesto = nessuno; feedback = arena priva di responso,
nero e battito; registrazione = solo stato terminale gia' commesso.
Fallback = quadro fermo, focus confinato, crediti/uscita testuali.

Correzione dell'utente: la trama non contiene esseri umani. Il riferimento
ai soggetti non classificati non autorizza un cast umano. La prima immagine
con figure umane era un'interpretazione errata ed e' stata sostituita.
