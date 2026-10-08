# Arena illustrata - campione runtime, 8 ottobre 2026

## Richiesta e risultato

L'utente richiede un gioco visivamente coerente tra ambienti, senza il
realismo e il rumore delle reference spaziali. Questo pass realizza la prova
concordata: una vista stilizzata integrata sotto la UI reale, verificata a
720p e confrontata con Registro, cast e fascicolo prima dell'estensione.

Il nuovo PNG `assets/ui/generated/arena_illustrated_sample.png` e' usato in
giudizio, gesto pubblico e scelta quietanza/raddoppio. L'arco a sinistra e
il vessillo mantengono la geografia della reference; banco e piedistallo
dipinto sono assenti. La gradinata per ora usa la stessa vista, senza nuova
inquadratura dedicata. Le quattro reference non sono integrate nel gioco.

L'immagine usa campiture dipinte, superfici semplificate e una luce ampia.
Un `GradientTexture2D` nativo condiviso scurisce la zona dei testi, senza
alterare il raster o intercettare input. La didascalia alta del giudizio ha
richiesto piu' ombra dopo la prima cattura. Nessun testo e' incorporato nel PNG.

## Coerenza da estendere

| Elemento confrontato | Esito del confronto e lavoro successivo |
| --- | --- |
| Arena | Il campione riduce la micrograna e separa luogo e comandi. L'architettura conserva dettaglio sui gradoni: da valutare in movimento e su display reale. |
| Registro e patto | Restano sul banco precedente, molto piu' realistico. Ridipingere la vista del vestibolo con la stessa mano dell'arena. |
| Cast | Identita' e silhouette restano riconoscibili; piume e bronzo sono piu' minuti e realistici. Semplificare per masse senza cambiare specie, pose o attributi. Nerio e' il confronto diretto del campione. |
| Sigillo del giudizio | Oggetto originale piu' fotografico del nuovo fondale. Ridisegnare la famiglia conservando cera, incavi, stati e geometria interattiva. |
| Quietanza e fascicolo | Gerarchia nativa leggibile, carta ancora ricca di fibre e bordo materico. Allineare il dettaglio; il fondale del fascicolo deve diventare il portico illustrato. |
| Menu e Archivio | Devono entrare nella successiva revisione della sequenza e della stessa famiglia materiale; non ridisegnati da questo campione. |

Il criterio comune e' in `docs/art_direction.md`: stessa costruzione delle
forme, palette, trattamento della luce e densita' di dettaglio; cambia il
luogo, non la mano. Questo pass non dichiara completata la coerenza del gioco.

## Provenienza e riproduzione

Generazione tramite ImageGen integrato; riferimento geografico:
`artifacts/attraversamento_2026-10-08/02_arena.png`. Prompt completo, sorgente
e SHA-256 del PNG sono in `assets/ui/generated/manifest.json` e il prompt
e' anche in `artifacts/arena_stilizzata_2026-10-08/prompt.json`.
Il PNG originale e' copiato senza ritocco esterno. Le reference restano intatte.

Evidenze locali: `artifacts/arena_stilizzata_2026-10-08/`.
`verify.py` offre import, static, smoke e layout. La fixture `layout_capture.gd`
deriva da `tools/counter_layout_capture.gd`, scrive nella nuova cartella e
usa un profilo isolato, renderer Compatibility, audio Dummy e finestra
minimizzata. Gli stati densi sono fixture di presentazione, non una partita
umana completa. Screenshot principali in `layout/`: receipt, judgment,
gesture, signature e dossier, con suffisso lingua e risoluzione.

## Verifiche

Risultati e log sono conservati separatamente per import, suite statica,
KEYBOARD_FULL_RUN e matrice visuale. Import, suite statica e percorso completo
da tastiera terminano con exit 0. Riferimenti documentali, scansione mojibake
del repository e `git diff --check` puliti. La matrice finale ha prodotto 108 PNG
IT/EN/ES a 1280x720 e 1920x1080, senza errori di contenimento o sovrapposizione
rilevati. Ispezione visiva di stati rappresentativi e confronto con Registro,
fascicolo e ritratto Nerio; non un giudizio automatico sulla qualita' artistica.
Un primo processo di cattura rimasto pendente e' stato interrotto; la seconda
esecuzione sul gradiente corretto e' terminata con exit 0 e riepilogo completo.

Restano separati il controllo locale Windows, il checkpoint Linux e
l'accettazione artistica/leggibilita' dell'utente. Nessun export o gate chiuso.

## File di questo pass

- `scenes/UI.tscn`: asset arena su tre fondali e gradiente di lettura comune.
- `assets/ui/generated/arena_illustrated_sample.png` e `.png.import`: asset.
- `assets/ui/generated/manifest.json`: provenienza completa.
- `docs/art_direction.md`: criterio condiviso e stato parziale del campione.
- `docs/canon/UI_CANON.md`, `docs/layout_rules.md`, `docs/asset_pipeline.md`:
  mappatura delle viste e comportamento del livello di lettura.
- `docs/README.md`, `docs/development_plan.md`, `docs/testing.md`: accesso,
  prossimo passo e matrice di verifica.
- `docs/support/illustrated_arena_2026-10-08.md`: questo resoconto.

Lavoro locale su main sopra il candidato gia' modificato. Nessun cambiamento
di questo pass a RunManager, segnali, flusso, salvataggi, testi o ricompense.
Modifiche preesistenti conservate; nessun commit, push o pubblicazione.
