# Incasso/Rilancio: revisione dei cinque commenti visivi

Candidato locale su main, con modifiche pregresse preservate. Nessun commit,
push o modifica a economia, eventi, salvataggi e autorita del RunManager.

## Correzioni

1. Fondale dedicato senza il giudice specchiato a destra; resta quello a sinistra.
2. Vessa e il banco sono un unico sprite: ali e vassoio appoggiati sul piano,
   pannello frontale completo, base sul parapetto della scena.
3. Comando e conseguenze del rilancio sono scritti sul cartiglio accanto alla
   cera. Il sigillo conserva forma e seconda incisione, senza testo sul bordo.
4. Quietanza su carta nine-slice, massimo 360 x 180 px alla base 720p;
   contenuto centrato nella zona chiara. Lo stato incassato riserva spazio
   al timbro sotto le conseguenze complete.
5. Importo in Fondamento a 42 px, con adattamento per numeri lunghi, al posto
   della cifra sovradimensionata. Titolo sull'insegna con pigmento irregolare;
   scrittura nativa sulla carta coerente con il Registro.

La modifica riguarda questa fase. Gli asset precedenti restano disponibili.
I target rettangolari nativi restano fermi durante focus, click e animazione;
testo e skin sono passivi, senza duplicare gli intenti.

## File del seguito

- `scripts/ui/manifesto_verdict.gd`: composizione, carta, ritratto e lettering.
- `scripts/ui/verdict_object.gd`: carta e sigillo separati, timbro compatto.
- `scripts/ui/verdict_atmosphere.gd`: fondale dedicato.
- `scripts/ui/ritual_environment.gd`: nuovo fondale nel gruppo di continuita.
- `tools/living_verdict_capture.gd`: controllo dei margini del supporto reale,
  oltre a clipping, viewport e comportamento nativo gia coperti.
- `assets/ui/generated/verdict_arena_v2.png` e relativo import (1619 x 971).
- `assets/ui/generated/vessa_counter_pixel.png` e relativo import
  (1774 x 887, RGBA).
- `assets/ui/generated/manifest.json`: prompt completi, riferimenti, origine,
  dimensioni e SHA-256 dei due asset ImageGen.
- Questo report, `docs/README.md`, `docs/art_direction.md`,
  `docs/layout_rules.md`, `docs/testing.md`, `docs/development_plan.md`.

## Evidenze e verifica

[Prima/dopo e stati reali](../../artifacts/verdict_review/index.html).
Screenshot del renderer Godot, non mockup. Il file candidate.json nella stessa
cartella registra HEAD, stato dirty e hash di sorgenti/asset/catture.

- 50 catture IT/EN/ES a 720p e 1080p, zero fallimenti: supporti, testi, focus,
  doppio click nativo, blocchi, tre azioni, importo 123456, quietanza/incisione,
  transizione sincrona, movimento ridotto ed esiti dell'atmosfera.
- Ispezione visiva di scelta, blocchi ES, quietanza registrata e importo lungo.
- OF-01, OF-02, OF-03 superati.
- Art uniformity: 253 controlli, zero fallimenti.
- ROUTE_CASHOUT, ROUTE_DOUBLE, ROUTE_CONDANNA, KEYBOARD_FULL_RUN superati.
- Riferimenti documentali, scansione mojibake e diff check puliti.

Queste sono verifiche locali Windows. Linux canonico, accettazione artistica,
controller fisico e playtest umano restano gate separati; nessuna pubblicazione.
