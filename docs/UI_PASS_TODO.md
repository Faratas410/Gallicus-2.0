# UI pass - Gallicus

Stato: da fare (to do). Scritto il 2026-10-09.

## Contesto

Marco ha chiesto il 2026-10-09 di ripetere su tutti i progetti il pass UI fatto su Micelio (Carta e Linfa: menu e bottoni fatti della materia del mondo, un solo accento vivo, movimento di sollevo/pressione, tutto documentato). Questo file e' il "to do" per questo repo: la ricognizione e' fatta, l'implementazione no. Proposta con mockup interattivi: https://claude.ai/artifact/NSSMq7E3po6L6YYtuwRiGq

Decisioni di Marco (2026-10-09): materiale e accento qui sotto approvati; consegna con commit locale (niente push senza nuovo mandato).

## Grammatica comune (uguale in tutti i giochi)

1. **La UI e' fatta del mondo.** Pannelli, inset e bottoni usano un materiale che esiste nel gioco. Niente cruscotto piatto generico, niente ornamento fantasy.
2. **Un solo accento vivo.** Hover e focus da tastiera mostrano lo stesso segno: un tratto sul bordo inferiore del bottone nel colore-accento del gioco, sempre con forma o posizione oltre al colore. L'accento non si usa altrove come decorazione.
3. **Tre livelli di bottone.** Primario pieno (al massimo uno per schermata), secondario nella materia neutra, disattivato piatto e sbiadito senza ombra. Danger solo dove esiste gia'.
4. **Luce in alto a sinistra.** Ombra breve in basso a destra, stessa distanza per elementi della stessa scala. Il contorno segue la regola del gioco.
5. **Cinque stati sempre definiti:** normale, hover, focus, premuto, disattivato. Premuto schiaccia la superficie e abbassa l'etichetta di 2 px (content margin). Nessuno stato ricade sul default Godot.
6. **Nessun controllo di default.** Slider, toggle/CheckButton, freccia OptionButton, scrollbar, tooltip e dialog ridisegnati con la stessa materia.
7. **Testo in tre ruoli:** titolo, corpo, secondario dai token; rispettare le dimensioni minime gia' dichiarate dal repo.
8. **Una sola sorgente.** Token e funzioni nello script tema esistente (o in uno nuovo se manca). API comune: `apply_panel`, `apply_inset`, `apply_primary_button`, `apply_secondary_button`, `apply_slider`, `apply_toggle`, `apply_option_button`, `apply_title` / `apply_body` / `apply_muted`, `animate_panel_in`, `bind_button_motion`. Nessun hex inline nelle UI toccate.
9. **Documentato nello stesso pass:** sezione "Menu e bottoni" nel doc di art direction, voce nel decision log, verifica nel formato del repo.

**Implementazione di default:** StyleBoxFlat (fill, `shadow_offset`, `corner_detail` per gli smussi, accento come `border_width_bottom` nello stile hover/focus) o `_draw` procedurale. Niente PNG generati da script salvo dove indicato sotto.

**Profili di movimento** (sempre disattivati da "riduci movimento"):
- *Pieno* (Micelio): hover scala 1.015 e ombra piu' lunga, premuto 0.985, pulse 1.04 al clic, pannello entra da 0.97 con fade in 0.14-0.18 s; tween con `TWEEN_PAUSE_PROCESS`. Riferimento: `The-Cursor/scripts/ui/signal_ui_theme.gd`.
- *Sobrio*: nessuna scala; l'accento si disegna da sinistra a destra in ~0.12 s; premuto = 2 px o cambio tinta; pannelli solo in dissolvenza.
- *Fermo*: nessuna animazione; stati istantanei.

## Questo gioco: Manifesto del Verdetto, completamento ("Atto a stampa")

**Materiale.** Il sistema esiste gia' (pacchetti 1-3, commit `dc55943` "ui"): documenti in carta avorio con taglio `slab()` irregolare, lastre d'inchiostro, cera solo per esposizione e firma. Si completano i pacchetti 4-7 di `docs/support/manifesto_remaining_screens_2026-10-09.md`: fascicolo/HUD/segni, menu/impostazioni/crediti, Archivio, narrativa/terminale. Primario/continuazione = lastra d'inchiostro con testo avorio; secondario/utilita' = lastra di carta con testo inchiostro; esposizione = cera; disattivato = lerp 16% verso l'inchiostro piu' due barre e motivo scritto. Ombra d'inchiostro corta opzionale, nessun contorno ornamentale.

