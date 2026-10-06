# Gallicus - Direzione del prodotto

Questo documento risponde a una sola domanda: **che gioco e' Gallicus e come
deve sentirsi in ogni schermata**. Non sostituisce il canon: lo riassume in
una direzione unica che ogni patch di layout, copy, UI o contenuto deve
rispettare. In caso di conflitto prevalgono i file in `docs/canon/`.

Audit dei gap rispetto a questa direzione:
`docs/support/rework_audit_2026-10-06.md`.

## Anima

> **L'arena dimentica. Il Registro no.**

Gallicus e' un gioco d'azzardo rituale sulla propria definizione.

Nell'arena di Gallicus non si combatte piu': si scommette. Il soggetto entra,
firma una promessa sulla cera, si espone alla gradinata e lascia che un sigillo
decida. Il corpo paga cio' che la firma promette: gloria se regge, un segno se
cede. Un apparato antico, il **Registro**, servito da Gufi amministratori,
copia ogni atto accettato e cerca di stabilire chi sei.

Ogni percorso pone una domanda semplice: **quanto rischi per la gloria?**
L'intera campagna ne pone una seconda, mai scritta a schermo:
**chi diventi a forza di ripeterlo?**

Prima di te c'e' stato **Felix Gallicus**: ha fatto tutto correttamente e il
Registro non e' riuscito a chiuderlo. Sulla gradinata il suo posto e' rimasto
vuoto; Dima lo tiene ancora con una zampa. Il giocatore non ripercorre la sua
strada: la incrocia nei margini.

La campagna termina quando il soggetto e' scritto cosi' a fondo che non resta
nulla da decidere. Il Registro tace, si guasta e infine cessa. L'arena resta,
vuota. Per la prima volta anche il Registro dimentica.

## Tre strati, tre voci

| Strato | Cosa contiene | Chi parla | Come parla |
| --- | --- | --- | --- |
| Gradinata | sabbia, folla, gloria, segni sul corpo, il posto vuoto | Rugo, Dima, la folla | frasi brevi e concrete, memoria dei passi |
| Amministrazione | quote, copie, bandi, archivio | Nerio, Vessa, Orvo | precisione da ufficio, mai giudizio |
| Registro | firma, classificazione, Silenzio | il terminale | righe di stato maiuscole e rare |

Il giocatore non parla mai. Felix non parla mai. Il Registro non spiega,
non consola e non giudica: registra. Le voci degli abitanti danno calore e
mistero; quella del Registro da' peso.

## Fantasia del giocatore

Il giocatore d'azzardo che diventa la propria firma. Ogni scelta e' piccola e
leggibile; il loro accumulo e' irreversibile. La tensione nasce da tre leve,
sempre visibili quando contano:

- **Gloria**: cio' che il percorso ha guadagnato e cio' che e' ora in posta.
- **Pressione**: quanto la gradinata stringe; sale con i rilanci e la sfida.
- **Segni**: i costi accettati che restano sul corpo e pesano sulle prossime arene.

Tutto il resto (firma comportamentale, Ere, soglie, convergenza) resta nascosto
e si percepisce solo attraverso materiali, suono, tono e voci.

## Loop

Arena (circa 10-15 secondi dopo il primo percorso):

```text
apri il Registro -> firma una promessa -> gesto davanti alla gradinata
-> imprimi il sigillo -> responso -> incassa la posta / rilancia
```

Ogni sigillo che regge aggiunge Gloria alla **posta**; uno che cede ne toglie
meta' (tutta, per l'Hybris) e lascia i costi del patto. Dopo ogni responso il
giocatore sceglie fra incassare e rilanciare: e' la domanda dell'arena, posta
ogni volta. Le famiglie dei patti dicono a parole quanto spesso il sigillo
regge e quanto rende; il gesto scambia Pressione con posta.

Percorso (alcuni minuti): al massimo sette arene, limite visibile. Finisce con
la quietanza, con il marchio quando la folla blocca l'incasso, o quando un
patto chiude senza appello; poi il fascicolo dice cosa e' rimasto scritto.

