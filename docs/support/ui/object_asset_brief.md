# Object Asset Brief

Status: active supporting brief
Purpose: define the first object-first asset families required by the roadmap.

## Regole comuni

- Testo renderizzato da Godot.
- Materiali coerenti con `docs/art_direction.md`.
- Stati con geometria stabile.
- Safe area sufficiente per IT/EN/ES.
- Nessun watermark, arma, teschio o decorazione non funzionale.
- PNG trasparente per oggetti; background separati.

## Quietanza

Uso: route cashout.

- Foglio o tavoletta contabile con corda/segno di chiusura.
- Stati: normal, focus, taken, disabled.
- Il gesto e' prendere o marcare la quietanza.
- Deve comunicare chiusura prudente, non premio ricco.

### Scheda OF-01

```text
Intento del soggetto: chiudere il percorso e prendere quanto registrato.
Oggetto: quietanza contabile con legaccio e sigillo di chiusura.
Materiale: carta sporca, bronzo pallido, corda scura.
Gesto: prendere la quietanza e tirare il legaccio.
Stato prima: importo e conseguenza leggibili; quietanza disponibile o bloccata.
Stato dopo: quietanza ritirata, legaccio chiuso, fascicolo pronto.
Feedback visivo: breve presa verticale e chiusura del legaccio.
Feedback audio: carta asciutta seguita da un colpo breve di bronzo.
Feedback testuale: valore incassato e corruzione rimossa.
Registrazione prodotta: run end reason CASH_OUT.
Owner dati/flow: RunManager.
Segnale GameEvents: request_pyl_cashout, invariato.
Fallback accessibile: focus netto; stato registered immediato senza movimento.
Schermata o scenario QA: Phase_PUSH_YOUR_LUCK e ROUTE_CASHOUT.
```

Asset previsto:

- sorgente trasparente senza testo, rapporto `5:2`;
- safe area centrale libera per copy renderizzato da Godot;
- stati con geometria identica: normal, focus, taken, disabled;
- destinazione `assets/ui/official/objects/receipt/`;
- texture condivisa:
  `registry_receipt_base.png`;
- risorse:
  `sb_registry_receipt_normal.tres`,
  `sb_registry_receipt_focus.tres`,
  `sb_registry_receipt_pressed.tres` e
  `sb_registry_receipt_disabled.tres`;
- provenienza visuale: generazione originale built-in su chroma-key e
  rimozione locale dello sfondo; nessuna fonte third-party;
- cue originale procedurale:
  `res://assets/audio/sfx/registry_receipt_take.wav`;
- consumer:
  `Btn_PUSH_YOUR_LUCK_CASHOUT` dentro `res://scenes/UI.tscn`;
- nessuna modifica a payout, eleggibilita', payload o transizione;
- lo stato taken e' immediato e non richiede movimento;
- reduced motion riceve la stessa informazione tramite stato, contrasto, copy
  e cue.

Accettazione OF-01:

- oggetto riconoscibile senza leggere la label;
- valore e conseguenza restano leggibili in IT/EN/ES;
- disabled mostra la causa gia' fornita dal payload;
- mouse, tastiera e focus emettono lo stesso intento;
- screenshot viewport-only a 1280x720 e 1920x1080;
- `ROUTE_CASHOUT` e ritual-loop contract verdi.

## Marchio

Uso: route condanna.

- Timbro, ferro o sigillo avverso.
- Stati: normal, focus, heated, registered.
- Il gesto e' esporre la superficie e ricevere l'impronta.
- Nessun gore esplicito.

### Scheda OF-02

```text
Intento del soggetto: accettare il costo e chiudere il percorso senza premio.
Oggetto: ferro-timbro amministrativo di condanna.
Materiale: ferro annerito, bordo consumato, calore rosso smorzato, rivetti di bronzo.
Gesto: ricevere il marchio.
Conseguenza leggibile prima del gesto: perdita della posta e chiusura del percorso.
Stato prima: marchio disponibile, focus o bloccato senza sembrare gia' registrato.
Stato dopo: marchio registrato e oggetto spento dal lock esistente.
Feedback visivo: ferro caldo/registered immediato, senza movimento obbligatorio.
Feedback audio: colpo basso di ferro con coda termica smorzata.
Feedback testuale: perdita della posta e Registro chiuso.
Registrazione prodotta: route condanna invariata.
Owner dati/flow: RunManager.
Segnale GameEvents: request_pyl_condanna, invariato.
Fallback accessibile: focus netto; stato registered immediato senza movimento.
Schermata o scenario QA: Phase_PUSH_YOUR_LUCK e ROUTE_CONDANNA.
```

Asset previsto:

- sorgente trasparente senza testo, rapporto `5:2`;
- safe area centrale libera per copy renderizzato da Godot;
- stati con geometria identica: normal, focus, heated/pressed, registered,
  disabled;
- destinazione `assets/ui/official/objects/condemnation_mark/`;
- texture condivisa:
  `registry_condemnation_mark_base.png`;
- risorse:
  `sb_registry_condemnation_mark_normal.tres`,
  `sb_registry_condemnation_mark_focus.tres`,
  `sb_registry_condemnation_mark_pressed.tres`,
  `sb_registry_condemnation_mark_registered.tres` e
  `sb_registry_condemnation_mark_disabled.tres`;
