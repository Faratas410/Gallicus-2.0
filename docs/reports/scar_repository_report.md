# Report — Scar presenti nel repository

## Scope
Report inventariale delle Scar/cicatrici presenti nel codice runtime e nella documentazione canonica.

## Scar gameplay definite nel catalogo runtime
Fonte: `scripts/content/scar_catalog.gd`.

1. `OPEN_WOUND` — **FERITA APERTA**
2. `CRACKED_BONES` — **OSSA INCRINATE**
3. `SHAME_MARK` — **MARCHIO DELLA VERGOGNA**
4. `RUSTED_ARMOR` — **ARMATURA ARRUGGINITA**
5. `DEBT_BRAND` — **MARCHIO DEL DEBITO**
6. `ONE_EYE` — **OCCHIO PERDUTO**

## Scar/eventi di registro gestiti dal RunManager
Fonte: `scripts/systems/run_manager.gd`.

- Trigger runtime:
  - `SCAR_TRIGGER_IRREVERSIBLE_BET`
  - `SCAR_TRIGGER_REFUSED_CLOSURE`
  - `SCAR_TRIGGER_RISK_THRESHOLD`
- Event Scar registrati in run:
  - `SCAR_EVENT_IRREVERSIBLE_PACT`
  - `SCAR_EVENT_REFUSED_CLOSURE`
  - `SCAR_EVENT_RISK_THRESHOLD`

## Punti di integrazione runtime principali
- Segnali globali su `GameEvents`:
  - `scars_updated(scars: Array)`
  - `scar_applied(scar: Dictionary)`
- Stato run:
  - array `scars` in `run_state.gd`
- Sistema modificatori:
  - `RunScarSystem.compute_modifiers(...)` applica moltiplicatori in base alle scar attive.

## Canon/documentazione dove le Scar sono formalizzate
- `docs/canon/MECHANICS_UNIFIED.md` (sezione Scar System)
- `docs/canon/GLOSSARY_ENTITIES.md` (voce Scar)
- `docs/canon/LORE_UNIFIED.md` (relazione Registro ↔ Scar)

## Comando usato per l’inventario
`rg -n -i '\bscar\b|\bscars\b'`
