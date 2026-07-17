# Gallicus Accessibility And Localization

## Obiettivo

La release deve essere giocabile senza dipendere da precisione motoria,
percezione del solo colore o conoscenza della lingua sorgente.

## Input

- Tutti i menu e gesti devono funzionare con mouse e tastiera.
- Il focus e' sempre visibile.
- L'ordine di focus segue l'ordine di lettura.
- Enter/Space attivano l'elemento focalizzato.
- Escape torna indietro solo quando non perde una decisione irreversibile.
- Nessun gesto richiede drag, timing stretto o click ripetuti per necessita'.

## Visuale

- Baseline a 1280x720 e 1920x1080.
- Contrasto sufficiente per testo e stato.
- Nessuna informazione affidata al solo colore.
- Icona, forma o testo accompagnano gli stati critici.
- Reduced motion preserva feedback e durata di lettura.
- Flash ripetuti e flicker non sono ammessi.

## Audio

- Slider persistenti per Master, Music e SFX.
- Le azioni critiche hanno anche feedback visuale/testuale.
- Nessuna informazione di gameplay e' audio-only.
- Picchi e transizioni rispettano un volume coerente.

## Lingue

Lingue di release:

- italiano;
- inglese;
- spagnolo.

L'italiano e' la sorgente editoriale. Ogni nuova stringa player-facing deve
entrare nel sistema di localizzazione nello stesso blocco che la introduce.

## Regole di traduzione

- Preservare il tono rituale e amministrativo, non la sintassi parola per parola.
- Mantenere brevi i verbi sugli oggetti.
- Non tradurre identificatori, path o chiavi.
- Il Registro resta impersonale in tutte le lingue.
- Le stringhe mancanti non possono ricadere silenziosamente sull'italiano in
  una build di release.
- Glossario e termini canonici devono avere una resa stabile.
- Nei modali object-first la localizzazione copre l'intera superficie visibile:
  titolo, corpo, CTA, effetto e registrazione. Le righe dinamiche ricevute dal
  payload vengono tradotte in UI; EN/ES non possono mostrare fallback italiani.
- Le tessere del gesto conservano focus visibile e target `336x224`; selected e
  disabled restano distinguibili tramite forma, contrasto e copy, senza scala.
- Il sigillo OF-09 conserva target `360x144`; i tre colpi sono leggibili anche
  senza audio o timing perfetto tramite stati strike_1, strike_2 e resolved.

## QA linguistica

Per ogni lingua:

- menu e settings;
- Registro e firma;
- patto;
- gesto pubblico;
- rito;
- tre route push-your-luck;
- fascicolo finale;
- Archivio;
- Silenzio e Assenza;
- crediti e messaggi errore.

Verificare wrapping, font, accenti, apostrofi e assenza di mojibake.

## Gate 1.0

- navigazione completa mouse/tastiera;
- focus visibile in ogni superficie;
- reduced motion funzionante;
- tre bus audio regolabili;
- cataloghi IT/EN/ES completi;
- nessun overflow alle risoluzioni target;
- nessuna informazione critica esclusivamente cromatica o sonora.