- provenienza visuale: generazione originale built-in su chroma-key e
  rimozione locale dello sfondo; nessuna fonte third-party;
- cue originale procedurale:
  `res://assets/audio/sfx/registry_condemnation_mark.wav`;
- consumer:
  `Btn_PUSH_YOUR_LUCK_CONDANNA` dentro `res://scenes/UI.tscn`;
- nessuna modifica a reward, eleggibilita', payload o transizione;
- lo stato registered e' immediato e non richiede movimento;
- reduced motion riceve la stessa informazione tramite stato, contrasto, copy
  e cue.

Accettazione OF-02:

- oggetto riconoscibile senza leggere la label;
- costo e conseguenza restano leggibili in IT/EN/ES;
- disabled non sembra una condanna gia' scelta;
- mouse, tastiera e focus emettono lo stesso intento;
- screenshot viewport-only a 1280x720 e 1920x1080;
- `ROUTE_CONDANNA` e ritual-loop contract verdi.

## Seconda incisione

Uso: route double.

- Tavoletta gia' firmata con spazio per una seconda linea.
- Stati: normal, focus, pressed/incised, sealed, disabled.
- Il gesto e' incidere nuovamente.
- Deve mostrare pressione e continuita', non un generico moltiplicatore.

### Scheda OF-03

```text
Intento del soggetto: rifiutare la chiusura e aumentare la posta registrata.
Oggetto: tavoletta di cera gia' firmata con una seconda linea di incisione.
Materiale: basalto, bronzo pallido, cera rossa compressa.
Gesto: incidere nuovamente e sigillare la continuita'.
Conseguenza leggibile prima del gesto: prossima posta e Pressione +1 dal payload.
Stato prima: prima incisione presente; seconda incisione disponibile, in focus o bloccata.
Stato dopo: seconda incisione sigillata e oggetto spento dal lock esistente.
Feedback visivo: incisione calda e stato sealed immediato, senza movimento obbligatorio.
Feedback audio: graffio asciutto nella cera seguito da un breve colpo di bronzo.
Feedback testuale: RADDOPPIA con prossima posta e incremento di pressione.
Registrazione prodotta: rilancio invariato.
Owner dati/flow: RunManager.
Segnale GameEvents: request_pyl_double, invariato.
Fallback accessibile: focus netto; stato sealed immediato senza movimento.
Schermata o scenario QA: Phase_PUSH_YOUR_LUCK e ROUTE_DOUBLE.
```

Asset previsto:

- sorgente trasparente senza testo, rapporto `5:2`;
- safe area centrale libera per copy renderizzato da Godot;
- stati con geometria identica: normal, focus, pressed/incised, sealed,
  disabled;
- destinazione `assets/ui/official/objects/second_incision/`;
- texture condivisa:
  `registry_second_incision_sealed.png`;
- risorse:
  `sb_registry_second_incision_normal.tres`,
  `sb_registry_second_incision_focus.tres`,
  `sb_registry_second_incision_pressed.tres`,
  `sb_registry_second_incision_sealed.tres` e
  `sb_registry_second_incision_disabled.tres`;
- provenienza visuale: generazione originale built-in su chroma-key con
  quietanza e marchio come riferimenti stilistici, seguita da rimozione
  locale dello sfondo; nessuna fonte third-party;
- cue originale procedurale:
  `res://assets/audio/sfx/registry_second_incision.wav`;
- consumer:
  `Btn_PUSH_YOUR_LUCK_DOUBLE` dentro `res://scenes/UI.tscn`;
- CTA canonica `RADDOPPIA`, con traduzioni `DOUBLE` e `DOBLA`;
- nessuna modifica a reward, eleggibilita', payload o transizione;
- lo stato sealed e' immediato e non richiede movimento;
- reduced motion riceve la stessa informazione tramite stato, contrasto, copy
  e cue.

Accettazione OF-03:

- oggetto riconoscibile senza leggere la label;
- prossima posta e Pressione +1 restano leggibili in IT/EN/ES;
- disabled non sembra una seconda incisione gia' sigillata;
- mouse, tastiera e focus emettono lo stesso intento;
- screenshot viewport-only a 1280x720 e 1920x1080;
- `ROUTE_DOUBLE` e ritual-loop contract verdi.

## Pietra del giudizio

Uso: resolve ritual.

- Pietra o sigillo centrale con tre stati di impatto.
- Stati: intact, strike_1, strike_2, resolved.
- Crepe leggibili ma controllate.
- Il testo istruttivo resta su una superficie associata.

## Fascicolo

Uso: END_RUN.

- Dossier con timbro e sezioni per patto, condanna e verdetto.
- Stati: open, updated, closed.
- Route successive devono apparire come nuova tavola, pagina o uscita.

## Soglia

Uso: menu e inizio campagna.

- Porta o limite dell'arena leggibile nel primo viewport.
- Nessun pannello marketing.
- Il gesto e' entrare.
- Il brand Gallicus resta evidente.

## Verifica

Ogni famiglia richiede:

- brief compilato;
- path e licenza;
- import Godot;
- scene consumer;
- screenshot viewport-only;
- test focus, disabled e reduced motion.
