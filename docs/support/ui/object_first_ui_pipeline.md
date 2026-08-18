# Object-First UI Production Pipeline

Status: supporting workflow
Authority: subordinate to UI canon and active art-direction contract.

## Catena

```text
fantasia -> ruolo -> intento -> strumento -> meccanica -> interfaccia
```

La completezza di ogni azione resta definita dalla formula canonica:

```text
intento -> oggetto -> gesto -> feedback -> registrazione
```

La produzione traduce poi la formula in risorse verificabili:

```text
intento -> oggetto -> gesto -> brief -> asset/resource
-> binding reattivo -> feedback -> verifica
```

Non iniziare da una scena, da un bottone o da un widget HUD.

## Gate prima dell'interfaccia

Prima di produrre UI:

1. definire la fantasia vissuta;
2. definire il ruolo del soggetto;
3. elencare gli strumenti fisici o amministrativi credibili;
4. assegnare all'azione un oggetto primario;
5. rendere la conseguenza leggibile prima del gesto.

In Gallicus lo strumento puo' appartenere al Registro anziche' al soggetto.
Se non esiste un oggetto primario credibile, fermare la UI e riesaminare la
meccanica.

## Input

- `docs/object_grammar.md`
- `docs/art_direction.md`
- `docs/layout_rules.md`
- `docs/asset_pipeline.md`
- `docs/contracts/ui_art_direction_contract_v1.md`
- `docs/support/ui/run_ui_phase_paths.md`

## Workflow

1. **Scegliere un solo gesto**
   - Confermare fantasia, ruolo, intento, oggetto primario e owner.
   - Definire la conseguenza leggibile prima del gesto.
   - Confermare che non richieda una nuova meccanica.

2. **Compilare la scheda object-first**
   - Oggetto, materiale, stati, feedback, registrazione.
   - Verificare che la metafora software sparisca senza nascondere l'affordance.
   - Definire fallback accessibile.

3. **Classificare il lavoro**
   - copy;
   - asset;
   - style/resource;
   - scene binding;
   - payload/contract, solo se indispensabile;
   - verification.

4. **Scrivere il brief**
   - ruolo runtime;
   - dimensioni;
   - stati;
   - safe area testo;
   - fonte/licenza;
   - destinazione;
   - test.

5. **Produrre o scegliere l'asset**
   - Riutilizzare solo asset coerenti.
   - Generare il gap minimo.
   - Niente testo baked.

6. **Creare la risorsa Godot**
   - StyleBox/materiale/theme nel path owner.
   - Override locale solo se la migrazione non e' ancora globale.

7. **Collegare la superficie**
   - UI reagisce a payload e invia intenti.
   - Nessuna decisione o transizione nella presentazione.

8. **Aggiungere feedback**
   - visuale;
   - audio;
   - testuale;
   - reduced motion.

9. **Verificare**
   - static test;
   - path/import;
   - smoke;
   - screenshot alle risoluzioni target;
   - focus e tre lingue.

10. **Aggiornare roadmap e docs**
    - Segnare il gesto chiuso solo dopo le prove.

## Naming

Asset:

- `registry_receipt_base.png`
- `registry_condemnation_mark_base.png`
- `registry_second_incision_sealed.png`
- `arena_threshold_base.png`
- `registry_table_closed.png`
- `registry_table_open.png`
- `registry_promise_signature_blank.png`
- `registry_promise_signature_signed.png`
- `registry_pact_tablet_sealed.png`
- `arena_gesture_tile_placa.png`
- `arena_gesture_tile_provoca.png`

Risorse:

