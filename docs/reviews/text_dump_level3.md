# Text Dump Level 3

## MAIN_MENU
- location: scenes/Main.tscn:280
  type: tscn_node
  key: TitleLabel
  text: GALLICUS
- location: scenes/Main.tscn:285
  type: tscn_node
  key: ContinueButton
  text: CONTINUA
- location: scenes/Main.tscn:297
  type: tscn_node
  key: ContinueHintLabel
  text: Nessuna partita salvata.
- location: scenes/Main.tscn:300
  type: tscn_node
  key: NewGameButton
  text: NUOVA PARTITA
- location: scenes/Main.tscn:307
  type: tscn_node
  key: LoadGameButton
  text: CARICA PARTITA
- location: scenes/Main.tscn:314
  type: tscn_node
  key: AchievementsButton
  text: ARCHIVIO
- location: scenes/Main.tscn:321
  type: tscn_node
  key: SettingsButton
  text: OPZIONI
- location: scenes/Main.tscn:328
  type: tscn_node
  key: CreditsButton
  text: CREDITI
- location: scenes/Main.tscn:353
  type: tscn_node
  key: AchievementsTitle
  text: ARCHIVIO DELLE CONDANNE
- location: scenes/Main.tscn:360
  type: tscn_node
  key: AchievementsSubtitle
  text: Registro consultivo. Nessuna ricompensa.
- location: scenes/Main.tscn:367
  type: tscn_node
  key: CondanneTabButton
  text: CONDANNE
- location: scenes/Main.tscn:374
  type: tscn_node
  key: MuseoTabButton
  text: MUSEO
- location: scenes/Main.tscn:412
  type: tscn_node
  key: AchievementsBackButton
  text: TORNA AL MENU
- location: scenes/Main.tscn:452
  type: tscn_node
  key: CreditsTitle
  text: CREDITI
- location: scenes/Main.tscn:460
  type: tscn_node
  key: CreditsBody
  text: "Game: Gallicus\nDesign/Direction: (TBD)\nCode: (TBD)\nArt: (TBD)\nAudio: (TBD)\nSpecial Thanks: (TBD)"
- location: scenes/Main.tscn:463
  type: tscn_node
  key: CreditsBackButton
  text: TORNA AL MENU
- location: scenes/Main.tscn:488
  type: tscn_node
  key: SettingsTitle
  text: OPZIONI
- location: scenes/Main.tscn:494
  type: tscn_node
  key: BrightnessLabel
  text: LUMINOSITA
- location: scenes/Main.tscn:507
  type: tscn_node
  key: BrightnessValue
  text: Luminosita: 1.00
- location: scenes/Main.tscn:513
  type: tscn_node
  key: LanguageLabel
  text: LINGUA
- location: scenes/Main.tscn:522
  type: tscn_node
  key: LanguageValue
  text: Lingua selezionata: Italiano
- location: scenes/Main.tscn:528
  type: tscn_node
  key: MasterVolumeLabel
  text: VOLUME MASTER
- location: scenes/Main.tscn:541
  type: tscn_node
  key: MasterVolumeValue
  text: Volume: 100%
- location: scenes/Main.tscn:547
  type: tscn_node
  key: MusicVolumeLabel
  text: VOLUME MUSICA
- location: scenes/Main.tscn:560
  type: tscn_node
  key: MusicVolumeValue
  text: Musica: 75%
- location: scenes/Main.tscn:563
  type: tscn_node
  key: FullscreenToggle
  text: SCHERMO INTERO
- location: scenes/Main.tscn:574
  type: tscn_node
  key: SettingsBackButton
  text: TORNA AL MENU
- location: scripts/ui/main_menu.gd:72
  type: gd_string
  key: L3_EXPECTATION_MICRO_COPY
  text: Loop rituale basato su scommesse. Nessun combat action.
- location: scripts/ui/main_menu.gd:220
  type: gd_string
  key: _disable_placeholder_buttons
  text: Funzione disattiva in L3.
- location: scripts/ui/main_menu.gd:261
  type: gd_string
  key: _build_museo_list
  text: PATTI DISPONIBILI (LIVELLO 3)
- location: scripts/ui/main_menu.gd:263
  type: gd_string
  key: _build_museo_list
  text: - Nessun patto disponibile.
- location: scripts/ui/main_menu.gd:270
  type: gd_string
  key: _build_museo_list
  text: - Nessuna arena disponibile.
