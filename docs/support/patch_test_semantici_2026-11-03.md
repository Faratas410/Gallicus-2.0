# Patch 1 Test del sigillo e del movimento basati sul comportamento

## Consegna locale del 3 novembre 2026

Patch implementata e verificata localmente su `main`, HEAD
`83083b61ed45a60545bd97b245484c163709da7a` piu' il diff non committato.
Le quattro modifiche documentali preparatorie erano gia' presenti e sono
state preservate. Nessun commit o push. Runtime di produzione, scene, asset,
copy e save sono invariati; la [patch 2](patch_offerta_autorevole_2026-11-03.md)
resta da implementare.

Origine: conversazione ChatGPT `6aea202c-4444-83eb-86c4-9bbdd4dff88a`,
"Controllo repository test automatici". La preparazione aveva verificato
working tree pulito e HEAD uguale al riferimento locale origin/main, senza
fetch. Le copie sotto `artifacts/` restano evidenze locali, non sorgenti da
sovrapporre al progetto. Questa consegna non usa i tempi Actions storici come
misura del costo attuale.

## Protezioni riviste

| Controllo precedente | Trattamento e prova sostitutiva |
| --- | --- |
| Sigillo con dimensione letterale 360 x 144 e ID ExtResource esatti | Risoluzione dei binding tramite percorsi; target e contenimento verificati nell'istanza reale alle risoluzioni supportate. Una rinumerazione degli ID e un resize proporzionale passano il controllo statico. |
| `_assert_runtime` che leggeva funzioni con regex | Rimosso: gli input dei Button, i lock e le risposte sono esercitati in Godot. Nessuna lettura del corpo degli helper privati. |
| Frammenti di lock, ordine dei cue e chiamate al bus | Invio immediato singolo con mouse/Invio e ripetizione; cue realmente in playback prima dell'intento; risposte sul bus e percorso con manager collegato. |
| Traduzioni replicate parola per parola | Chiavi uniche, valori presenti, placeholder coerenti. Rimane esatto solo COLPISCI/STRIKE/GOLPEA, esplicitamente specificato nel canon. Il contesto viene verificato dopo il suo evento e nel testo renderizzato. |
| Allowlist dei creatori di tween, easing QUAD, helper e parole nei docs | Rimossi come dettagli interni; prove su geometria, hover/focus, cancellazione degli effetti, Movimento ridotto e azioni immediate della posta. Il canon non cambia. |
| Nomi e istruzioni del capture, seed e cleanup nel sorgente | Rimossi dal contratto dell'oggetto. Percorso reale nella fixture; inventario cumulativo delle PNG ancora protetto da `test_ci_checkpoint_contract.py`. |
| Anchor del Registro | Conservati: guard di una regressione storica della scena esportata, finche' una prova equivalente dell'export non li sostituisce. |
| Manifest, asset, formati/livelli audio e segnali pubblici | Conservati nei controlli statici. Save, contabili e gate cumulativi restano attivi. |

## Copertura runtime e CI

La matrice di `tools/counter_layout_capture.gd` e' condivisa fra QA renderizzata
e il nuovo ingresso headless `scripts/ci/judgment_runtime_contract.gd`.
Comprende dodici combinazioni di IT/EN/ES, 720p/1080p e motion normale/ridotto.
Le risposte iniettate provano presentazione, colpi, arresto, Segno, recovery,
riapertura e geometria. Soltanto in questa parte il ricevitore del manager e'
scollegato. Segue firma -> Patto -> tre scambi -> Rito -> posta col manager
collegato, osservando intento e risposta reali. Non sono dodici campagne.

`art_uniformity_runtime_contract.gd` riusa le prove di cancellazione e canvas
e aggiunge stabilita' del target nel menu e sei casi della posta: tre azioni,
con/senza Movimento ridotto, intento sincrono e lock al secondo invio.
Il runner art esegue entrambi i contratti in profili separati. Il workflow
esistente li richiama nei profili cumulativi lean/full; il planner li include
nei gruppi `betting_ui`, `localization` e `doc_ui`, senza duplicarli quando i
gruppi si combinano. Nessun job nuovo, timeout dei job invariati.

