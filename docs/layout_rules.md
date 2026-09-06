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
  centrate con separazione `14 px`; il sigillo OF-09 usa controllo `360x144`
  (5:2) nel pannello `640x420`. Gli stati conservano queste geometrie.

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

Il fascicolo END_RUN usa un controllo fisso `1120x640`. La safe area interna
mantiene il titolo sotto la cerniera, tre colonne compatte per patti,
condanne e ultima voce, e una riga centrata `940x64`. Le linguette restano
`304x64` anche quando `PROSSIMA SCOMMESSA` non e' disponibile; non si
espandono e non cambiano scala tra focus, selected e disabled.
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

## Geometrie della bonifica

- Menu: marchio largo 740 px, frase senza cornice, soglia da 480x72 px,
  ripresa disponibile solo con save valido e utility in una riga da 480 px.
  Gli avvisi di salvataggio hanno una riga dedicata e wrapping. La colonna
  resta ferma; solo luce del marchio e fondale hanno moto ambientale.
- Registro: tavola 900x540, due blocchi unificati e firma per pagina.
- Push Your Luck: tre oggetti alti 104 px, note da 15 px e spazio riservato
  sotto ciascun comando. Nessuna cornice aggiuntiva nei pannelli testuali.
- Pressione: rail largo 680 px, 16 px sopra il bordo inferiore; tutti i figli,
  inclusa la descrizione della fascia, devono rientrare nel viewport.
- Fascicolo: geometria 1120x640 invariata; nessun pannello scuro dietro
  l'inchiostro, testo chiaro sulle linguette.
- Assenza: nero full viewport sopra HUD, menu e luminosita', senza CTA.

La matrice Opzioni cambia lingua attraverso il selettore reale e ripristina
lingua, risoluzione e reduced motion al termine.

## Presentazione leggera del 6 settembre 2026

Il pass audiovisivo mantiene fermi hit area e focus. La polvere VFX compare
sul bordo dell'oggetto, senza overlay opaco o testo coperto; due sprite al
massimo, invisibili dopo 0,41 s. Il titolo di lettura del Registro e' fermo,
le entrate rituali sono ridotte a 4 px. Movimento ridotto cancella subito i
VFX attivi. Limiti e accettazione in `docs/art_direction.md` e `docs/testing.md`.
