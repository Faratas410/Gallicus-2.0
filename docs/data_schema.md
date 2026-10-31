# Gallicus Data Schema

## Checkpoint completion - 12 settembre 2026

Le versioni dei contenitori restano invariate. BET_OFFER viene scritto anche al primo ingresso nel
Registro; INTERMEDIATE_CHOICE all'apertura del gesto pubblico, prima della
scelta. Gli altri checkpoint mantengono i rispettivi confini. L'identita' di
chiusura condivisa fra campagna e fascicolo e' una cache di RunManager, azzerata
a nuova run/load e mai salvata come nuovo campo. Il congedo terminale non
richiede checkpoint: meta.registry_era=4 e' gia' persistita prima di mostrarlo.

RunState.scar_rng_state resta un int64 nel runtime, ma to_dict lo scrive come
stringa decimale: JSON.parse_string tratta i numeri come float64 e poteva
perdere i bit bassi, cambiando le cicatrici dopo Continue. from_dict accetta
sia la nuova stringa sia il numero legacy. I bit gia' persi in un vecchio save
non sono recuperabili; il caricamento conserva il valore legacy disponibile.
Il contratto verifica stati positivi/negativi oltre 2^53 e sedici estrazioni
successive identiche prima/dopo il round-trip JSON.

## Principio

Il profilo conserva `meta.seat_case` come `{choice, era}`: choice vuoto e
era -1 per profili precedenti, oppure `reserve`/`witness` e un'Era 0..3.
Valori non validi tornano allo stato non risolto. La risoluzione scrive scelta
ed eventuale addebito nella stessa transazione del profilo; la testimonianza
si applica alle nuove run nella stessa Era, non viene riapplicata al resume.
Il checkpoint RunState aggiunge `seat_case_deferred` (bool, default false):
un rinvio resta valido se si riprende lo stesso percorso e si azzera in una
nuova run. I salvataggi precedenti sono leggibili senza migrazione distruttiva.
`meta.seat_inquiry` conserva `seen` (bit 1 copia, bit 2 ricevuta o voce) e
`complete` (solo dopo entrambe); i profili precedenti partono da 0/false.
Il checkpoint aggiunge `seat_inquiry_deferred` (bool, default false), distinto
dal rinvio del caso. Le letture restano nel profilo attraverso la ripresa.
I due ID `seat_reserved_followup` e `seat_witness_followup` usano il catalogo
e `settings.campaign_dialogues_seen` gia' esistenti, senza nuovi campi save.
Anche `seat_receipt_after_inquiry` e `seat_voice_after_inquiry` riusano quel
catalogo e la stessa lista; vengono proposti solo dopo il confronto completato
e in base alla via registrata nel profilo.
`meta.seat_copy` e' vuoto nei vecchi profili, oppure `copy` o `keep` dopo il
confronto; il valore e' valido solo se l'indagine e' completa. La scelta `copy`
e l'addebito di 5 Denari condividono una scrittura del profilo. Il checkpoint
aggiunge `seat_copy_deferred` (bool, default false); si azzera alla nuova run.
I dialoghi `seat_copy_for_nerio` e `seat_copy_for_dima` usano la lista esistente.
`meta.seat_copy_era` registra l'Era in cui e' pagata la copia, o -1 altrimenti.
`meta.seat_copy_echoed` (bool, default false, valido solo con una copia
registrata) segna che la gradinata ha gia' ricordato la destinazione; il
checkpoint RunState aggiunge `seat_copy_echo` (bool, default false) per il
percorso in cui quell'eco avviene.
`meta.final_era` (30 ottobre 2026) registra lo smontaggio dell'ultima Era:
`ledger` (vuoto, `lauro`, `crowd`, `vessa`, `voice`, `debt`), `amount` (saldo
al momento della chiusura), `voice_pending` (solo con `voice`, finche' il
percorso successivo non applica la Pressione), `bando` (vuoto, `open`,
`closed`, `missed`), `strophe` (fino a tre versi `{key, value}` con chiavi del
catalogo di Lauro) e `copy` (vuoto, `seat`, `gesta`, `scars`). I profili
precedenti e i valori invalidi tornano ai default; `reset_campaign` li azzera.
Le scene `final_ledger`, `final_bando` e `final_copy` usano
`settings.campaign_dialogues_seen`.
Il checkpoint RunState aggiunge `active_msec` (int, default 0, mai negativo):
il tempo di gioco dentro il percorso a finestra attiva, escluso menu e
fascicolo, conservato al resume. A ogni percorso chiuso RunManager aggiunge una
riga JSON a `user://session_log.jsonl` (`ended_unix`, `era`, `silence`,
`active_seconds`, `reason`, `arenas`, `scenes`, `bando`, `denari`, `earned`,
`lost`). Il file e' una misura locale per i playtest: non entra nel profilo,
non e' letto dal gioco, non viene inviato e sopravvive al reset della campagna.
Il checkpoint RunState aggiunge `campaign_scenes_heard` (lista di id del
catalogo, default vuota): le scene di campagna confermate nel percorso
corrente. Id sconosciuti, duplicati o non stringa sono scartati; si azzera alla
nuova run. I richiami `seat_case_recall`, `seat_inquiry_recall` e
`seat_copy_recall` usano `settings.campaign_dialogues_seen`, senza nuovi campi
del profilo. Un profilo con un passo dell'arco gia' iniziato in un'Era
precedente alla regola resta valido: il passo riprende quando la sua Era e il
richiamo lo consentono.
Una copia pagata in un profilo precedente a questo campo riceve lo sconto per
l'Era corrente ancora aperta; in Assenza non viene riattivata. Valori invalidi
non attivano lo sconto. Il prezzo della polizza e' derivato, non salvato.

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