## Verifiche e prove locali

Evidenze in `artifacts/patch1_tests/`; i file sono ignorati da Git.
Usati Python bundled desktop e Godot ufficiale
`4.7.2.stable.official.ed1daf0bf` dal Desktop. I profili di test sono isolati;
il TEMP dei runner e' stato collocato nel workspace per evitare il limite di
accesso della cartella temporanea della sandbox Windows.

- PASS: import completo (`import.log`), senza errori di script o risorse.
- PASS: `test_judgment_seal_object_contract.py` e `test_ui_motion_contract.py`.
- PASS: `run_art_uniformity_contract.py` sul candidato finale
  (`final_behavior.log`): matrice headless e percorso reale, con verifica dei
  cue e del contesto localizzato; nessun errore o warning.
- PASS: matrice renderizzata OpenGL Compatibility su GPU reale, dodici
  combinazioni e percorso nativo (`render.log`, `render/summary.json`): 162
  PNG prodotte. Sei viste rappresentative ispezionate nella contact sheet;
  nomi in `inspected_images.txt`. Le immagini non sono 162 comportamenti
  distinti. Le ultime asserzioni di cue/contesto sono state riprovate in
  headless; non cambiano i pixel delle catture gia' prodotte.
- PASS: `KEYBOARD_FULL_RUN` con profilo temporaneo (`keyboard_summary.json`).
- Prove negative riuscite: risorsa inesistente e chiave EN mancante respinte;
  input del Button scollegato in una fixture usa e getta rilevato con exit 1
  (`static_mutations/results.json`, `negative_input.log`). Nessuna mutazione
  e' stata applicata ai sorgenti di produzione.
- Verifiche finali statiche, planner, checkpoint, i18n, path, docs, encoding e
  candidato sono registrate in `final_checks.json`.

La prima bozza della fixture ha fallito per una chiamata di chiusura errata
e per l'assunzione che la pelle runtime fosse sempre StyleBoxTexture: il
sigillo corrente ha anche un renderer pixel. Corrette entrambe le assunzioni
nel test e ripetute le prove pertinenti; il log fallito `behavior.log` resta
conservato. Non e' una correzione del gameplay.
Anche il primo controllo path ha rilevato il file TSCN volutamente invalido
della prova negativa, incluso nella scansione degli artefatti: conservato
come `UI.negative-fixture.txt` prima di ripetere il controllo. Il log iniziale
resta in `verify_res_paths_before_cleanup.log`.

## File della patch

- `scripts/ci/test_judgment_seal_object_contract.py`
- `scripts/ci/test_ui_motion_contract.py`
- `tools/counter_layout_capture.gd`
- `scripts/ci/judgment_runtime_contract.gd` e relativo UID
- `scripts/ci/art_uniformity_runtime_contract.gd`
- `scripts/ci/run_art_uniformity_contract.py`
- `scripts/ci/contextual_ci.py` e `scripts/ci/test_contextual_ci.py`
- `.github/workflows/godot_smoke_runtime.yml`
- `docs/testing.md`, `docs/development_workflow.md`, `docs/development_plan.md`,
  `docs/README.md` e questa scheda.

## Limiti e prossimo passo

Full playbook, campagna completa, export e Linux NOT_RUN: il pacchetto cambia
test e wiring, senza gameplay/save nuovi. I profili CI mantengono le prove
cumulative; la loro esecuzione sul futuro candidato resta necessaria ai gate.
Input sintetici e smoke non provano focus OS, controller fisico, ritmo o
qualita' del mix. Le sei immagini ispezionate non costituiscono accettazione
artistica: il testo italiano "Pressione +1" in una fixture EN e' un dato
iniettato; nella cattura nativa della posta compare un tooltip sotto il
puntatore. Nessun redesign e' incluso.

Non e' stato misurato un risparmio di tempo o token. La riduzione riguarda i
vincoli sul sorgente; alcune verifiche ora avviano Godot per osservare il
comportamento. Core Playable Candidate, campagna umana cronometrata e gate
Steam rimangono invariati. Il prossimo pacchetto tecnico preparato e' la
patch 2 sull'offerta, senza estenderlo automaticamente a questa consegna.
