# Gallicus Object-First Grammar

## Design Doctrine

Gallicus deve sembrare un ruolo abitato, non un software operato. La direzione
di progetto parte sempre dal mondo e arriva all'interfaccia:

```text
fantasia -> ruolo -> intento -> strumento -> meccanica -> interfaccia
```

In Gallicus il ruolo del giocatore e' il soggetto esposto nell'arena. Gli
strumenti che rendono possibili i suoi atti non devono appartenergli: possono
essere proprieta', concessione o imposizione del Registro.

Ogni azione gameplay ha un oggetto primario riconoscibile. Non e' una
corrispondenza rigidamente uno-a-uno: lo stesso oggetto puo' sostenere gesti e
stati coerenti, e una meccanica puo' coinvolgere superfici di prova o
registrazione secondarie. Deve comunque essere inequivocabile quale oggetto
riceve il gesto principale.

La metafora software deve scomparire; l'affordance no. Focus, disponibilita',
blocco e conseguenza devono restare leggibili anche quando la superficie e'
interamente diegetica.

Ordine di priorita':

1. chiarezza del gameplay;
2. leggibilita';
3. fantasia;
4. decorazione.

Un oggetto in primo piano deve avere funzione gameplay o informativa. Gli
elementi puramente ambientali possono costruire il mondo, ma non competono con
gli oggetti interattivi. Utility, impostazioni e accessibilita' restano
convenzionali quando questo rende il controllo piu' prevedibile.

## Domanda guida

```text
Se fossi davvero il soggetto nell'arena, quale oggetto userei per farlo?
```

La risposta arriva prima di layout, CTA, icone o microcopy.

## Ambito

La grammatica e' obbligatoria per:

- scelte che cambiano la run;
- rituali e conferme narrative;
- consultazione di prove e conseguenze;
- route che aprono, proseguono o chiudono un percorso.

Non e' obbligatoria per utility:

- impostazioni;
- volume, lingua e risoluzione;
- accessibilita';
- back, quit e finestre di sistema.

Queste superfici usano controlli convenzionali e focus prevedibile.

## Formula

```text
intento -> oggetto -> gesto -> feedback -> registrazione
```

- `intento`: cosa vuole fare il soggetto.
- `oggetto`: superficie fisica o amministrativa credibile.
- `gesto`: atto breve e leggibile.
- `feedback`: risposta visiva, audio e testuale.
- `registrazione`: traccia che il Registro puo' conservare.

Se manca uno dei cinque elementi, l'azione non e' pronta.

## Principi

- L'oggetto deve portare stato, rischio, scelta o memoria.
- Il gesto resta piccolo: aprire, firmare, incidere, colpire, prendere, esporre.
- La label chiarisce l'atto, ma non deve essere l'unico indizio.
- Il Registro annota atti; non legge intenzioni e non fa tutorial.
- L'input puo' restare click, tastiera o focus activation.
- La diegesi non giustifica controlli opachi.
- A 1280x720 leggibilita' e accessibilita' prevalgono sulla decorazione.

## Materiali come significato

| Materiale | Significato |
| --- | --- |
| Pietra | autorita', permanenza, procedura |
| Cera | consenso, firma, stato ancora modificabile |
| Bronzo | valore, debito, ufficialita' |
| Carta/fascicolo | memoria, prova, archiviazione |
| Ferro/catena | vincolo e condanna |
| Marchio | conseguenza iscritta sul soggetto |
| Sabbia | esposizione pubblica e transitorieta' |
| Vuoto | cessazione della classificazione |

## Mappa della run

| Momento | Intento | Oggetto | Gesto | Feedback | Registrazione |
| --- | --- | --- | --- | --- | --- |
| Entrata | accettare l'esposizione | soglia dell'arena | oltrepassare | luce, porta, ambiente | accesso aperto |
| Registro | consultare offerte | tavola del Registro | aprire | pietra che si scopre | offerte esposte |
| Bet | indicare una promessa | tavola contrattuale | porre un segno | evidenza e suono secco | promessa selezionata |
| Firma | vincolarsi | stilo, cera, sigillo | incidere/premere | cera, colpo, pulse | patto firmato |
| Patto | riconoscere il vincolo | tavoletta sigillata | osservare/accettare | sigillo chiuso | patto convalidato |
| Gesto | esporsi alla folla | tessera, sabbia o mano | mostrare/lasciare | reazione e pressione | gesto accettato |
| Rito | forzare il responso | sigillo su pietra | colpire | impatto, crepa, riverbero | giudizio pesato |
| Incasso | chiudere il dovuto | quietanza o borsa | prendere/marcare | chiusura netta | percorso chiuso |
| Condanna | accettare il costo | marchio o timbro avverso | esporsi/ricevere | bruciatura e colpo grave | condanna iscritta |
| Rilancio | rifiutare la chiusura | seconda incisione | incidere di nuovo | cera riaperta e pressione | continuita' firmata |
| Finale | archiviare il percorso | fascicolo | chiudere/aggiornare | timbro finale | esito registrato |
| Proseguire | aprire altro rischio | nuova tavola | voltare/prendere | nuovo spazio leggibile | nuovo percorso |
| Assenza | cessare la classificazione | nessun oggetto | nessun gesto | vuoto e battito | nessuna voce |

## Stati di interazione

Ogni oggetto interattivo deve mostrare:

- disponibile;
- focus/hover;
- attivato;
- bloccato con causa;
- consumato o registrato, quando pertinente.

La geometria non deve cambiare tra stati. Motion e luce confermano il gesto,
ma non spostano il target.

## Scheda feature

```text
Intento del soggetto:
Oggetto:
Materiale:
Gesto:
Conseguenza leggibile prima del gesto:
Stato prima:
Stato dopo:
Feedback visivo:
Feedback audio:
Feedback testuale:
Registrazione prodotta:
Owner dati/flow:
Segnale GameEvents:
Fallback accessibile:
Schermata o scenario QA:
```

## Stop conditions

Fermare la progettazione se:

- l'oggetto e' decorazione senza funzione;
- il gesto nasconde la conseguenza;
- la soluzione richiede una nuova meccanica non prevista;
- la UI diventa meno leggibile per sembrare diegetica;
- il Registro diventa personaggio, tutorial o giudice morale;
- Felix viene trasformato in avatar o guida;
- un effetto non ha equivalente con reduced motion.

## Priorita' corrente

Il primo blocco runtime e' push-your-luck:

- incasso come quietanza;
- condanna come marchio;
- rilancio come seconda incisione.

Gli intenti, i segnali e il flow restano invariati.
