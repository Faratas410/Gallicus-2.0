# Gallicus Object-First Grammar

## Scopo

Questa grammatica trasforma le azioni player-facing di Gallicus da comandi astratti a gesti rituali leggibili.

Domanda guida:

```text
Se fossi davvero il soggetto nell'arena, quale oggetto userei per fare questa cosa?
```

La risposta deve arrivare prima di layout, CTA, icone o microcopy. Il bottone puo' restare la forma tecnica dell'input, ma il player deve percepire un oggetto, un gesto e una conseguenza registrata.

## Confini

- Non cambia il core loop.
- Non introduce nuove meccaniche.
- Non cambia ownership: `RunManager` flow authority, `GameEvents` bus, UI reattiva.
- Non rende Felix avatar o guida.
- Non trasforma i Gufi in interfaccia primaria.
- Non sostituisce i canon; se una feature cambia regole, flow, UI contract o lore canonica, aggiorna il canon owner pertinente.

## Formula obbligatoria

Ogni nuova azione visibile deve dichiarare:

```text
intento -> oggetto -> gesto -> feedback -> registrazione
```

Definizioni:

- `intento`: cosa vuole fare il soggetto, non cosa clicca il player.
- `oggetto`: superficie fisica o amministrativa credibile nel mondo.
- `gesto`: atto breve, leggibile e ripetibile.
- `feedback`: risposta visiva/audio/UI che conferma l'atto.
- `registrazione`: cosa il Registro puo' annotare senza diventare narratore.

Se un comando non puo' compilare questa formula, non e' pronto per entrare come feature player-facing.

## Principi

- Oggetto prima del pulsante: non progettare "un bottone per X", progettare "l'oggetto con cui il soggetto compie X".
- Il gesto deve essere piccolo: firma, colpo, incisione, apertura, chiusura, presa, consegna.
- Il Registro annota atti, non intenzioni. La UI deve far vedere l'atto accettato.
- Gli oggetti non sono decorazione: devono portare stato, rischio, scelta o memoria.
- Le label restano ammesse per leggibilita', ma non devono essere l'unica cosa che rende comprensibile l'azione.
- Nessun oggetto deve promettere sistemi non presenti.
- A 1280x720 la leggibilita' vince sul feticismo diegetico.

## Loop object map

| Segmento | Intento | Oggetto | Gesto | Feedback | Registrazione | Stato v0.5 |
| --- | --- | --- | --- | --- | --- | --- |
| Menu / nuova run | Entrare nel percorso | Soglia o porta dell'arena | Oltrepassare / aprire | Luce, pietra, audio di ingresso | Accesso aperto | Parziale: ancora molto CTA |
| Registro chiuso | Consultare le offerte | Tavola del Registro | Aprire la tavola | Pagina/pietra che si scopre | Offerte esposte | Buono |
| Scelta bet | Indicare una promessa | Tavola contrattuale | Porre un segno sull'offerta | Evidenza su pagina scelta | Promessa selezionata | Buono, da tenere leggibile |
| Firma bet | Vincolarsi | Stilo, cera, sangue o sigillo | Incidere / premere | Colpo secco, sigillo, pulse | Patto firmato | Buono |
| Patto sigillato | Riconoscere il vincolo | Tavoletta sigillata | Attendere / osservare | Cera chiusa, testo breve | Patto convalidato | Parziale |
| Scelta intermedia | Esporsi alla gradinata | Mano, gettone, sabbia, tessera | Mostrare / lasciare cadere | Reazione della folla, pressione | Gesto accettato | Parziale |
| Rito di giudizio | Forzare il responso | Sigillo su pietra | Colpire tre volte | Impatto, crepa, riverbero | Giudizio pesato | Buono ma migliorabile |
| Incassa | Chiudere cio' che e' dovuto | Borsa, quietanza, corda contabile | Prendere / marcare ricevuta | Suono secco, chiusura registro | Percorso chiuso | Debole: oggi e' soprattutto bottone |
| Accetta condanna | Subire l'iscrizione | Marchio, catena, timbro avverso | Esporre il segno / accettare il timbro | Bruciatura, colpo grave | Condanna iscritta | Debole: priorita' futura |
| Rilancia | Rifiutare la chiusura | Seconda incisione o nuovo sigillo | Premere ancora | Pressione, eco, cera che si riapre | Continuita' firmata | Debole: priorita' futura |
| END_RUN | Archiviare il percorso | Fascicolo | Chiudere o aggiornare | Timbro finale, fascicolo riposto | Fascicolo chiuso/aggiornato | Parziale |
| Restart / next / menu | Scegliere uscita operativa | Nuova tavola, prossima pagina, porta | Prendere / voltare / uscire | Stato route chiaro | Nuovo percorso o ritorno | Parziale |

## Micro-audit v0.5

Gia' object-first:

- Registro, firma bet e sigillo hanno una metafora fisica forte.
- Il rito di giudizio ha un gesto semplice e coerente: colpire il sigillo.
- Il fascicolo finale e' coerente con la grammatica amministrativa.

Ancora troppo astratto:

- Menu e route finali comunicano funzione piu' che oggetto.
- Push-your-luck e' leggibile, ma `INCASSA`, `ACCETTA CONDANNA` e `RADDOPPIA` sono ancora percepiti come pulsanti di scelta.
- Scelta intermedia puo' diventare piu' forte se il gesto davanti alla gradinata viene associato a un oggetto o una postura chiara.

Prossima patch UI consigliata dopo QA lock:

- Push-your-luck object pass.
- Tenere gli stessi tre intenti e gli stessi segnali.
- Presentare le tre scelte come tre oggetti comparabili: quietanza, marchio, seconda incisione.
- Aggiungere feedback minimo su selezione/attivazione senza cambiare flow.

## Checklist per nuove feature

Prima di implementare una feature player-facing, compilare:

```text
Intento del soggetto:
Oggetto usato:
Gesto compiuto:
Feedback visivo:
Feedback audio:
Feedback UI/testuale:
Frase registrabile dal Registro:
Segnale GameEvents esistente o nuovo:
Owner dati/flow:
Schermata QA richiesta:
```

Regole:

- Preferire segnali esistenti quando la feature e' presentazionale.
- Se serve un nuovo segnale, aggiornare contract statici e test.
- Se cambia una regola di gioco, aggiornare `docs/canon/MECHANICS_UNIFIED.md`.
- Se cambia il flow, aggiornare `docs/canon/RUN_ARCHITECTURE_CANON.md`.
- Se cambia il contratto UI, aggiornare `docs/canon/UI_CANON.md`.
- Se cambia solo presentazione/copy, aggiornare `docs/layout_rules.md` o `docs/content_bible.md`.

## Stop conditions

Fermare la progettazione se:

- L'oggetto e' solo decorazione e non aiuta a capire stato o conseguenza.
- Il gesto sembra una nuova meccanica ma non ha ownership documentata.
- La UI diventa meno leggibile per essere piu' diegetica.
- Il Registro viene umanizzato o trasformato in tutorial.
- Felix diventa una guida, un obiettivo o una presenza da imitare.