- location: scripts/ui/main_menu.gd:278
  type: gd_string
  key: _build_museo_list
  text: VOCI DEL PUBBLICO
- location: scripts/ui/main_menu.gd:281
  type: gd_string
  key: _build_museo_list (template)
  text: "Voci dure: %s" (variabile: harsh_status)
- location: scripts/ui/main_menu.gd:283
  type: gd_string
  key: _build_museo_list (template)
  text: "Voci dure: +%d" (variabile: harsh_total)
- location: scripts/ui/main_menu.gd:341
  type: gd_string
  key: _on_condanna_mouse_entered (template)
  text: "%s\\n\\nCome e stata ottenuta:\\n%s\\n\\n%s" (variabili: title, condition_text, lore_text)
- location: scripts/ui/main_menu.gd:365
  type: gd_string
  key: _refresh_continue_button
  text: Accetta una scommessa per procedere.
- location: scripts/ui/main_menu.gd:369
  type: gd_string
  key: _format_continue_reject_reason
  text: Salvataggio non valido: schema del file mancante o corrotto.
- location: scripts/ui/main_menu.gd:370
  type: gd_string
  key: _format_continue_reject_reason
  text: Salvataggio non compatibile con questa versione.
- location: scripts/ui/main_menu.gd:371
  type: gd_string
  key: _format_continue_reject_reason
  text: Salvataggio incompleto: dati run mancanti.
- location: scripts/ui/main_menu.gd:375
  type: gd_string
  key: _format_continue_reject_reason
  text: Salvataggio non valido: schema Level 3 mancante.
- location: scripts/ui/main_menu.gd:377
  type: gd_string
  key: _format_continue_reject_reason
  text: Salvataggio non compatibile: schema Level 3 differente.
- location: scripts/ui/main_menu.gd:379
  type: gd_string
  key: _format_continue_reject_reason
  text: Salvataggio legacy non supportato in L3.
- location: scripts/ui/main_menu.gd:381
  type: gd_string
  key: _format_continue_reject_reason
  text: Salvataggio incompleto: stato run mancante.
- location: scripts/ui/main_menu.gd:383
  type: gd_string
  key: _format_continue_reject_reason
  text: Salvataggio non valido: dati Condanne non leggibili.
- location: scripts/ui/main_menu.gd:385
  type: gd_string
  key: _format_continue_reject_reason
  text: Salvataggio non valido: formato Condanne non supportato.
- location: scripts/ui/main_menu.gd:387
  type: gd_string
  key: _format_continue_reject_reason
  text: Salvataggio non valido.
- location: scripts/ui/main_menu.gd:388
  type: gd_string
  key: _format_continue_reject_reason (template)
  text: "Salvataggio non valido: %s." (variabile: reason)
- location: scripts/ui/main_menu.gd:401
  type: gd_string
  key: _on_continue_pressed / fallback
  text: In arrivo.

## BETTING / PACT
- location: scenes/UI.tscn:969
  type: tscn_node
  key: Lbl_INTRO_TITLE
  text: Scommessa Arena
- location: scenes/UI.tscn:978
  type: tscn_node
  key: Lbl_INTRO_SUBTITLE
  text: ARENA SPECIALE
- location: scenes/UI.tscn:990
  type: tscn_node
  key: Lbl_INTRO_HINT
  text: FOCUS: Leggi prima la CONDANNA.
- location: scenes/UI.tscn:999
  type: tscn_node
  key: Lbl_INTRO_BODY
  text: Seed (opzionale)
- location: scenes/UI.tscn:1003
  type: tscn_node
  key: SeedInput
  text: Es. 10331
- location: scenes/UI.tscn:1006
  type: tscn_node
  key: Btn_INTRO_APPLY_SEED
  text: APPLICA
- location: scenes/UI.tscn:1015
  type: tscn_node
  key: Lbl_INTRO_BODY_STAKE
  text: Stake
- location: scenes/UI.tscn:1034
  type: tscn_node
  key: Btn_INTRO_SELECT_WIN
  text: RADDOPPI O MUORI
- location: scenes/UI.tscn:1041
  type: tscn_node
  key: Btn_INTRO_SELECT_FAST
  text: INCASSA E VAI
- location: scenes/UI.tscn:1054
  type: tscn_node
  key: Lbl_INTRO_FOOTER
  text: Selezione: -
