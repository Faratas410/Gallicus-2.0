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

Nodi:

- `Object_RECEIPT`
- `Object_CONDEMNATION_MARK`
- `Object_SECOND_INCISION`

## Definition of Done

- oggetto e gesto identificabili;
- conseguenza leggibile;
- owner invariati;
- asset runtime-ready;
- feedback completo;
- focus e reduced motion verificati;
- smoke e visual QA verdi.

## Stop

Dividere la patch se richiede:

- nuovo flow;
- nuovo manager;
- piu' di una schermata maggiore senza asset condiviso;
- dati gameplay non previsti dal payload;
- compromesso di leggibilita';
- asset senza licenza.