Il profilo v5 persiste i quattro assi canonici:

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

La bonifica ha aggiunto `meta.registry_evolution`, con i campi necessari a:

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

- Il profilo CP-02 era alla versione `4`. Aveva aggiunto `sfx_volume` (`float`,
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

## Profilo v5: campagna persistente

`v4 -> v5` aggiunge `meta.registry_evolution` e preserva settings, unlock,
pressione ed Era. Anche `v3 -> v4 -> v5` e' coperto. Wrapper run e payload
Level 3 restano invariati. La nuova shape contiene:

- `signature`: risk_bias in -1..1; repetition_bias, scar_tolerance e volatility
  in 0..1; default zero. Numeri non finiti o tipi errati diventano zero.
- `fixed`: false; `entry_streak`, `stable_streak`, `samples`, `era_runs` e
  `convergence`: zero, contatori limitati a 0..100000.
- `ramp_runs`: 3, limitato a 0..3 e azzerato dal Silenzio.
- `paths_seen`, `observations`: array deduplicati, massimo 16 stringhe da 128
  caratteri; `last_class`: stringa vuota, massimo 64 caratteri.

Il getter restituisce copia profonda. RunManager commette evoluzione, ramp
ed Era una sola volta per chiusura con scrittura atomica del profilo. Le API
non possono diminuire un'Era persistita. Era 4 e' anche il flag terminale.
`run_ended` riusa il Dictionary esistente: REGISTRY_SILENCE/REGISTRY_ABSENCE
espongono `classified_terminal=false`, `terminal` e `registry_status`
(chiave di una riga di stato del terminale, vuota nell'Assenza). La proiezione UI
`get_registry_presentation()` espone terminal, material_fade e definitive,
mai gli assi o il numero dell'Era.

## Correzione della ripresa dal menu

La boundary scrive esplicitamente `run_state.scars` e `run_state.pacts_log`
come array di dizionari, inclusi gli array vuoti. Questi campi appartengono al
contratto esistente: il wrapper resta 1, il payload L3 resta 2, il profilo 5.
`RunState.to_dict()` da solo non serializza gli oggetti runtime. Il checkpoint
non deve perdere gli array preparati da RunManager prima della scrittura.
Il test semantico attraversa scrittura JSON, lettura e pulsante di ripresa.
In caso di rigetto, quarantena e ritorno a MAIN_MENU precedono l'evento
`continue_rejected`, cosi' il menu legge il save aggiornato e conserva la causa.

## Preferenza di apertura

`settings.opening_prologue_seen`: boolean, default false, owner SaveManager.
Il caricamento di profili v5 senza il campo applica false e lo salva; valori
non booleani sono normalizzati a false. mark_opening_prologue_seen registra
true al primo ingresso presentato. Nessuna modifica ai checkpoint della run,
alla progressione o alla firma. I profili con campagna gia' avviata vengono
esclusi dalla presentazione tramite i dati esistenti. La regressione AV
ricarica il profilo e controlla che la preferenza sia persistita.

## Presa visione dei dialoghi - 12 settembre 2026

Profilo v5: settings.campaign_dialogues_seen e' una lista additiva di id
entry/middle/departure, deduplicata e sanitizzata; default vuoto, valori
ignoti o non stringa scartati. opening_prologue_seen=true sui vecchi profili
vale come entry gia' vista. La visione viene scritta solo al completamento
o skip esplicito; un'uscita interrompe e consente di ricominciare la scena.
Run save e versioni non cambiano. Il checkpoint BET_OFFER sottostante resta
valido e non salva una fase narrativa separata o il singolo indice di battuta.

Dettaglio e prove: `docs/support/illustrated_dialogues_2026-09-12.md`.
