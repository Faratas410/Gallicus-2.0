# Gallicus Asset Pipeline

## Principio

Gli asset devono essere runtime-ready. Concept art e riferimenti non devono entrare nei path runtime se non sono usati o verificati.

## Path principali

- `assets/backgrounds/` - fondali runtime.
- `assets/MainMenu/` - menu ambience.
- `assets/ui/` - font, icone, stylebox, materiali e sorgenti UI.
- `assets/audio/` - audio runtime.
- `assets/i18n/` - traduzioni.

## Naming

- Usare nomi descrittivi e stabili.
- Preferire snake_case per nuovi file.
- Non rinominare asset referenziati senza aggiornare scene, script e `res://` validation.

## Visual asset policy

- Usare asset esistenti se bastano al playtest.
- Generare immagini solo se una texture mancante blocca la build o la comprensione.
- Ogni immagine generata deve avere risoluzione, path e uso runtime chiari.
- PNG per raster UI/sprite; materiali Godot per style/runtime effects.

## Audio policy

- SFX brevi, coerenti, senza materiale copyrighted.
- Ogni azione importante deve avere feedback audio o una ragione documentata.
- Placeholder WAV procedurali sono ammessi per beta interna.

## Import e verifica

Se cambia un asset:

```powershell
python tools/ci/verify_res_paths.py
```

Se cambia import Godot, eseguire import headless. Se cambia UI/visual, fare screenshot QA.