- location: scenes/UI.tscn:1061
  type: tscn_node
  key: Btn_INTRO_CONFIRM
  text: SIGILLA
- location: scenes/ui/BettingCircle.tscn:58
  type: tscn_node
  key: BettingCircle/Title
  text: "Arena del Sigillo\nQui ogni firma pesa."
- location: scenes/ui/BettingCircle.tscn:133
  type: tscn_node
  key: BettingCircle/Lbl_Left_Title
  text: VIA SINISTRA
- location: scenes/ui/BettingCircle.tscn:167
  type: tscn_node
  key: BettingCircle/Btn_Sign_Left
  text: SIGILLA
- location: scenes/ui/BettingCircle.tscn:242
  type: tscn_node
  key: BettingCircle/Lbl_Right_Title
  text: VIA DESTRA
- location: scenes/ui/BettingCircle.tscn:276
  type: tscn_node
  key: BettingCircle/Btn_Sign_Right
  text: SIGILLA
- location: scripts/ui/betting_circle_ui.gd:5
  type: gd_string
  key: EMPTY_PAGE_BODY
  text: "[i]Nessuna proposta disponibile.[/i]"
- location: scripts/ui/betting_circle_ui.gd:281
  type: gd_string
  key: _map_offer_for_display (template)
  text: "CONDIZIONE: %s" (variabile: condition_text)
- location: scripts/ui/betting_circle_ui.gd:283
  type: gd_string
  key: _map_offer_for_display (template)
  text: "PATTO: %s" (variabile: pact_text)
- location: scripts/ui/ui_root.gd:1836
  type: gd_string
  key: _refresh_condanna_focus_label
  text: Firma una via. Il Registro annota il prezzo.
- location: scripts/ui/ui_root.gd:1845
  type: gd_string
  key: _refresh_condanna_focus_label
  text: Clausola non esposta.
- location: scripts/ui/ui_root.gd:1846
  type: gd_string
  key: _refresh_condanna_focus_label (template)
  text: "Firma focus: %s | Clausola: %s" (variabili: title_text, doom_text)
- location: scripts/ui/ui_root.gd:2526
  type: gd_string
  key: _build_signature_button
  text: FIRMA
- location: scripts/content/bet_catalog.gd:96
  type: gd_string
  key: L3_ACTIVE_BET_IDENTITIES/CASH_OUT/display_title
  text: VIA DELLA PRUDENZA
- location: scripts/content/bet_catalog.gd:97
  type: gd_string
  key: L3_ACTIVE_BET_IDENTITIES/CASH_OUT/display_subtitle
  text: Chiudi ora. Salva margine, cedi gloria.
- location: scripts/content/bet_catalog.gd:103
  type: gd_string
  key: L3_ACTIVE_BET_IDENTITIES/DOUBLE_OR_DIE/display_title
  text: VIA DELL'HYBRIS
- location: scripts/content/bet_catalog.gd:104
  type: gd_string
  key: L3_ACTIVE_BET_IDENTITIES/DOUBLE_OR_DIE/display_subtitle
  text: Spingi oltre. Rischio massimo, ritorno totale.
- location: scripts/content/bet_catalog.gd:112
  type: gd_string
  key: LEVEL3_BETS/CASH_OUT/doom
  text: "Hai scelto la via breve.\nLa folla ricorda chi non spinge.\nL'arena lascia comunque il segno.\nEffetto: cicatrice OSSA INCRINATE, ogni futura scommessa pi� rischiosa."
- location: scripts/content/bet_catalog.gd:129
  type: gd_string
  key: LEVEL3_BETS/DOUBLE_OR_DIE/doom
  text: "Hai promesso tutto.\nNon esiste margine.\nLa folla trattiene il fiato.\nEffetto: MORTE IMMEDIATA, run terminata senza appello."

## RITUALS (PACT SEALED / RESOLVE)
- location: scenes/UI.tscn:679
  type: tscn_node
  key: Lbl_FIRST_REACTION_TITLE
  text: IL PATTO E' SIGILLATO.
- location: scenes/UI.tscn:689
  type: tscn_node
  key: Lbl_FIRST_REACTION_BODY
  text: La folla trattiene il fiato.
- location: scenes/UI.tscn:697
  type: tscn_node
  key: Btn_FIRST_REACTION_NEXT
  text: AVANTI
- location: scenes/UI.tscn:757
  type: tscn_node
  key: Lbl_RESOLUTION_TITLE
  text: RITO DI GIUDIZIO
