# Manifesto - pacchetti 4-7 ("Atto a stampa")

10 ottobre 2026. Esecuzione di `docs/UI_PASS_TODO.md` (pass UI comune ai
giochi) sul kit Manifesto gia' consegnato con i pacchetti 1-3. Consegna su
branch `claude/ui-pass` con PR verso `main` su mandato esplicito di Marco
(eccezione al flusso locale di `AGENTS.md`). Verifica solo headless: la
revisione visiva a 720p/1080p resta da fare sul PC locale.

## Kit (`scripts/ui/manifesto_kit.gd`, `manifesto_palette.gd`)

- Token: inchiostro `191917`, avorio `e7ddc5`, cera `792d26`, muted
  `a39e8f`, `DISABLED_MIX` 16%. Unica sorgente di colore delle UI toccate.
- API comune: `apply_panel`, `apply_inset`, `apply_primary_button`,
  `apply_secondary_button`, `apply_title` / `apply_body` / `apply_muted`,
  `apply_slider`, `apply_toggle`, `apply_option_button`, `apply_scroll`,
  `apply_scrollbar`, `apply_meter`, `apply_tooltip`, `apply_dialog`,
  `focus_rule`, `animate_panel_in`, `bind_button_motion`.
- Controlli: scanalatura incisa con corsa avorio e linguetta avorio (cera
  in presa/focus) al posto della manopola di bronzo; quadrato inciso con
  barra per il toggle; campo carta con chevron inciso e popup inchiostro/
  carta per OptionButton; scrollbar sottile avorio, cera solo in presa.
  Icone create a runtime (`ImageTexture`), nessun PNG nuovo.
- Accento: `manifesto_action_surface.gd` traccia la linea dello stilo sul
  bordo inferiore da sinistra a destra in 0.12 s su hover e focus e mostra il
  marchio a tre tagli vuoto sui comandi compatti; istantaneo con riduci
  movimento. Nessuna scala o spostamento. Il marchio pieno resta solo a
  `registered`.

## Pacchetto 4 - Fascicolo, HUD, Segni

Consumer migrati in `ui_root.gd` (`_apply_manifesto_print`): pigmenti del
fascicolo per stato (aperto inchiostro su carta, chiuso avorio/muted su
inchiostro), tipografia del corpo e scrollbar del resoconto; Gradinata e
Bando (titolo, misura incisa, corpo, nota muted); PressureRail (tipi);
ScarsPanel (scroll); dettaglio Segni su lastra d'inchiostro con scheda di
lettura in carta e chiusura secondaria; ScarPopup su lastra d'inchiostro.
Varianti crema della posta e del ritardo di lettura sostituite dai token.
Restano invariati: skin del fascicolo, sigillo, soglia, colori di stato
della pressione, payload e tempi. I titoli del fascicolo conservano il font
di scena: il font display variabile, sovrascritto li', fa fallire lo
shaping di Godot 4.6.2 (`Parameter "fd" is null`) sui comandi della posta.

## Pacchetto 5 - Menu, impostazioni, crediti

`main_menu.gd` (`_apply_manifesto_skin`): ripresa = primaria inchiostro;
Archivio/Impostazioni/Crediti e ritorni = secondari carta compatti; pannelli
utility su lastra d'inchiostro; titoli, corpo e valori nei tre ruoli; slider,
selettori e toggle dal kit (via le stylebox di bronzo dai campi); focus della
riga effetti = sottolineatura 4 px. Rimossa `MENU_BUTTON_HOVER_SCALE` (1.02):
l'hover suona e non scala. La soglia `ENTRA NELL'ARENA` mantiene la skin
oggetto.

## Pacchetto 6 - Archivio

Tab = secondari con stato `selected` (riga), mai `registered`. Voci lette
su scheda carta; condanna bloccata su inchiostro in ruolo muted (forma oltre
al colore); intestazioni del museo in ruolo titolo; biografie nel corpo;
nota/tooltip su carta; scroll dal kit. Nessuna modifica a sblocchi o dati.

## Pacchetto 7 - Narrativa

`opening_prologue.gd`: lastra d'inchiostro, titoli e ruoli dai token,
avanzamento primario e salto secondario. `registry_terminal_view.gd` non e'
toccato: e' la superficie di Era 4 / Assenza (fuori perimetro).

## Verifica (headless, Linux, Godot 4.6.2)

- `run_godot_import.py`: OK.
- `run_testing_playbook.py --scenario KEYBOARD_FULL_RUN`: tutti i controlli
  statici OK (inclusi `tscn_format`, `res_paths`, `ui_motion`,
  `no_mojibake`), runtime cp02/audit/campaign OK, smoke KEYBOARD_FULL_RUN OK.
  `av_runtime_contract` falliva per la larghezza della scrollbar dei Segni
  (< 8 px); corretto (traccia 10 px) e rieseguito singolarmente: OK.
- `test_ui_motion_contract.py` aggiornato: al posto di `_menu_button_tweens`
  vieta la scala hover del menu e richiede che la superficie fermi il tween
  dell'accento e rispetti riduci movimento.

## Ancora aperto

- Aggiornamento 15 ottobre: merge completato in `b81a4fc`, catture locali
  720p/1080p e correzioni eseguite con Godot 4.7.2. Evidenze e perimetro
  effettivamente ispezionato in `docs/support/manifesto_visual_review_2026-10-15.md`.
  Accettazione umana e checkpoint Linux del nuovo candidato restano aperti.
- Contraddizioni tipografiche: Libre Baskerville vs RobotoSerif del kit,
  focus del tema legacy (bordo oro 2 px) ancora nei controlli non migrati;
  rinomina di `italiana_regular_font.tres` non eseguita (riferimenti in CI).
- Colori di stato della pressione e skin oggetto (soglia, ricevuta, marchio,
  seconda incisione) invariati per vincolo.
