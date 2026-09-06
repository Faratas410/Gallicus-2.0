# Gallicus Asset Pipeline

## Principio

Nel runtime entrano solo asset con ruolo, path, licenza e verifica definiti.
Concept art e riferimenti restano fuori dalle cartelle runtime.

Ogni asset gameplay deve sostenere un oggetto, un gesto, uno stato o un luogo.

## Struttura

- `assets/ui/generated/` - tutti i raster attivi originali e manifest.
- `assets/backgrounds/` - sorgenti precedenti ritirate.
- `assets/MainMenu/` - sorgenti precedenti ritirate.
- `assets/ui/official/` - risorse adottate e runtime-ready.
- `assets/ui/official_source/` - sorgenti storiche escluse dall'export.
- `assets/ui/third_party/` - pacchetti storici esclusi dall'export.
- `assets/audio/` - musica e ambience.
- `assets/audio/sfx/` - effetti brevi.
- `assets/i18n/` - cataloghi di traduzione.
- `docs/support/media_vertical_slice/` - concept, layer e audio di revisione
  non importati dal runtime durante la preparazione del gate MV.

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

Gli StyleBox OF-01..10 restano in `assets/ui/official/objects/` e puntano
soltanto ai raster originali. Sono immagini rettangolari RGB a campo pieno:
margini texture zero, safe area del testo e geometria costanti tra stati.
La vecchia regola alpha non si applica alla nuova famiglia. Focus, pressione,
selezione e registrazione restano stati nativi Godot.

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

## Adozione ImageGen del 4 settembre 2026

`assets/ui/generated/manifest.json` registra nome, prompt, tool, data e fonte
per 15 immagini originali, copiate senza ritocco. PNG e sidecar sono versionati.
I vecchi file restano consultabili come sorgenti storiche ma sono esclusi
dall'export, inclusi `assets/ui/lapidary/` e i vecchi PNG sotto
`assets/ui/official/`. Il controllo del pacchetto verifica anche i `.ctex`
importati: nessun vecchio raster deve essere incluso. I WAV restano.
ImageGen non sostituisce audio o font: il testo usa il font incorporato di
Godot tramite `assets/ui/fonts/engine_sans.tres`. Attribuzioni audio sospese
su richiesta dell'utente; il gate licenze release rimane aperto.

Il menu aggiunge `assets/ui/generated/gallicus_wordmark.png`, sedicesimo PNG
originale. La trasparenza generata e' conservata senza ritocchi; prompt e
provenienza sono nel medesimo manifest. Il marchio GALLICUS e' invariabile,
mentre ogni testo informativo/interattivo continua a essere Godot nativo.

## Asset audiovisivi originali del 6 settembre 2026

Il manifest immagini contiene ora 17 raster: il nuovo `ritual_dust` RGBA
rimane integro a 1254x1254; l'import Godot usa `process/size_limit=256` per
l'uso VFX. Si anima la texture nel motore, senza generare ogni frame.

La raccolta audio e' ricostruibile con `python tools/generate_original_audio.py`
in un ambiente NumPy. Cinque WAV musicali e il battito sono in
`assets/audio/original/`; i 25 SFX sostituiscono i WAV negli stessi path per
preservare i contratti. Il manifest originale registra tutti i 31 output.
La CI controlla i file consegnati con sola libreria standard, senza installare
NumPy o rigenerare audio. Budget source audio: meno di 24 MiB.

Gli MP3 precedenti sono esclusi dal preset. Il controllo pack carica anche
31 stream originali e rifiuta MP3 residui. Produzione originale e rimozione
delle dipendenze audio precedenti non sostituiscono il completamento dei
nomi da accreditare o il controllo finale di provenienza del pacchetto.