- location: scenes/UI.tscn:766
  type: tscn_node
  key: Lbl_RESOLUTION_BODY
  text: Il patto viene giudicato.
- location: scenes/UI.tscn:774
  type: tscn_node
  key: Btn_RESOLUTION_NEXT
  text: AVANTI
- location: scripts/ui/ui_root.gd:1660
  type: gd_string
  key: _on_pact_sealed_opened
  text: patto registrato
- location: scripts/ui/ui_root.gd:1680
  type: gd_string
  key: _on_resolve_ritual_opened
  text: condanna registrata
- location: scripts/ui/ui_root.gd:1685
  type: gd_string
  key: _on_resolve_ritual_opened
  text: RITO DI GIUDIZIO

## INTERMEDIATE CHOICE
- location: scenes/UI.tscn:862
  type: tscn_node
  key: Lbl_MID_CHOICE_AUDIENCE
  text: La folla osserva la tua scelta.
- location: scenes/UI.tscn:872
  type: tscn_node
  key: Lbl_MID_CHOICE_TITLE
  text: SELEZIONE GESTO
- location: scenes/UI.tscn:891
  type: tscn_node
  key: Btn_MID_CHOICE_SELECT_0
  text: "UMILIATI\nRiduci escalation di 1.\nAtto registrato: contenimento."
- location: scenes/UI.tscn:905
  type: tscn_node
  key: Btn_MID_CHOICE_SELECT_1
  text: "PROVOCA\nAumenta escalation di 1.\nAtto registrato: esposizione."
- location: scripts/systems/run_manager.gd:2908
  type: gd_string
  key: _apply_intermediate_choice
  text: Gesto: Umiliati.
- location: scripts/systems/run_manager.gd:2911
  type: gd_string
  key: _apply_intermediate_choice
  text: Gesto: Provoca.
- location: scripts/systems/run_manager.gd:3339
  type: gd_string
  key: _enter_intermediate_choice
  text: La folla osserva la tua scelta.

## PUSH YOUR LUCK
- location: scenes/UI.tscn:1151
  type: tscn_node
  key: Lbl_PUSH_YOUR_LUCK_TITLE
  text: RILANCIO DEL PATTO
- location: scenes/UI.tscn:1160
  type: tscn_node
  key: Lbl_PUSH_YOUR_LUCK_BODY
  text: Il Registro e aperto: incassa ora o aumenta esposizione.
- location: scenes/UI.tscn:1169
  type: tscn_node
  key: Lbl_PUSH_YOUR_LUCK_SUBTITLE
  text: La folla registra il costo di ogni rilancio.
- location: scenes/UI.tscn:1178
  type: tscn_node
  key: Lbl_PUSH_YOUR_LUCK_HINT
  text: Condanna chiude il ciclo senza premio.
- location: scenes/UI.tscn:1190
  type: tscn_node
  key: Lbl_PUSH_YOUR_LUCK_FOOTER
  text: Scegli un atto. La firma e irrevocabile.
- location: scenes/UI.tscn:1212
  type: tscn_node
  key: Btn_PUSH_YOUR_LUCK_CASHOUT
  text: INCASSA ORA
- location: scenes/UI.tscn:1223
  type: tscn_node
  key: Lbl_PUSH_YOUR_LUCK_CHOICE_0
  text: Chiudi la posta corrente.
- location: scenes/UI.tscn:1241
  type: tscn_node
  key: Btn_PUSH_YOUR_LUCK_CONDANNA
  text: CONDANNA
- location: scenes/UI.tscn:1251
  type: tscn_node
  key: Lbl_PUSH_YOUR_LUCK_CHOICE_1
  text: Nessun premio. Registro chiuso.
- location: scenes/UI.tscn:1269
  type: tscn_node
  key: Btn_PUSH_YOUR_LUCK_DOUBLE
  text: RADDOPPIA
- location: scenes/UI.tscn:1280
  type: tscn_node
  key: Lbl_PUSH_YOUR_LUCK_FOOTER_CHOICE
  text: Aumenti posta e danno potenziale.
- location: scripts/ui/ui_root.gd:2030
  type: gd_string
  key: _on_push_luck_opened fallback
  text: Incassa ora o aumenta esposizione.
- location: scripts/ui/ui_root.gd:2043
  type: gd_string
  key: _on_push_luck_opened fallback
  text: SPINGI LA SORTE
