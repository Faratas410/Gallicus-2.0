# Gallicus Layout Rules

## Baseline

La UI deve essere funzionale almeno a:

- 1280x720;
- 1920x1080.

Il layout deve tollerare italiano, inglese e spagnolo senza font scalato con la
larghezza viewport.

## Struttura

- L'oggetto attivo occupa il centro funzionale.
- Titolo, conseguenza e gesto appartengono alla stessa superficie.
- Pannelli di pagina non devono sembrare card flottanti.
- Vietate card dentro card.
- Dimensioni e aspect ratio degli oggetti critici sono stabili.
- Hover, focus, label e stato non devono ridimensionare il layout.
- La tavoletta OF-07 usa controllo `320x128` (5:2) nel pannello `660x390`;
  le tessere OF-08 usano controlli `336x224` (3:2) nel pannello `764x430`,
  centrate con separazione `14 px`. Gli stati conservano queste geometrie.

## Gerarchia

Ogni schermata gameplay mostra:

1. cosa e' davanti al soggetto;
2. quale stato porta;
3. quale gesto e' disponibile;
4. quale conseguenza produce;
5. cosa ha registrato il sistema dopo l'atto.

Il testo secondario non deve competere con il gesto principale.

## Schermate

- **Menu:** Gallicus e soglia dell'arena nel primo viewport.
- **Registro:** due offerte confrontabili senza wrapping distruttivo.
- **Firma:** promessa, costo e sigillo sulla stessa tavola.
- **Patto:** vincolo leggibile e corpo non vuoto.
- **Gesto pubblico:** opzioni confrontabili e reazione della folla.
- **Rito:** oggetto centrale, conteggio colpi e responso.
- **Push-your-luck:** quietanza, marchio e incisione chiaramente distinte.
- **END_RUN:** fascicolo, esito, memoria e route disponibili.
- **Archivio:** consultazione, non griglia di achievement generica.
- **Assenza:** nessun residuo del normale HUD.

## Utility

Settings, lingua, volume, risoluzione, back e quit usano controlli familiari:

- slider per valori continui;
- checkbox/toggle per stati binari;
- option menu per insiemi;
- icone note con tooltip;
- focus order prevedibile.

Non forzare metafore diegetiche sulle utility.

## Testo

- Nessuna parola importante si spezza in modo illeggibile.
- Bottoni e oggetti interattivi supportano la stringa piu' lunga prevista.
- Font decorativo solo su titoli brevi.
- Corpo e conseguenze usano font ad alta leggibilita'.
- Non usare letter spacing negativo.
- Informazioni critiche non dipendono dal solo colore o da un'icona.

## Stati

- normal, hover/focus, pressed, disabled e registered devono essere distinti;
- disabled mostra causa quando rilevante;
- un elemento cliccabile non deve sembrare spento;
- focus da tastiera deve essere visibile quanto hover da mouse;
- route finali non possono essere ambigue.

## Motion

- Pulse, flash e transizioni confermano causa/effetto.
- I target cliccabili non si spostano.
- Il testo non viene coperto.
- Reduced motion sostituisce movimento con cambio di stato breve.
- Nessun effetto indispensabile dura solo un frame.

## QA

Una patch visibile richiede:

- screenshot viewport-only alle due risoluzioni;
- almeno una cattura nella lingua con stringa piu' lunga;
- controllo focus tastiera;
- controllo reduced motion se tocca animazioni;
- static test UI pertinenti.
