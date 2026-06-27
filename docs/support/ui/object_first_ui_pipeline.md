# Object-First UI Production Pipeline

Status: supporting workflow
Authority: subordinate to UI canon and active art-direction contract.

## Catena

```text
intento -> oggetto -> gesto -> brief -> asset/resource
-> binding reattivo -> feedback -> verifica
```

Non iniziare da una scena o da un bottone.

## Input

- `docs/object_grammar.md`
- `docs/art_direction.md`
- `docs/layout_rules.md`
- `docs/asset_pipeline.md`
- `docs/contracts/ui_art_direction_contract_v1.md`
- `docs/support/ui/run_ui_phase_paths.md`

## Workflow

1. **Scegliere un solo gesto**
   - Definire intento, conseguenza e owner.
   - Confermare che non richieda una nuova meccanica.

2. **Compilare la scheda object-first**
   - Oggetto, materiale, stati, feedback, registrazione.
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

- `registry_receipt_normal.png`
- `registry_condemnation_mark_pressed.png`
- `registry_second_incision_sealed.png`

Risorse:

- `sb_registry_receipt.tres`
- `mat_condemnation_heat.tres`

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
