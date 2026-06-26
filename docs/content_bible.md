# Gallicus Content Bible

## Tono

Gallicus usa tono rituale, amministrativo e tagliente. Il Registro non parla come tutorial moderno: annota, pesa, classifica e condanna.

## Lessico preferito

- Usare `percorso` per la run percepita.
- Usare `pressione` per escalation/rischio.
- Usare `incassa`, `rilancia`, `condanna`, `segno`, `Registro`, `fascicolo`.
- Usare frasi brevi nelle UI.
- Usare frasi piu' dense solo in lore o verdetto.

## Lessico da evitare in UI

- Gergo tecnico non necessario.
- Battute fuori mood.
- Spiegazioni lunghe dentro bottoni.
- Copy che promette sistemi non presenti.
- Termini action/combat se la schermata e' rituale.

## Grammatica delle schermate

- Menu: obiettivo in una riga.
- Bet: promessa + prezzo.
- Patto: conferma rituale.
- Scelta intermedia: gesto + effetto sulla pressione.
- Rito: azione fisica semplice + stato del verbale.
- Push-your-luck: tre conseguenze confrontabili.
- END_RUN: esito + stato + uscita.

## Regola object-first per la copy

La copy deve sostenere la grammatica `intento -> oggetto -> gesto -> feedback -> registrazione` descritta in `docs/object_grammar.md`.

- Preferire verbi fisici e amministrativi: apri, firma, incidi, colpisci, chiudi, registra, accetta.
- Evitare copy che suona come UI generica: continua, conferma, scegli opzione, procedi.
- Un bottone puo' avere testo breve, ma il pannello deve chiarire quale oggetto viene usato.
- Il Registro deve annotare l'atto, non spiegare la strategia.

## Contenuti runtime

Ogni nuova bet deve avere:
- titolo breve;
- subtitle leggibile;
- path tag;
- comportamento esistente o nuovo comportamento documentato;
- conseguenza coerente con tono e sistema.

Ogni nuova condanna deve avere:
- id stabile;
- titolo leggibile;
- testo narrativo breve;
- effetto comprensibile;
- origine tracciabile.

## Verifica

- Leggere la schermata a 1280x720.
- Nessuna riga deve spezzare una parola in modo brutto.
- Nessun testo deve contenere mojibake.
- Ogni nuovo comando visibile deve avere un oggetto e un gesto riconoscibili.
- Aggiornare `docs/data_schema.md` se cambia shape dei dati.