Campagna (2-4 ore): i percorsi giocati davvero (almeno due responsi) formano la
firma; quando la lettura si stabilizza, o quando l'Era ha raccolto abbastanza
prove, arriva un Silenzio e il Registro cambia materia. Dopo quattro Silenzi
resta l'Assenza. Chiudere subito non avvicina la fine.

Regola di ritmo: **un gesto per schermata, nessuna schermata senza decisione o
rivelazione**. Le conferme che non aggiungono informazione si tolgono; le
sequenze ripetute ogni arena si accorciano dopo il primo percorso (la
tavoletta del patto passa da sola, il sigillo vuole un colpo).

Regole e numeri: `docs/canon/MECHANICS_UNIFIED.md`, sezione "Loop rivisto
(ottobre 2026)". Revisione: `docs/support/game_loop_review_2026-10-06.md`.

## Regole di stile UI

Valgono per ogni superficie gameplay e utility.

1. **Una superficie, un oggetto.** Titolo, stato, gesto e conseguenza vivono
   sullo stesso oggetto (tavola, tavoletta, sigillo, fascicolo). Niente card
   dentro card.
2. **Tre livelli di testo.** Titolo (maiuscolo, breve), corpo (frase naturale),
   nota (dettaglio o numero). Mai piu' di tre livelli nella stessa superficie.
3. **Numeri con unita'.** `+6 Gloria`, `Pressione +2`, mai valori nudi o
   separati da barre verticali.
4. **Colore con significato.** Osso su basalto per leggere; bronzo per cio' che
   e' disponibile o a fuoco; cera rossa solo per atti irreversibili (firma,
   marchio); verde ossidato solo per l'anomalia. Lo stato non dipende mai dal
   solo colore.
5. **Maiuscole solo per titoli e comandi.** Frasi narrative e valori in forma
   naturale.
6. **Accenti nativi.** `È`, `più`, `così`: mai apostrofi al posto degli accenti
   nel testo player-facing.
7. **Comando = verbo del gesto.** `FIRMA`, `COLPISCI`, `PRENDI LA QUIETANZA`,
   `RICEVI IL MARCHIO`, `RADDOPPIA`. Non `CONTINUA` o `CONFERMA` quando esiste
   un gesto specifico.
8. **Un posto per ogni informazione persistente.** Posta, Pressione e arena
   (su sette) stanno nel rail in basso; i Segni nel riquadro in alto a destra.
   La ricevuta della quietanza ripete la posta solo come importo da incassare.

## Lessico unico

| Parola | Significa solo | Non usare per |
| --- | --- | --- |
| Patto / promessa | cio' che firmi nel Registro | esiti o premi |
| Posta | gloria in gioco nell'arena corrente | gloria gia' incassata |
| Gloria | valore guadagnato dal percorso | punteggio astratto |
| Pressione | rischio corrente della gradinata | escalation, difficolta' |
| Segno / cicatrice | costo persistente sul corpo | equipaggiamento, malus generico |
| Marchio | scelta di chiudere accettando la perdita della posta | condanna del Registro |
| Condanna | registrazione avversa del Registro | errore, morte, achievement |
| Percorso | una partita dal primo patto al fascicolo | run, partita |
| Fascicolo | il riepilogo scritto di un percorso | game over |

Parole escluse dal testo player-facing: morte, uccidere, nemico, combattimento,
run, escalation, opzione, conferma.

## Cosa resta fermo

- `RunManager` resta l'unica autorita' del flow, `GameEvents` il bus, la UI
  reagisce ai payload.
- Nessuna nuova economia, power scaling, modalita' endless o New Game+.
- Il Registro non diventa personaggio; Felix non appare.
- Firma, Ere e soglie del Silenzio non diventano contatori visibili.
- Il timing del sigillo non influenza l'esito.

## Come si usa

Ogni patch player-facing indica quale regola di questo documento applica o
corregge. Se una patch richiede di cambiare l'anima, il lessico o le regole di
stile, aggiorna prima questo documento e il canon pertinente, poi il codice.