- `sb_registry_receipt_normal.tres`
- `sb_registry_receipt_focus.tres`
- `sb_registry_receipt_pressed.tres`
- `sb_registry_receipt_disabled.tres`
- `sb_registry_condemnation_mark_normal.tres`
- `sb_registry_condemnation_mark_focus.tres`
- `sb_registry_condemnation_mark_pressed.tres`
- `sb_registry_condemnation_mark_registered.tres`
- `sb_registry_condemnation_mark_disabled.tres`
- `sb_registry_second_incision_normal.tres`
- `sb_registry_second_incision_focus.tres`
- `sb_registry_second_incision_pressed.tres`
- `sb_registry_second_incision_sealed.tres`
- `sb_registry_second_incision_disabled.tres`
- `sb_arena_threshold_normal.tres`
- `sb_arena_threshold_focus.tres`
- `sb_arena_threshold_pressed.tres`
- `sb_arena_threshold_crossed.tres`
- `sb_arena_threshold_disabled.tres`
- `sb_registry_table_closed_normal.tres`
- `sb_registry_table_closed_focus.tres`
- `sb_registry_table_closed_pressed.tres`
- `sb_registry_table_closed_disabled.tres`
- `sb_registry_table_open.tres`
- `sb_registry_promise_signature_normal.tres`
- `sb_registry_promise_signature_focus.tres`
- `sb_registry_promise_signature_pressed.tres`
- `sb_registry_promise_signature_selected.tres`
- `sb_registry_promise_signature_signed.tres`
- `sb_registry_promise_signature_disabled.tres`
- `sb_registry_pact_tablet_normal.tres`
- `sb_registry_pact_tablet_focus.tres`
- `sb_registry_pact_tablet_pressed.tres`
- `sb_registry_pact_tablet_validated.tres`
- `sb_registry_pact_tablet_disabled.tres`
- `sb_arena_gesture_placa_normal.tres`
- `sb_arena_gesture_placa_focus.tres`
- `sb_arena_gesture_placa_pressed.tres`
- `sb_arena_gesture_placa_selected.tres`
- `sb_arena_gesture_placa_disabled.tres`
- `sb_arena_gesture_provoca_normal.tres`
- `sb_arena_gesture_provoca_focus.tres`
- `sb_arena_gesture_provoca_pressed.tres`
- `sb_arena_gesture_provoca_selected.tres`
- `sb_arena_gesture_provoca_disabled.tres`
- `sb_registry_judgment_seal_normal.tres`
- `sb_registry_judgment_seal_focus.tres`
- `sb_registry_judgment_seal_pressed.tres`
- `sb_registry_judgment_seal_strike_1.tres`
- `sb_registry_judgment_seal_strike_2.tres`
- `sb_registry_judgment_seal_resolved.tres`
- `sb_registry_judgment_seal_disabled.tres`
- `sb_registry_final_dossier_open.tres`
- `sb_registry_final_dossier_updated.tres`
- `sb_registry_final_dossier_closed.tres`
- `sb_registry_final_dossier_tab_normal.tres`
- `sb_registry_final_dossier_tab_focus.tres`
- `sb_registry_final_dossier_tab_pressed.tres`
- `sb_registry_final_dossier_tab_selected.tres`
- `sb_registry_final_dossier_tab_disabled.tres`

Nodi:

- `Object_RECEIPT`
- `Object_CONDEMNATION_MARK`
- `Object_SECOND_INCISION`
- `Object_ARENA_THRESHOLD`
- `Object_REGISTRY_TABLE` (`ClosedBookBg`/`SpellbookBg` nel consumer attuale)
- `Object_PROMISE_SIGNATURE` (`Btn_Sign_Left`/`Btn_Sign_Right` nel consumer attuale)
- `Object_PACT_TABLET` (`Btn_FIRST_REACTION_NEXT` nel consumer attuale)
- `Object_ARENA_GESTURE` (`Btn_MID_CHOICE_SELECT_0/1` nel consumer attuale)
- `Object_JUDGMENT_SEAL` (`Btn_RESOLUTION_STRIKE` nel consumer attuale)
- `Object_FINAL_DOSSIER` (`Panel_END_RUN` e `EndRunRouteTabs` nel consumer attuale)

## Definition of Done

- oggetto e gesto identificabili;
- conseguenza leggibile;
- owner invariati;
- asset runtime-ready;
- feedback completo;
- focus e reduced motion verificati;
- smoke e visual QA verdi.

La prova completa e' cumulativa ai checkpoint OF-06, OF-09 e OF-11. Tra i
checkpoint il pacchetto usa contratto specifico, import pertinente e QA
rappresentativa; il signoff formale resta sospeso fino al checkpoint.

## Stop

Dividere la patch se richiede:

- nuovo flow;
- nuovo manager;
- piu' di una schermata maggiore senza asset condiviso;
- dati gameplay non previsti dal payload;
- compromesso di leggibilita';
- asset senza licenza.
