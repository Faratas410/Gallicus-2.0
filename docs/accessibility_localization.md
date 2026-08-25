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
- In CP-02 `ui_accept`, `ui_cancel` e la navigazione focus nativa coprono menu,
  Registro, firma, patto, gesto, sigillo, Push Your Luck e linguette finali.
- `Escape` chiude soltanto Opzioni, Crediti e Archivio. Una superficie rituale
  aperta non viene chiusa e non emette intenti in risposta a `Escape`.
- Ordine Opzioni: lingua, risoluzione, fullscreen, reduced motion, luminosita',
  Master, Music, SFX, indietro.

## Visuale

- Baseline a 1280x720 e 1920x1080.
- Contrasto sufficiente per testo e stato.
- Nessuna informazione affidata al solo colore.
- Icona, forma o testo accompagnano gli stati critici.
- Reduced motion preserva feedback e durata di lettura.
- Flash ripetuti e flicker non sono ammessi.
- Con Reduced Motion attivo drift, fog, bandiera, fiamme, bob, pulse, flicker,
  shake, scale, traslazioni e scrittura progressiva si fermano. Restano cambi di
  stato e dissolvenze non superiori a 0,08 secondi, senza rimuovere copy, focus,
  selezione o conseguenza.
- La modalita' standard conserva soltanto ambience lenta e a bassa ampiezza;
  non usa componenti stroboscopiche rapide o ad alto contrasto.

## Audio

- Slider persistenti per Master, Music e SFX.
- Le azioni critiche hanno anche feedback visuale/testuale.
- Nessuna informazione di gameplay e' audio-only.
- Picchi e transizioni rispettano un volume coerente.
- Il bus runtime `SFX` e' figlio di `Master`; lo slider SFX agisce sul bus senza
  alterare i dB specifici dei singoli cue.

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
- Il fascicolo OF-10 conserva pannello `1120x640` e linguette `304x64`;
  open/updated/closed, focus, selected e disabled restano distinguibili senza
  scala. Titolo, esito, pressione, patti, condanne, ultima voce e route sono
  localizzati in IT/EN/ES al confine UI.

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
