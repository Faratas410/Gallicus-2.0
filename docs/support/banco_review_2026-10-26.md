# Banco: correzione dei sette commenti visivi

Seguito della revisione utente sulla cattura banco_20_it_1280 del pacchetto
Banco/posta. Candidato locale main, HEAD b81a4fc00797be0b0f0b7dd68639e309f3db061c,
con modifiche pregresse preservate, senza commit.

## Risposta ai commenti

1. Bando: un solo sigillo di cera con gufo impresso. Nessuna medaglia aggiunta.
2. Servizi: carta senza stemmi incorporati; bordi in nine-slice, centro
   estensibile. Il sigillo del bando e indipendente e conserva l'aspect ratio.
3. Dorso: cuoio continuo e nervature discrete al posto degli anelli dorati.
   L'atlante originale continua a fornire la penna e i piccoli bordi durante
   la rotazione; cambia solo la faccia della copertina.
4. Testi: centrati sulla parte chiara, con margini laterali del 10 percento
   e verticali del 17 percento. Prezzi ed effetti restano completi IT/EN/ES.
5. Banco di Vessa: cartiglio dedicato e scrittura scura, allineata al centro;
   nessun testo informativo sospeso sul pubblico.
6. Titolo: Fondamento rasterizzato senza antialiasing e pigmento oro irregolare.
7. Apri il Registro: stesso trattamento locale sulla copertina, testo nativo.

La grana del lettering e statica e leggera; nessuno spostamento dei glifi.
Corpi sulla carta, HUD, altre fasi e font globali non sono stati sostituiti.
Acquisti, disponibilita, eventi, salvataggi e flow restano dei rispettivi owner.

## File del seguito

Nuovi:

- `assets/ui/generated/banco_paper_v2.png`, `registry_volume_sprites_v2.png`,
  `bando_single_seal.png` e relativi import.
- `scripts/ui/banco_paper.gd`, `registry_lettering.gd`,
  `registry_cover_action.gd` e relativi uid.
- `assets/ui/official/registry_imprint.gdshader` e uid; questo report.

Modificati:

- `scripts/ui/betting_circle_ui.gd`, `banco_receipt.gd`, `registry_volume.gd`.
- `tools/pixel_banco_capture.gd`: evidenze in artifacts/banco_review/final.
- `tools/registry_volume_capture.gd`: argomento capture-dir per conservare
  le evidenze precedenti durante le revisioni.
- `assets/ui/generated/manifest.json`: source, prompt completi, alpha e hash
  dei tre asset prodotti con il tool ImageGen integrato. Originali preservati.
- `docs/README.md`, `docs/art_direction.md`, `docs/layout_rules.md`,
  `docs/testing.md`, `docs/development_plan.md`.

## Evidenze e verifica

[Confronto con la versione commentata](../../artifacts/banco_review/index.html).
Il confronto usa screenshot nativi, non mockup. Impronte del candidato e
dei PNG in artifacts/banco_review/candidate.json; artefatti ignorati da Git.

- Banco: 18 catture IT/EN/ES a 720p/1080p, saldi negativo/zero/disponibile,
  zero fallimenti; geometrie, testo e click nativo con un solo intento.
- Registro: 760 controlli e 32 catture, zero fallimenti; apertura, firme,
  blocco durante la rotazione, tastiera, movimento ridotto e termini completi.
  Ispezionati Banco IT/ES e rotazione della copertina.
- OF-05 e OF-06, KEYBOARD_FULL_RUN e art uniformity (253 controlli) superati.
- Riferimenti documentali, mojibake e diff check puliti.

Il runner Registro mantiene il warning ObjectDB instances leaked at exit.
Non viene dichiarata risolta la pulizia al termine del processo. Linux canonico,
controller fisico, accettazione artistica e playtest umano restano distinti.