- location: scripts/ui/ui_root.gd:2075
  type: gd_string
  key: _on_push_luck_opened fallback
  text: Nessun dettaglio.
- location: scripts/ui/ui_root.gd:2082
  type: gd_string
  key: _on_push_luck_opened fallback
  text: Stato: in attesa di scelta.
- location: scripts/systems/run/betting_policy.gd:146
  type: gd_string
  key: _get_audience_label
  text: FOLLA IN FURIA
- location: scripts/systems/run/betting_policy.gd:148
  type: gd_string
  key: _get_audience_label
  text: FOLLA OSTILE
- location: scripts/systems/run/betting_policy.gd:150
  type: gd_string
  key: _get_audience_label
  text: FOLLA TIEPIDA
- location: scripts/systems/run/betting_policy.gd:152
  type: gd_string
  key: _get_audience_label
  text: FOLLA IN ASCOLTO
- location: scripts/systems/run/betting_policy.gd:153
  type: gd_string
  key: _get_audience_label
  text: FOLLA IN DELIRIO
- location: scripts/systems/run/betting_policy.gd:181
  type: gd_string
  key: _build_audience_cashout_policy
  text: La folla non ti lascia incassare.
- location: scripts/systems/run/betting_policy.gd:184
  type: gd_string
  key: _build_audience_cashout_policy (template)
  text: "Incasso penalizzato: x%.1f" (variabile: cashout_modifier)
- location: scripts/systems/run/betting_policy.gd:187
  type: gd_string
  key: _build_audience_cashout_policy (template)
  text: "Incasso penalizzato: x%.2f" (variabile: cashout_modifier)

## END RUN (VERDICT)
- location: scenes/UI.tscn:1381
  type: tscn_node
  key: Lbl_END_RUN_TITLE
  text: VERDETTO DEL REGISTRO
- location: scenes/UI.tscn:1416
  type: tscn_node
  key: Lbl_END_RUN_PACTS_TITLE
  text: PATTI FIRMATI
- location: scenes/UI.tscn:1432
  type: tscn_node
  key: Lbl_END_RUN_CONDANNE_TITLE
  text: CONDANNE
- location: scenes/UI.tscn:1452
  type: tscn_node
  key: Lbl_END_RUN_CROWD_TITLE
  text: ULTIMA VOCE
- location: scenes/UI.tscn:1490
  type: tscn_node
  key: Btn_END_RUN_RESTART
  text: NUOVA RUN
- location: scenes/UI.tscn:1499
  type: tscn_node
  key: Btn_END_RUN_NEXT_BET
  text: NEXT BET
- location: scenes/UI.tscn:1507
  type: tscn_node
  key: Btn_END_RUN_QUIT
  text: TORNA AL MENU
- location: scripts/ui/ui_root.gd:1099
  type: gd_string
  key: _on_run_finale_selected
  text: AGGIORNAMENTO DEL REGISTRO
- location: scripts/ui/ui_root.gd:1215
  type: gd_string
  key: _refresh_verdict_panel
  text: Protocollo di classificazione completato.
- location: scripts/ui/ui_root.gd:1217
  type: gd_string
  key: _refresh_verdict_panel
  text: Chiusura non applicata.
- location: scripts/ui/ui_root.gd:1232
  type: gd_string
  key: _refresh_verdict_panel
  text: nessuna annotazione registrata
- location: scripts/ui/ui_root.gd:1235
  type: gd_string
  key: _refresh_verdict_panel
  text: Stato: chiusura definitiva.
- location: scripts/ui/ui_root.gd:1237
  type: gd_string
  key: _refresh_verdict_panel
  text: Stato: in attesa di prosecuzione.
- location: scripts/ui/ui_root.gd:1240
  type: gd_string
  key: _refresh_verdict_panel
  text: "[center]Registro Arena - Lettura amministrativa[/center]"
- location: scripts/ui/ui_root.gd:2658
  type: gd_string
  key: _set_end_run_buttons_terminal_text
  text: RETRY BET
- location: scripts/ui/ui_root.gd:2660
  type: gd_string
  key: _set_end_run_buttons_terminal_text
  text: RESTART RUN
- location: data/verdict_lines.gd:8
  type: gd_string
  key: SENTENCES_BY_OUTCOME
  text: dynamic list (LOSS/CASHOUT/WIN) used for verdict sentence line
