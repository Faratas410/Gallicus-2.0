# Gallicus Data Schema

## Principio

I dati devono essere strutturati, deterministici e consumati da un owner chiaro.
Questo documento descrive le superfici operative; i canon restano autoritativi.

## Cataloghi

- `scripts/content/bet_catalog.gd` - identita', presentazione e behavior delle bet.
- `scripts/content/scar_catalog.gd` - scars e testi associati.
- `data/arena_themes.gd` - temi dell'arena.
- `data/condanne.gd` - condanne.
- `data/ending_rules.gd` - priorita' e condizioni degli ending.
- `data/verdict_lines.gd` - righe di verdetto.

I cataloghi definiscono contenuto, non flow.

## Bet

Una bet attiva deve fornire almeno:

- id/token stabile;
- `display_title`;
- `display_subtitle`;
- `path_tag`;
- `behavior`;
- patto, condizione e conseguenza;
- requisiti o blocchi dichiarati.

Titolo e subtitle devono essere localizzabili e leggibili nel Registro.

## Firma comportamentale

La futura implementazione usa i quattro assi canonici:

- `risk_bias`;
- `repetition_bias`;
- `scar_tolerance`;
- `volatility`.

Coerenza, fissazione e isteresi restano interne. Nessun payload UI puo' esporre
questi valori come statistiche player-facing.

## Stato del Registro

Campi persistenti canonici:

- `registry_pressure`;
- `registry_era`, limitato a `0..4`.

Lo stage Registry Memory dovra' aggiungere solo i campi necessari a:

- firma e storico di stabilita';
- ramp di tre run;
- stato terminale.

Ogni campo nuovo richiede default, sanitizzazione, migrazione e test. Le Ere
avanzano solo tramite Silenzio.

## Payload UI

- `RunManager` costruisce i payload canonici.
- `scripts/ui/run_ui_payload.gd` e' il confine di proiezione.
- La UI non calcola outcome, eleggibilita' o progressione.
- I payload espongono stato leggibile, non formule interne.
- Nuovi campi aggiornano contract statici e consumer nello stesso blocco.

## Save

Le shape save/runtime sono governate da:

- `docs/canon/RUN_ARCHITECTURE_CANON.md`;
- `docs/contracts/run_save_flow_step_contract_v1.md`;
- implementazioni SaveSystem/SaveManager.

Regole:

- schema versionato;
- scrittura atomica con backup;
- invalid value policy esplicita;
- normalizzazione legacy solo al boundary;
- profilo terminale non puo' riattivare il Registro;
- un save interrotto durante una cinematica riprende da uno stato canonico.

### Profilo e recovery CP-02

- Il profilo persistente e' alla versione `4`. Aggiunge `sfx_volume` (`float`,
  default `1.0`, range `0..1`) e `reduced_motion` (`bool`, default `false`).
- La migrazione `v3 -> v4` preserva lingua, luminosita', Master, Music,
  risoluzione, fullscreen, unlock e meta.
- Il wrapper run resta schema `1`; il payload Level 3 resta schema `2` e non
  riceve campi CP-02.
- `SaveSystem.load_run_payload_result()` restituisce `ok`, `payload`, `source`
  e `reason`; `load_run_payload()` resta il wrapper compatibile che restituisce
  soltanto il payload.
- Un backup valido rigenera il primario. Primario e backup corrotti o
  incompatibili vengono rinominati in quarantena, mai cancellati dal recovery;
  Continue viene disabilitato e il menu mostra una ragione localizzata.
- Gli alias legacy dei flow step restano normalizzati soltanto al boundary;
  valori sconosciuti sono rifiutati.

## Matrice contenuto

Il gate Content & Readability deve poter verificare:

- path tag coperti;
- behavior coperti;
- route cashout/double/condanna;
- condizioni delle Ere;
- ending raggiungibili;
- chiavi IT/EN/ES presenti;
- assenza di fallback player-facing.

## Validazione

```powershell
python tools/ci/verify_res_paths.py
python scripts/ci/test_release_content_contract.py
python scripts/ci/test_ritual_loop_contract.py
```

Ogni modifica a schema richiede test di:

- default;
- round-trip;
- save precedente;
- valore invalido;
- determinismo;
- consumer UI pertinente.
