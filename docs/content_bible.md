# Gallicus Content Bible

## Voce

Gallicus parla con tono rituale, amministrativo e preciso. Il Registro non e'
un narratore moderno: annota, pesa, confronta, convalida e conclude.

La durezza nasce dalla procedura e dall'irreversibilita', non da gore o insulti.

La voce dei Gufi e' distinta: brevi scambi fra Nerio (precisione della copia),
Vessa (margine commerciale) e Orvo (attenzione della gradinata). Sono colleghi
dell'amministrazione. Rugo, gallo della soglia, misura il richiamo; Dima,
gallina della gradinata, ricorda gli occupanti dei posti; Lauro, storno
cantastorie, mette in versi le gesta e ruba la voce agli altri. Nessuno e' umano
o narratore del Registro. Quaranta scambi
di due battute, nei due contesti patto/gesto e nelle varianti distese/compresse,
sono localizzati in IT/EN/ES insieme a ruoli e schede. I nomi non si traducono.
La firma resta attestata dal titolo del patto; il corpo ospita "Voci dell’arena".
Nel gesto la riga della gradinata resta sopra lo scambio. Nessuna voce nei
Silenzi o nell'Assenza; nessuna battuta di Felix. Il catalogo e' in
`scripts/content/arena_characters.gd` e il dettaglio in
`docs/support/arena_cast_2026-09-12.md`.

## Lessico player-facing

Il lessico unico e le parole escluse sono definiti in `docs/direction.md`.

- `percorso`, `ciclo`, `fascicolo` al posto del termine tecnico `run`;
- `pressione` al posto di `escalation`;
- `incassa`, `rilancia`, `condanna`, `segno`, `patto`, `Registro`;
- `apri`, `firma`, `incidi`, `colpisci`, `prendi`, `accetta`, `chiudi`;
- frasi brevi nelle superfici interattive;
- frasi dense solo nei verdetti e nell'Archivio.

## Da evitare

- gergo tecnico o percentuali interne;
- `continua`, `conferma`, `opzione` quando esiste un gesto specifico;
- tono ironico o battute fuori mood;
- linguaggio action/combat;
- promesse di meccaniche non presenti;
- Registro personificato come villain, guida o coscienza morale;
- spiegazioni strategiche messe in bocca al Registro.

## Formula della copy

La copy sostiene:

```text
intento -> oggetto -> gesto -> feedback -> registrazione
```

Esempio:

```text
Vuoi chiudere il dovuto -> quietanza -> prendila
-> il conto si chiude -> il fascicolo registra l'incasso
```

La label dell'azione resta breve. Rischio e conseguenza vivono sulla superficie
dell'oggetto, non dentro un bottone troppo lungo.

## Struttura delle schermate

- Soglia: cosa significa entrare.
- Bet: promessa, costo e vincolo.
- Patto: cosa e' stato firmato.
- Gesto pubblico: atto e variazione percepibile della pressione.
- Rito: oggetto, colpo richiesto e stato del verbale.
- Push-your-luck: tre conseguenze confrontabili.
- Fascicolo: esito, evidenza raccolta e route disponibile.
- Silenzio: assenza di responso, non spiegazione dell'Era. Il terminale
  mostra una sola riga di stato (precedente Felix al primo Silenzio).
- Fascicolo: esito, Gloria del percorso, segni, pressione massima, patti
  firmati per titolo e nuove voci d'Archivio.
- Assenza: nessuna frase classificatoria finale.

## Contenuti di campagna

Il contenuto deve coprire una matrice, non soltanto raggiungere un numero:

- tutti i path canonici;
- le condizioni rilevanti delle quattro Ere;
- cashout, condanna e double;
- scars e condanne principali;
- firma liquida e firma fissata;
- Silenzi e finale terminale;
- ending dichiarati nei cataloghi.

Una variazione e' valida solo se cambia interpretazione, rischio percepito o
memoria. Riscrivere lo stesso testo con sinonimi non conta.

## Bet

Ogni bet richiede:

- id stabile;
- titolo breve;
- promessa;
- condizione;
- conseguenza;
- path tag;
- behavior esistente o documentato;
- oggetto e gesto di firma;
- varianti linguistiche previste;
- stato di eleggibilita' testabile.

## Scars e condanne

Ogni voce richiede:

- id stabile;
- titolo leggibile;
- origine tracciabile;
- effetto comprensibile prima dell'accettazione;
- segno fisico o amministrativo;
- frase registrabile;
- relazione con firma e finale.

Una condanna non e' un messaggio di errore. Una scar non e' equipaggiamento.

## Ending e Silenzio

- Gli ending classificano evidenza realmente prodotta.
- La priorita' tra ending deve essere deterministica.
- Il Silenzio non e' un premio raro da collezionare.
- L'Assenza non usa una classificazione conclusiva.
- Nessuna route finale deve contraddire lo stato persistito.

## Ere

- Era 0: voce completa e ancora interpretativa.
- Era 1: frasi piu' rigide e assertive.
- Era 2: asimmetrie controllate, non testo corrotto.
- Era 3: compressione e rarefazione.
- Era 4: nessuna nuova voce del Registro.

Le Ere non vengono nominate nella UI e le transizioni restano graduali.

## Localizzazione

- L'italiano e' sorgente editoriale.
- Inglese e spagnolo preservano funzione e tono.
- Titoli e CTA devono reggere il layout piu' stretto.
- Nessuna chiave mancante o fallback player-facing in release.
- Il glossario canonico guida la terminologia.

### Gesto davanti alla gradinata

- La scelta composta usa `ABBASSA LO SGUARDO`, `LOWER YOUR GAZE`,
  `BAJA LA MIRADA` e registra misura/restraint/mesura.
- La scelta di sfida usa `SFIDA LA GRADINATA`, `CHALLENGE THE CROWD`,
  `DESAFÍA A LA GRADA` e registra esposizione/exposure/exposición.
- Le reazioni della gradinata restano osservazioni del payload, non giudizi o
  tutorial del Registro, e sono complete nelle tre lingue di release.
- Negli scambi (ottobre 2026) il titolo dice cosa sta per fare la folla in una
  frase concreta (`La gradinata vuole sangue.`, `raccoglie la sabbia`,
  `si annoia`, `trattiene il fiato`) e ogni risposta stampa il proprio prezzo
  con unita' (`Favore +1, Pressione +1.`). Favore e' EN `Favour`, ES `Favor`.
  Trionfo e rivolta: `LA GRADINATA TI PORTA`, `LA GRADINATA SI RIVOLTA`.

### Banco di Vessa

- Vessa (margine commerciale) tiene il conto: voce d'ufficio, mai giudizio.
  Titolo `BANCO DI VESSA`, comandi `COMPRA IL FAVORE`, `PAGA LA PRESSIONE`,
  `ASSICURA LA POSTA`. Denari: EN `Denarii`, ES `Denarios`; conto: EN
  `Account`, ES `Cuenta`; banco: EN `Vessa's counter`, ES `Mostrador de Vessa`.
- Le note dicono la cifra con l'unita' (`Quietanza versata: Denari +3.`).

### Colpo sul sigillo

- Il rito usa `COLPISCI`, `STRIKE`, `GOLPEA` come CTA breve sul sigillo.
- Il prompt resta amministrativo: colpire il sigillo a tempo, non vincere un
  minigioco.
- I tre messaggi sono progressivi e materiali: cera impressa, verdetto
  inciso, sigillo chiuso. Nessuno anticipa una condanna prima del responso.
- Il Registro registra l'avanzamento del verbale, non commenta l'abilita' del
  giocatore.
- La riga contestuale della folla ricevuta dal payload viene localizzata al
  confine UI; EN/ES non mostrano la chiave sorgente italiana nel rito.

## Accettazione

- nessun placeholder o fallback generico;
- nessun mojibake;
- ogni comando gameplay ha oggetto e gesto;
- ogni ending e contenuto dichiarato e' raggiungibile;
- la matrice contenuti e' coperta da test o playtest;
- il testo e' leggibile nelle tre lingue alle risoluzioni target.

## Copy e classificazioni corrette nella bonifica

Il rito chiede `IMPRIMI IL SIGILLO`; la CTA resta `COLPISCI`, poi
`COLPISCI ANCORA` accanto a `ALZA LA MANO` quando il sigillo regge.
Nessuna frase promette un effetto del timing sul risultato. Il gesto pubblico
dichiara `Il gesto è registrato. La pressione è cambiata.` senza negare la
conseguenza della scelta. La firma fissata usa `Condizione registrata.` e
`Configurazione stabile.`; queste righe e i Quick Cut sono tradotti IT/EN/ES.

