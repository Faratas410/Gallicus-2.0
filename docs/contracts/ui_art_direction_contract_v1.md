# UI Art Direction Contract v1

Status: Active
Scope: Object-first visual and interaction contract for Gallicus 1.0.

## Authority

Questo contratto e' subordinato a `docs/canon/UI_CANON.md`. Non cambia:

- autorita' di `RunManager`;
- segnali `GameEvents`;
- payload;
- routing delle fasi;
- regole di gameplay.

## North Star

La UI e' il Registro reso fisico. Ogni azione gameplay deve apparire come uso
di un oggetto amministrativo o rituale, non come pressione di un comando
astratto.

Formula:

```text
intento -> oggetto -> gesto -> feedback -> registrazione
```

## Contratto delle superfici

1. Il testo e' leggibile prima della decorazione.
2. L'oggetto attivo porta scelta, stato o memoria.
3. Il gesto produce una trasformazione visibile dell'oggetto.
4. La registrazione conferma la conseguenza.
5. La geometria degli stati interattivi resta stabile.
6. Le utility usano controlli convenzionali e accessibili.

## Materiali

- basalto e pietra: autorita';
- cera: consenso e firma;
- bronzo: valore e procedura;
- carta/fascicolo: memoria;
- ferro e marchi: condanna;
- sabbia: esposizione;
- vuoto: Assenza.

## Famiglie runtime

- `arena_threshold`
- `registry_slab`
- `contract_tablet`
- `wax_seal`
- `judgement_stone`
- `receipt`
- `condemnation_mark`
- `second_incision`
- `dossier`
- `archive_fixture`
- `pressure_groove`
- `witness_mark`

Ogni nuova famiglia aggiorna art direction e asset pipeline.

## Stati

Gli oggetti interattivi supportano, quando pertinenti:

- normal;
- hover/focus;
- pressed;
- disabled;
- sealed/registered;
- consumed.

Focus tastiera e hover mouse devono essere equivalenti. Disabled non puo'
sembrare attivo e deve comunicare la causa quando rilevante.

## Ere

- Nessuna superficie mostra il numero o il nome dell'Era.
- La deriva e' graduale lungo tre run.
- Era 2 e 3 possono introdurre asimmetria controllata.
- La leggibilita' non viene degradata.
- Era 4 rimuove le normali superfici classificatorie.

## Asset source

StonePixel resta una fonte utilizzabile per ruoli compatibili, non una lingua
obbligatoria. Un asset viene adottato solo se:

- corrisponde a una famiglia oggetto;
- non introduce wood/parchment fantasy incoerente;
- ha licenza tracciata;
- e' importato e verificato;
- non contiene testo baked.

## Divieti

- card decorative senza oggetto;
- generic fantasy frames;
- bottoni disegnati prima dell'atto;
- testo baked;
- mix incoerente di asset pack;
- simboli ornamentali senza funzione;
- colore come unico stato;
- motion senza fallback reduced-motion.

## Accettazione

- leggibile a 1280x720 e 1920x1080;
- object-first sheet compilata;
- nessun cambio di authority;
- import e path validi;
- screenshot viewport-only;
- focus tastiera verificato;
- stringhe IT/EN/ES controllate;
- nessun mojibake.

## Priorita' di produzione

1. quietanza, marchio e seconda incisione;
2. firma e patto;
3. rito di giudizio;
4. fascicolo finale;
5. soglia/menu;
6. Archivio;
7. variazioni graduali delle Ere.
