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

## Accettazione

- nessun placeholder o fallback generico;
- nessun mojibake;
- ogni comando gameplay ha oggetto e gesto;
- ogni ending e contenuto dichiarato e' raggiungibile;
- la matrice contenuti e' coperta da test o playtest;
- il testo e' leggibile nelle tre lingue alle risoluzioni target.