Violence e Penitence mantengono identita' nella traccia. I 14 predicati ending
hanno ciascuno un witness runtime indipendente. Broken precede i fallback;
Fall richiede tre patti Violence; Survivor esclude gloria alta; Pet richiede
un incasso, perche' il primo chiude la run. Silenzio e Assenza non emettono
verdetto, sconfitta o unlock di fine run.

## Voce del menu

- Invito: "L'arena dimentica. Il Registro no."
- Soglia: "ENTRA NELL'ARENA".
- Ripresa quando esiste un salvataggio valido: "RIPRENDI IL PERCORSO".
- Rientro: "Il tuo passaggio e' registrato." (accento nativo nei cataloghi).

Il menu presenta identita' e invito; il vecchio paragrafo Obiettivo e'
rimosso. Spiegazioni di gesti e conseguenze restano nelle rispettive fasi.
Le tre nuove frasi sono localizzate in IT/EN/ES; il marchio non si traduce.

## Copy del sigillo - 6 settembre 2026

Il richiamo luminoso ora e' breve. Dall'ottobre 2026 l'istruzione del rito e'
"Ogni colpo mette alla prova la cera." (EN: "Every strike tests the wax.";
ES: "Cada golpe pone a prueba la cera."): ogni colpo e' una prova e il
giocatore sceglie se colpire ancora (vedi "Arena attiva" in
`docs/canon/MECHANICS_UNIFIED.md`).

## Apertura e utility - 8 settembre 2026

Il prologo approvato usa due frasi native IT/EN/ES: "Ogni rischio accettato
lascia un segno." e "Il Registro conserva le tue scelte." Nessuna guida,
spiegazione del finale o regola aggiunta. Traduzioni e durata sono in
`docs/cinematic_direction.md`. Titoli e comandi utility sono maiuscoli;
frasi narrative e valori delle impostazioni restano in forma naturale.
Crediti usa il titolo GALLICUS e ringrazia i partecipanti al playtest, con
corpo tradotto. Nomi e attribuzioni definitive restano sospesi per richiesta
dell'utente e devono essere completati prima della pubblicazione.

L'Archivio localizza anche i nomi dinamici di tutti i patti disponibili,
le arene, le condizioni e le righe lore delle condanne. Settanta chiavi
mancanti sono aggiunte ai tre cataloghi, senza cambiare gli ID o le regole.
I codici ending interni restano nelle chiavi sorgente e non vengono mostrati
nel testo localizzato delle condizioni. I titoli delle voci gia' costruite
si aggiornano al cambio lingua, senza conservare il testo iniziale italiano.

## Pass di campagna - 12 settembre 2026

L'Archivio affianca ai titoli dei patti disponibili il sottotitolo del catalogo
IT/EN/ES. Sostituisce il conteggio delle battute con il rapporto fra pubblico,
gesto e responso: conoscere il contenuto deve aiutare a riconoscere un vincolo.
Non aggiunge sblocchi o rivela firma/Ere. Il fascicolo e la convergenza usano
la medesima identita' calcolata prima delle annotazioni di chiusura. Il finale
non aggiunge copy narrativo: dopo il congedo restano CREDITI e ESCI DAL GIOCO.
Prove e matrice in `docs/support/campaign_completion_2026-09-12.md`.

## Conversazioni illustrate - 12 settembre 2026

Tre scene di sei battute nel catalogo scripts/content/campaign_dialogues.gd:
«La prima copia», «La stessa riga», «Il posto accanto». I tre interlocutori
ritratti sono Nerio, Rugo e Dima; il terminale ha due inserti marcati come stato.
Le scene accompagnano inizio, meta' e ultimo tratto della campagna. Dima passa
dal tenere un posto al lasciarlo libero; Rugo dal richiamo alla presenza quieta.
Le battute brevi gia' presenti su patto/gesto restano distinte dalle scene.
Nessun testo del giocatore o di Felix, nessuna risposta morale o strategica.

Dettaglio e prove: `docs/support/illustrated_dialogues_2026-09-12.md`.

## Racconti - 7 ottobre 2026

