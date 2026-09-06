# Gallicus Art Direction

## Tesi visuale

Gallicus e' un teatro amministrativo romano reso fisico: un'arena severa in
cui pietra, cera, bronzo e fascicoli registrano il comportamento del soggetto.
L'immagine non deve sembrare fantasy generico, horror demoniaco o interfaccia
moderna travestita.

La scena primaria e' l'oggetto rituale. Cornici e decorazioni esistono solo per
stabilire gerarchia, stato o conseguenza.

## Palette

- Base: basalto, pietra grigia, nero caldo, cenere.
- Superfici leggibili: osso spento, calcare, carta sporca.
- Autorita': bronzo ossidato e oro pallido.
- Firma e costo: cera rossa, sangue scuro, ferro.
- Anomalia: verde ossidato o blu ferro, usati con parsimonia.
- Assenza: sottrazione progressiva, non un nuovo colore spettacolare.

Nessuna schermata deve essere dominata da un solo hue. Stato e gerarchia non
possono dipendere soltanto dal colore.

## Materiali

- Pietra intatta: procedura stabile.
- Pietra crepata: struttura sotto pressione.
- Cera liscia: promessa disponibile.
- Cera impressa: consenso registrato.
- Bronzo lucidato: valore riconosciuto.
- Bronzo ossidato: istituzione che persiste ma perde continuita'.
- Carta/fascicolo: memoria accumulata.
- Ferro/catena: vincolo avverso.
- Sabbia: esposizione al pubblico.
- Vuoto: ritiro dell'apparato.

Le texture devono rendere il materiale riconoscibile senza sporcare il testo.

## Oggetti principali

- soglia dell'arena;
- tavola del Registro;
- stilo e sigillo;
- tavoletta del patto;
- tessera o manciata di sabbia per il gesto pubblico;
- pietra del giudizio;
- quietanza;
- marchio o timbro di condanna;
- seconda incisione;
- fascicolo finale;
- armadio/Archivio.

Ogni oggetto ha stati coerenti: integro, disponibile, attivato, registrato,
consumato o assente.

Il fascicolo finale usa carta amministrativa leggibile, dorso di basalto,
cerniere di bronzo e cera rossa controllata. Open e updated conservano carta
chiara e inchiostro scuro; closed introduce una superficie scura e testo
chiaro senza alterare perimetro o safe area. Le linguette restano subordinate
al documento e non diventano card flottanti.

## Composizione

- L'oggetto attivo domina il centro funzionale della schermata.
- Arena e gradinata restano leggibili come luogo, non come wallpaper.
- Il testo vive su superfici fisiche con contrasto controllato.
- Evitare card flottanti annidate e pannelli decorativi senza ruolo.
- Lasciare respiro attorno al gesto principale.
- Il brand Gallicus deve essere evidente nel primo viewport del menu.

## Registro attraverso le Ere

Le Ere non vengono nominate o numerate in UI. Si percepiscono per deriva
materiale e compositiva.

### Era 0 - Intatto

- allineamenti stabili;
- pietra integra e bronzo leggibile;
- segni amministrativi completi;
- luce controllata.

### Era 1 - Rigido

- griglie piu' severe;
- spazi ridotti;
- incisioni piu' profonde;
- minore ambiguita' nel focus.

### Era 2 - Instabile

- asimmetrie localizzate;
- micro-fratture e ossidazione;
- rare interruzioni interpretative;
- nessuna distorsione che comprometta il testo.

### Era 3 - Terminale

- superfici rarefatte;
- commento visivo ridotto;
- oggetti piu' isolati;
- pressione percepita tramite sottrazione.

### Era 4 - Assenza

- nessuna nuova interfaccia del Registro;
- nessun simbolo celebrativo;
- spazio privo di funzione classificatoria;
- nero terminale conforme al canon.

Le transizioni usano una ramp di tre run: nessun cambio visuale istantaneo.

## Background e arena

- I background mostrano il luogo reale e sostengono l'azione.
- Le varianti cambiano luce, materiali, folla e stato del Registro.
- Il centro funzionale resta libero.
- Niente blur permanente dietro contenuto importante.
- Niente immagini atmosferiche generiche che nascondono l'arena.

## Personaggi e presenza

