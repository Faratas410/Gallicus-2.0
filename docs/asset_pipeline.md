# Gallicus Asset Pipeline

## Principio

Nel runtime entrano solo asset con ruolo, path, licenza e verifica definiti.
Concept art e riferimenti restano fuori dalle cartelle runtime.

Ogni asset gameplay deve sostenere un oggetto, un gesto, uno stato o un luogo.

## Struttura

- `assets/backgrounds/` - luoghi e variazioni arena.
- `assets/MainMenu/` - soglia e atmosfera del menu.
- `assets/ui/official/` - risorse adottate e runtime-ready.
- `assets/ui/official_source/` - sorgenti tracciate.
- `assets/ui/third_party/` - pacchetti con provenienza documentata.
- `assets/audio/` - musica e ambience.
- `assets/audio/sfx/` - effetti brevi.
- `assets/i18n/` - cataloghi di traduzione.

## Scheda asset

Prima della produzione dichiarare:

```text
Nome:
Famiglia:
Oggetto/luogo:
Uso runtime:
Stati richiesti:
Risoluzione/durata:
Trasparenza/loop:
Path destinazione:
Fonte o licenza:
Scene consumer:
Verifica richiesta:
```

## Visual

- Preferire asset esistenti se rispettano art direction e funzione.
- Generare immagini solo per gap runtime chiari.
- PNG per raster UI e layer.
- Nessun testo baked salvo marchi puramente simbolici.
- Gli stati interattivi devono condividere geometria.
- Background e overlay restano separati quando devono animarsi.
- Asset generati richiedono ispezione a risoluzione nativa.

## Audio

Seguire `docs/audio_direction.md`.

- WAV per SFX brevi.
- Loop verificati senza click.
- Volume coerente nella famiglia.
- Naming basato sul gesto o oggetto, non su sistemi action assenti.
- Asset temporanei devono essere marcati come tali e sostituiti prima del lock.

## Naming

- snake_case per nuovi file;
- prefisso di famiglia quando utile;
- suffix di stato: `_normal`, `_hover`, `_pressed`, `_disabled`, `_sealed`;
- niente nomi generici come `final2`, `new`, `temp`;
- non rinominare path referenziati senza migrazione atomica.

## Import

- Impostazioni Godot coerenti con il tipo di asset.
- Texture UI nitide e senza filtering incompatibile con lo stile.
- Nessun sidecar mancante dopo import.
- Materiali e shader hanno fallback leggibile.
- La scena non dipende da path assoluti.

## Provenienza

- Ogni pacchetto third-party conserva README/licenza.
- Nessun asset copyrighted senza diritto d'uso.
- Crediti e obblighi confluiscono nel pacchetto release.
- Asset non attribuibile non puo' entrare nella build finale.

## Audit verso 1.0

Classificare gli asset attuali come:

- `KEEP`: coerente e finalizzabile;
- `REWORK`: funzione corretta, resa insufficiente;
- `REPLACE`: fuori grammatica o fuori mood;
- `REMOVE`: non usato o relativo a sistemi assenti.

Priorita' di audit:

1. oggetti push-your-luck;
2. Registro e rituali;
3. fascicolo finale;
4. soglia/menu;
5. variazioni delle Ere;
6. audio con naming o mood action/combat.

## Verifica

```powershell
python tools/ci/verify_res_paths.py
```

Se cambia un asset runtime:

- import Godot;
- smoke pertinente;
- screenshot o ascolto manuale;
- controllo path mancanti;
- controllo licenza;
- aggiornamento del documento di dominio.
