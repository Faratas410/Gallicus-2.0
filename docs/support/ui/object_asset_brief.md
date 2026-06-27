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

## Marchio

Uso: route condanna.

- Timbro, ferro o sigillo avverso.
- Stati: normal, focus, heated, registered.
- Il gesto e' esporre la superficie e ricevere l'impronta.
- Nessun gore esplicito.

## Seconda incisione

Uso: route double.

- Tavoletta gia' firmata con spazio per una seconda linea.
- Stati: normal, focus, incised, sealed.
- Il gesto e' incidere nuovamente.
- Deve mostrare pressione e continuita', non un generico moltiplicatore.

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
