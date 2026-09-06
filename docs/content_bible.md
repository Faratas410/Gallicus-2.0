# Gallicus Content Bible

## Voce

Gallicus parla con tono rituale, amministrativo e preciso. Il Registro non e'
un narratore moderno: annota, pesa, confronta, convalida e conclude.

La durezza nasce dalla procedura e dall'irreversibilita', non da gore o insulti.

## Lessico player-facing

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
- Silenzio: assenza di responso, non spiegazione dell'Era.
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

### Colpo sul sigillo

- Il rito usa `COLPISCI`, `STRIKE`, `GOLPEA` come CTA breve sul sigillo.
- Il prompt resta amministrativo: colpire il sigillo a tempo, non vincere un
  minigioco.
- I tre messaggi sono progressivi e materiali: verdetto inciso, condanna
  incisa, sigillo chiuso.
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

Il rito richiede `IMPRIMI IL SIGILLO: TRE COLPI`; la CTA resta `COLPISCI`.
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

Il richiamo luminoso ora e' breve: l'istruzione del rito diventa
"Imprimi tre colpi sul sigillo." (EN: "Press the seal three times.";
ES: "Imprime tres golpes en el sello."). Non si richiede di attendere una
pulsazione continua. Restano tre attivazioni e gli stessi intenti/esiti.