- Il soggetto e' implicito attraverso mani, segni, respiro e punto di vista.
- Felix resta precedente d'archivio e non appare come avatar.
- I Gufi sono apparato e presenza amministrativa, non mascotte o menu.
- La folla si manifesta con massa, suono, ombre e reazione, non con ritratti
  ripetuti che rubano il centro alla scelta.

## VFX e motion

- Firma: cera compressa, breve impulso, particelle minime.
- Colpo: impatto, crepa controllata, polvere e riverbero.
- Quietanza: presa, corda o segno contabile che si chiude.
- Marchio: calore breve, annerimento, impronta persistente.
- Rilancio: incisione aggiuntiva e riapertura della cera.
- Fascicolo: timbro, chiusura e ritiro.
- Silenzio: sottrazione di elementi, non glitch spettacolare.

Motion serve a confermare causa ed effetto. Non deve muovere target cliccabili,
coprire testo o impedire un equivalente reduced-motion.

## Tipografia e simboli

- Testo breve, con gerarchia netta e letter spacing neutro.
- Font decorativo solo per titoli brevi.
- Corpo leggibile anche in inglese e spagnolo.
- Icone come segni amministrativi, non illustrazioni decorative.
- Nessun simbolo privo di ruolo, lore o stato.

## Divieti

- gradienti neon o glossy;
- bokeh, orbs e decorazione astratta;
- parchment fantasy, spellbook e wood UI nelle superfici finali;
- gore esplicito usato come scorciatoia;
- demoni, teschi o armi senza funzione canonica;
- testo gameplay o localizzabile baked nelle immagini runtime; il marchio
  invariabile GALLICUS e' l'unica eccezione di identita';
- asset pack incompatibili mescolati nella stessa schermata;
- effetti RGB/glitch moderni come linguaggio principale.

## Accettazione

- leggibile a 1280x720 e 1920x1080;
- oggetto, gesto e stato identificabili senza copy lunga;
- informazioni non affidate al solo colore;
- asset runtime-ready e con licenza tracciata;
- screenshot viewport-only delle schermate modificate;
- nessun path o texture mancante.

## Famiglia originale adottata nella bonifica

La richiesta del 4 settembre 2026 adotta 15 raster ImageGen originali; manifest
in `assets/ui/generated/manifest.json`. Una camera del Registro collega menu
e rituali; basalto, bronzo, cera rossa e dossier di carta condividono materiali
e luce. Le pagine del Registro usano testo osso su basalto scuro; il fascicolo
aperto conserva inchiostro scuro su carta e linguette scure con testo chiaro.
Corpo 16-18 px, note almeno 15 px, font incorporato di Godot. I pannelli interni
sono vuoti: la superficie esterna basta a definire l'oggetto.

Il menu usa solo il fondale originale con drift lento; torce, bandiere,
nebbie e statue separate sono rimosse. La deriva ambientale e' graduale;
testo e focus mantengono contrasto costante. Messa in scena completa delle
Ere e montaggio finale restano gate audiovisivi, non certificati dalla
campagna accelerata.

## Identita del menu

Il titolo usa `assets/ui/generated/gallicus_wordmark.png`: iscrizione originale
ImageGen in pietra chiara e bronzo, RGBA trasparente, senza pannello di fondo.
Il marchio e' invariabile in IT/EN/ES e ha nome accessibile GALLICUS; le frasi,
i comandi e gli stati restano testo nativo. La famiglia comprende ora 16 PNG.
Il titolo domina la gerarchia; segue una sola riga: "L'arena dimentica. Il
Registro no." La schermata invita all'ingresso senza un riquadro Obiettivo.

## VFX materici del 6 settembre 2026

La texture originale `assets/ui/generated/ritual_dust.png` e' prodotta con
ImageGen: polvere chiara di calcare e minuscoli granelli di bronzo, alpha reale.
Il manifest registra il prompt integrale. Nessun alone magico, flash o fumo
persistente. Il source rimane intatto; Godot limita l'import a 256 px.

`scripts/ui/ritual_feedback.gd` presenta al massimo due sprite da 90-160 px,
per 0,41 s, al bordo inferiore dell'oggetto: scala 0,92-1,06, salita di 5 px,
alpha massima 0,42. Il movimento non sposta target, glyph o focus. Cambi fase,
fine run e attivazione di Movimento ridotto cancellano subito il feedback.
Gli effetti non intercettano input e non usano RNG di gameplay.