- location: data/verdict_lines.gd:47
  type: gd_string
  key: CHARGES_BY_OUTCOME
  text: dynamic list (LOSS/CASHOUT/WIN) used for verdict charge line

## ERROR / BOOTFAIL / FALLBACK
- location: scenes/UI.tscn:445
  type: tscn_node
  key: BootFailTitle
  text: ERRORE INTERFACCIA
- location: scenes/UI.tscn:454
  type: tscn_node
  key: BootFailBackButton
  text: TORNA AL MENU
- location: scripts/ui/ui_root.gd:768
  type: gd_string
  key: _show_boot_fail (template)
  text: "Interfaccia non inizializzata.\nElementi mancanti:\n- %s\n\nTorna al menu e riavvia." (variabile: elenco missing)
- location: scripts/ui/ui_root.gd:879
  type: gd_string
  key: show_countdown
  text: GO
- location: scripts/ui/ui_root.gd:891
  type: gd_string
  key: _on_run_started
  text: Coins: 0
- location: scripts/ui/ui_root.gd:908
  type: gd_string
  key: _on_run_started
  text: "FAST: %ds" (variabile: FAST_SELECTION_SECONDS)
- location: scripts/ui/main_menu.gd:401
  type: gd_string
  key: continue/new game fallback
  text: In arrivo.

## MISC
- location: scenes/UI.tscn:118
  type: tscn_node
  key: HUD/BetBadgeTitle
  text: SCOMMESSA
- location: scenes/UI.tscn:125
  type: tscn_node
  key: HUD/BetBadgeValue
  text: NESSUNA
- location: scenes/UI.tscn:144
  type: tscn_node
  key: HUD/GloryTitle
  text: GLORY
- location: scenes/UI.tscn:150
  type: tscn_node
  key: HUD/GloryValue
  text: 0
- location: scenes/UI.tscn:159
  type: tscn_node
  key: HUD/EscalationLabel
  text: ESCALATION
- location: scenes/UI.tscn:203
  type: tscn_node
  key: ScarPopupTitle
  text: CICATRICE APPLICATA
- location: scenes/UI.tscn:222
  type: tscn_node
  key: ArenaResolutionLabel
  text: Il patto viene giudicato...
- location: scenes/UI.tscn:241
  type: tscn_node
  key: AudienceContextLabel
  text: La folla ti guarda.
- location: scenes/UI.tscn:266
  type: tscn_node
  key: RegisterAnnotationLabel
  text: Registro: atto annotato.
- location: scenes/UI.tscn:297
  type: tscn_node
  key: QuickCutLabel
  text: Configurazione stabile.
- location: scenes/UI.tscn:316
  type: tscn_node
  key: ArenaThemeTitleLabel
  text: Arena del Sigillo
- location: scenes/UI.tscn:335
  type: tscn_node
  key: ArenaThemeSubtitleLabel
  text: Qui ogni firma pesa.
- location: scenes/UI.tscn:369
  type: tscn_node
  key: SentenceTitleLabel
  text: SENTENZA
- location: scenes/UI.tscn:376
  type: tscn_node
  key: SentenceRuleLabel
  text: VINCI
- location: scenes/UI.tscn:384
  type: tscn_node
  key: SentenceDoomLabel
  text: SE FALLISCI: LA CICATRICE TI RESTA.
- location: scenes/UI.tscn:1309
  type: tscn_node
  key: ScarsDetailTitle
  text: DETTAGLIO CICATRICI
- location: scenes/UI.tscn:1320
  type: tscn_node
  key: ScarsDetailClose
  text: CHIUDI
- location: scenes/UI.tscn:1554
  type: tscn_node
  key: FastCountdownLabel
  text: FAST: 12s
- location: scenes/UI.tscn:1589
  type: tscn_node
  key: ScarsPanelTitle
  text: CICATRICI
- location: scenes/UI.tscn:1607
  type: tscn_node
  key: ScarsLabel
  text: Nessuna cicatrice.
- location: data/condanne.gd:25
  type: gd_string
  key: Condanna catalog
  text: user-facing archive copy for each condanna entry (title + condition_text + lore_text), including Registro endings at lines 176-205.
- location: scripts/systems/run/run_register_annotation_policy.gd:30
  type: gd_string
  key: register annotation templates
  text: all annotation templates shown in this file are user-facing via register_annotation payload.

