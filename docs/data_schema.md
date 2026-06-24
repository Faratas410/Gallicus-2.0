# Gallicus Data Schema

## Principio

I dati runtime devono essere strutturati, validabili e consumati da owner chiari. Non aggiungere campi se il consumer non e' evidente.

## Cataloghi principali

- `scripts/content/bet_catalog.gd` - identita' bet attive e metadata di presentazione.
- `scripts/content/scar_catalog.gd` - segni/scars e testi effetto.
- `data/arena_themes.gd` - temi arena.
- `data/bets.gd` - dati bet storici o runtime secondo consumer.
- `data/condanne.gd` - condanne.
- `data/ending_rules.gd` - regole finali.
- `data/verdict_lines.gd` - frasi verdetto.

## Campi attesi per bet attiva

- `token` o id stabile.
- `display_title`.
- `display_subtitle`.
- `path_tag`.
- `behavior`.

Il titolo deve essere breve. Il subtitle deve restare leggibile nelle card del Registro.

## Payload UI

Il payload UI deve restare compatibile con `scripts/ui/run_ui_payload.gd` e con i contratti in `docs/contracts/`.

Regole:
- UI non calcola outcome.
- RunManager emette payload canonici.
- Alias legacy non devono rientrare nel livello attivo.

## Save/runtime fields

La shape save/runtime e' governata da `docs/canon/RUN_ARCHITECTURE_CANON.md` e dai contratti in `docs/contracts/`.

Non cambiare:
- phase ids;
- flow step ids;
- scar array shape;
- payload ending senza aggiornare test e canon.

## Validazione

Eseguire:

```powershell
python tools/ci/verify_res_paths.py
python scripts/ci/test_beta_content_contract.py
python scripts/ci/test_playable_slice_contract.py
```

Se cambia una regola dati, aggiungere o aggiornare un test statico.
