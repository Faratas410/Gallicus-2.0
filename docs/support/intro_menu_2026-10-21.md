# Lastra d'avvio e menu principale - 21 ottobre 2026

Richiesta di Marco (2026-10-21): un'intro e un menu principale per ogni gioco,
nella materia del pass UI. Decisioni di Marco: intro a ogni avvio, sempre
saltabile; la decisione si registra qui e in `docs/art_direction.md`.

## Cosa cambia

- Nuova lastra d'avvio `scripts/ui/boot_intro.gd`, nodo `BootIntro`
  (CanvasLayer, layer 80) in fondo a `scenes/Main.tscn`: sopra il menu
  (layer 10), sotto `OpeningPrologue` (90) e la luminosita' (100).
- Sequenza (~2,4 s): inchiostro pieno 0,4 s; il wordmark esistente compare in
  0,3 s mentre la linea dello stilo si incide da sinistra a destra fino a
  1,2 s; la tagline del menu compare in 0,2 s; dissolvenza dell'intera lastra
  verso il menu da 2,0 a 2,4 s. Nessuna scala, nessuno spostamento.
- Qualsiasi tasto, clic, tocco o bottone del pad salta subito alla
  dissolvenza; un secondo input chiude la lastra. L'input viene consumato,
  quindi non attiva il bottone che ha il focus sotto.
- Movimento ridotto: lastra ferma e completa per 0,8 s, poi taglio al menu.
- Non compare in headless, con l'argomento utente `--skip-intro`, ne' quando
  `Main.tscn` e' istanziata da uno strumento (visual QA, contratti runtime):
  compare solo se la scena corrente e' `res://scenes/Main.tscn`.
- Materia: solo token di `manifesto_palette.gd` (inchiostro, avorio) e
  `gallicus_wordmark.png` gia' presente. Nessun PNG, nessun audio nuovo,
  nessuna stringa nuova (la tagline riusa la chiave del menu).
- Menu: rimosso `LoadGameButton`, nascosto e senza funzione dal Livello 3.
  La soglia d'arena (`NewGameButton`) resta un oggetto OF-04 con la sua skin,
  non un bottone del kit; quando c'e' un salvataggio l'unico primario del kit
  resta CONTINUA. Focus iniziale invariato: CONTINUA se c'e', altrimenti la
  soglia.
- `scripts/ci/test_ui_motion_contract.py` controlla anche la lastra: skip,
  headless, movimento ridotto, input consumato, nessuna scala o posizione,
  nessun tween.

## Non cambia

RunManager, GameEvents, salvataggi e `reset_campaign` (nessun flag nuovo), il
dialogo `OpeningPrologue` dopo ENTRA NELL'ARENA, i node path del menu, la skin
OF-04.

## Verifica (Linux, Godot 4.7.2)

- `python scripts/ci/run_testing_playbook.py`: 45 controlli statici verdi.
- Con `--godot-bin` e `--scenario KEYBOARD_FULL_RUN`: import, cp02, audit, AV,
  campagna e smoke verdi, ma solo con una correzione locale non inclusa:
  `main` a `56cb68b` non compila `run_manager.gd` (`CONDANNA_L_HO_ACCETTATO`
  non dichiarata), quindi su `main` l'import fallisce anche senza questa
  modifica.
- Avvio reale sotto Xvfb: la lastra parte e si chiude senza errori di script.

## Resta a Marco (verifica visiva locale)

Catture a 720p e 1080p di tutte le battute, con e senza movimento ridotto;
skip con tastiera, mouse e pad; passaggio lastra -> menu -> prologo; tagline
in IT/EN/ES non tagliata; giudizio sulla durata. Verde solo headless: non
validato.