## MOJIBAKE SUSPECTS
- location: scripts/systems/run_manager.gd:166
  type: gd_string
  key: AUDIENCE_POOL_SAFE
  text: Non è un leone. È un topo con un casco.
- location: scripts/systems/run_manager.gd:169
  type: gd_string
  key: AUDIENCE_POOL_SAFE
  text: Così si sopravvive… ma non si diventa leggenda.
- location: scripts/systems/run_manager.gd:172
  type: gd_string
  key: AUDIENCE_POOL_MID
  text: Non troppo audace… non troppo vile.
- location: scripts/systems/run_manager.gd:176
  type: gd_string
  key: AUDIENCE_POOL_MID
  text: È ambizione… o è paura mascherata?
- location: scripts/systems/run_manager.gd:180
  type: gd_string
  key: AUDIENCE_POOL_HIGH
  text: Sfida la sorte… o la provoca?
- location: scripts/systems/run_manager.gd:182
  type: gd_string
  key: AUDIENCE_POOL_HIGH
  text: Se cade, farà rumore.
- location: scripts/systems/run_manager.gd:183
  type: gd_string
  key: AUDIENCE_POOL_HIGH
  text: O sarà leggenda… o sarà cenere.
- location: scripts/systems/run_manager.gd:188
  type: gd_string
  key: AUDIENCE_PHRASES/FURY
  text: Ogni tuo respiro è un insulto.
- location: scripts/systems/run_manager.gd:193
  type: gd_string
  key: AUDIENCE_PHRASES/FURY
  text: Qui non c'è perdono per i timidi.
- location: scripts/systems/run_manager.gd:200
  type: gd_string
  key: AUDIENCE_PHRASES/COLD
  text: Il silenzio pesa più dell'acciaio.
- location: scripts/systems/run_manager.gd:203
  type: gd_string
  key: AUDIENCE_PHRASES/COLD
  text: Ti seguono senza pietà né favore.
- location: scripts/systems/run_manager.gd:212
  type: gd_string
  key: AUDIENCE_PHRASES/DELIRIUM
  text: Ogni colpo chiede di più.
- location: scripts/systems/run_manager.gd:243
  type: gd_string
  key: AUDIENCE_CONTEXT_PHRASES
  text: Il patto è inciso. Ti misurano.
- location: scripts/systems/run_manager.gd:244
  type: gd_string
  key: AUDIENCE_CONTEXT_PHRASES
  text: Hai firmato. Nessuno ti dà tregua.
- location: scripts/systems/run_manager.gd:269
  type: gd_string
  key: AUDIENCE_CONTEXT_PHRASES
  text: Hai scelto il gesto. Ora spingono di più.
- location: scripts/systems/run_manager.gd:289
  type: gd_string
  key: AUDIENCE_CONTEXT_PHRASES
  text: Ti fermi mentre urlano. Ora è delusione.
- location: scripts/systems/run_manager.gd:291
  type: gd_string
  key: AUDIENCE_CONTEXT_PHRASES
  text: Incassi mentre vogliono di più. Ti giudicano.
- location: scripts/systems/run_manager.gd:317
  type: gd_string
  key: AUDIENCE_CONTEXT_PHRASES
  text: Così finisci. La folla non ti piange.
- location: scripts/systems/run_manager.gd:319
  type: gd_string
  key: AUDIENCE_CONTEXT_PHRASES
  text: È finita. Il pubblico prende il tuo nome.
- location: scripts/systems/run_manager.gd:330
  type: gd_string
  key: AUDIENCE_CONTEXT_PHRASES
  text: Fine violenta. La folla ha ciò che voleva.
- location: scripts/systems/run_manager.gd:353
  type: gd_string
  key: AUDIENCE_CONTEXT_PHRASES_HARSH
  text: Il gesto è sterile. Ti tengono in debito.
- location: scripts/systems/run_manager.gd:461
  type: gd_string
  key: REGISTER_POOL_FINAL_CORRUPTION
  text: Integrità del soggetto: insufficiente. Caso concluso.
- location: scripts/systems/run_manager.gd:482
  type: gd_string
  key: REGISTER_POOL_FINAL_SCARS
  text: Integrità fisica compromessa. Il Registro conclude.
- location: scripts/systems/run_manager.gd:705
  type: gd_string
  key: Special arena description
  text: Condanne più dure.
- location: scripts/systems/run_manager.gd:713
  type: gd_string
  key: Special arena description
  text: Volatilità estrema.