Su richiesta dell'utente ("aggiungi un po' di lore e racconti"), cinque scene
di sei battute si aggiungono alle tre conversazioni illustrate, nello stesso
catalogo e con gli stessi ritratti (Nerio, Rugo, Dima e il terminale). Con il
bando di Orvo ("Perche' continuare?") diventano otto e ognuna e' il premio di
un gradino della scala dei bandi. Con Lauro il cantastorie (7 ottobre 2026)
diventano dieci; quattro raccontano il posto vuoto (`seat_kept`, `footstep`,
`open_strophe`, `slope`) e sono garantiti dalla campagna anche senza bando,
dall'Era 1 i primi due e dall'Era 2 gli altri, sempre prima del congedo:

| Id | Titolo | Gradino | Cosa racconta |
| --- | --- | --- | --- |
| `first_strophe` | La prima strofa | 1 | Lauro arriva sulla gradinata: canta quello che le righe lasciano fuori |
| `ledger` | Il conto di Vessa | 2 | il conto dei Denari e il debito ricordato alla gradinata |
| `sand` | La sabbia nelle tasche | 3 | perche' la gradinata lancia sabbia o monete |
| `seat_kept` | Il posto tenuto | 4 | chi sedeva accanto a Dima chiudeva ogni bando e se n'e' andato senza chiusura |
| `call` | Il richiamo | 5 | Orvo che prova i richiami, la tacca di Rugo |
| `seats` | I posti in vendita | 6 | il righello di Vessa si ferma al posto accanto a Dima |
| `footstep` | Il passo | 7 | Dima sente un passo nuovo uguale al suo |
| `open_strophe` | La strofa aperta | 8 | la gesta di chi sedeva accanto a Dima: Lauro non riesce a finirla e non la inventa |
| `scraping` | La riga che resta | 9 | la riga che Nerio non riesce a raschiare |
| `slope` | La stessa pendenza | 10 | la copia del soggetto e quella riga hanno la stessa pendenza; il terminale: "CONFRONTO IN CORSO / Corrispondenza parziale." |

Il riquadro del bando e il fascicolo dicono il titolo del racconto in palio
(`In palio il racconto «%s».`), cosi' il prossimo racconto e' la ragione per
chiudere il prossimo bando.

Vessa e Orvo non hanno ritratto: se ne parla, non parlano. I racconti danno
corpo ai sistemi gia' presenti (conto, sabbia, favore, posti) senza spiegarne
le regole, senza nominare Felix, le Ere o il Silenzio e senza parole del
giocatore. "Un nome e un fascicolo aperto" resta allusione: il nome arriva
solo dal terminale al primo Silenzio. Le dodici nuove voci dell'arena (tre per
contesto, distese e compresse) toccano gli stessi temi: conto, tasche piene,
terza fila venduta, folla che paga chi la regge.

## Lauro e la gesta - 7 ottobre 2026

Lauro, storno cantastorie, parla in versi brevi che cominciano spesso con
"Udite". Ruba la voce agli altri (il richiamo di Orvo, il grido di Rugo) e
ammette di ricordare male: "L'arena dimentica. Il Registro no. Io ricordo
male, ma ricordo." Non e' buffo e non e' un giullare: e' caldo, preciso sui
fatti, libero sulle parole.

La gesta del fascicolo e' una strofa di tre versi (catalogo
`scripts/content/cantastorie.gd`, due varianti per verso, scelte dal seme):

| Verso | Da che cosa dipende | Esempio |
| --- | --- | --- |
| Apertura | arene raggiunte (una, 2-4, 5-6, sette) | "Udite: %d arene sotto la stessa gradinata." |
| Fatto | il primo che vale: bando chiuso, catena di 3+, gradinata che porta, Segno mostrato, sabbia lanciata, 20+ Gloria, altrimenti un verso semplice | "%d sigilli di fila, e la cera non cede." |
| Chiusura | quietanza, marchio, cera che cede, fascicolo classificato | "Poi la quietanza: il Registro copia la cifra, io il resto." |

Sotto la strofa una nota dice la gesta piu' alta ("Gesta più alta: %d Gloria
in %d arene.", o "Nuova gesta più alta" quando la si batte). Otto nuove voci
dell'arena (due per contesto, distese e compresse) mettono Lauro accanto a
Nerio, Dima, Orvo e Rugo.