**Accento.** L'incisione dello stilo: in hover/focus una linea incisa si traccia lungo il bordo inferiore (sinistra -> destra, ~0.12 s, istantanea con riduci movimento) e compare il marchio a tre tagli vuoto. Il marchio pieno solo per "registrato". Equivale al tratto inferiore del canone (hover = linea interna in basso, focus = sottolineatura 4 px).

**Movimento.** Sobrio senza scala: il canone vieta scala e spostamento su hover/focus (CI). Premuto = tinta leggera + contorno interno. L'ingresso pannello rituale esistente (0.99, 0.22 s) resta. Rimuovere `MENU_BUTTON_HOVER_SCALE` 1.02 dal menu principale.

**Token** (da centralizzare):

| Ruolo | Hex |
| --- | --- |
| Inchiostro | `#191917` |
| Avorio | `#e7ddc5` |
| Cera | `#792d26` |
| Muted | `#a39e8f` |
| Da eliminare | oro `#f2d48f` / `#f0d69e` e le ~25 varianti crema in `ui_root.gd` |

## Passi

1. Un pacchetto alla volta, come da piano; ogni nuovo componente entra in `tools/manifesto_kit_gallery.tscn`.
2. `scripts/ui/manifesto_kit.gd`: aggiungere helper per slider (scanalatura incisa, riempimento inchiostro, linguetta avorio/cera), checkbox (quadrato inciso con barra) e freccia OptionButton (chevron inciso), al posto delle manopole di bronzo.
3. Pacchetto 4: fascicolo END_RUN, HUD (PressureRail, CrowdFavor, Bando), ScarsPanel e ScarPopup.
4. Pacchetto 5: menu principale (utility row), impostazioni, crediti; togliere `bronze_plaque` dai campi.
5. Pacchetto 6: Archivio (tab, voci, tooltip).
6. Pacchetto 7: prologo, dialoghi illustrati, terminale ambra, overlay.
7. Risolvere le contraddizioni: tipografia (Libre Baskerville vs RobotoSerif del kit), focus del tema legacy (bordo oro 2 px vs sottolineatura 4 px); rinominare `italiana_regular_font.tres` (e' il sans dell'engine).

## Vincoli

- Nessuno scale/movimento su hover/focus (`test_ui_motion_contract.py`).
- I test di contratto fissano gli ExtResource ID degli stylebox in `UI.tscn`.
- Vietato un tema globale sostitutivo o override ricorsivo su tutte le scene.
- `generated_art_contract.py`: PNG solo in `assets/ui/generated/` con manifest; il disegno procedurale `_draw` lo evita.
- AGENTS.md: lavoro su `main` locale; questo commit e' mandato da Marco.

## Non toccare

RunManager, GameEvents, payload e intent; skin degli oggetti (sigillo, soglia), node path, lock e tempi; Era 4 / Assenza; pacchetti 1-3 gia' consegnati.

## Docs da aggiornare nello stesso pass

`docs/art_direction.md`, `docs/canon/UI_CANON.md`, `docs/layout_rules.md`, `docs/testing.md`, `docs/development_plan.md`; un report di pacchetto in `docs/support/` per ciascun pacchetto. Scansione mojibake obbligatoria.

## Verifica

`run_godot_import.py`, `run_testing_playbook.py` (45 controlli statici), `run_headless_smoke.py --scenario KEYBOARD_FULL_RUN`, `tools/manifesto_kit_capture.gd`, `tools/counter_layout_capture.gd` a 720p e 1080p, `check_tscn_format.py`, `verify_res_paths.py`, `test_no_mojibake.py`.

## Fatto quando

- Nessun controllo con look di default Godot nelle schermate in perimetro.
- Tutti i bottoni hanno i cinque stati; hover e focus mostrano l'accento; primario unico per schermata.
- Nessun hex inline nelle UI toccate; token solo nello script tema.
- Docs e decision log aggiornati; verifica del repo verde; catture prima/dopo dove il repo le richiede.
