# Baseline di economia e ritmo - 29-30 ottobre 2026

Primo pacchetto della ripresa delle dieci ore, come proposto in
`docs/support/prossimo_goal_10_ore_2026-10-29.md`: baseline economica e mappa
degli eventi, senza ritoccare prezzi, ritmo o contenuto. Ripresa richiesta
dall'utente il 29 ottobre. Nessuna regola di gioco e' cambiata.

Candidato: `main` a `8df5f7b82ffcd6697b05ad4b3c83cce26da751cf`, con modifiche
locali solo documentali e strumenti di analisi (`tools/run_economy_matrix.py`,
`tools/economy_baseline_report.py`). Godot 4.7.2 ufficiale, Windows locale,
headless con driver audio Dummy, un profilo isolato per campagna. Le
simulazioni saltano i dialoghi e accelerano il tempo: non misurano durata,
comprensione o preferenze umane.

## Verifica del simulatore

- **Determinismo.** La campagna `bando_selective` seed 424242 ripetuta in un
  processo separato, con altri sei processi in parallelo, ha prodotto le stesse
  42 righe (saldo, entrate, uscite, acquisti, gradino, arene, Gloria, esito) e
  gli stessi dialoghi nello stesso percorso.
- **Scelte del posto.** Con `--seat` e `--copy` il simulatore raggiunge caso,
  seguito, confronto, risposta e copia nei due rami; il riepilogo registra la
  scelta salvata nel profilo. Senza parametri rinvia sempre, come la matrice
  storica.
- **Pagamenti e sconto.** La copia pagata produce 8-18 polizze scontate per
  campagna; posto riservato e copia scalano il saldo una sola volta.
- **Debito.** Con saldo iniziale -15 il conto torna positivo entro 2-3 percorsi.
- **Errori.** Il runner marca non valida ogni campagna con `ERROR:` nel log.
  12 campagne su 24 sono non valide solo per `resources still in use at exit`
  alla chiusura: tutte hanno raggiunto l'Assenza con righe complete. L'errore e'
  piu' frequente con molti processi paralleli; resta un difetto tecnico aperto
  (vedi Stabilita'). Le tabelle le riportano separate.
- Non verificati qui: ripresa da checkpoint e reset durante la campagna
  simulata; restano coperti dai contratti runtime esistenti.

## Matrice e confronti

Riproduzione (output in `artifacts/baseline_2026-10-29/`, artefatto locale):

```powershell
python -I tools/run_economy_matrix.py --godot-bin <godot 4.7.2> --output-dir artifacts/baseline_2026-10-29/matrix
python -I tools/run_economy_matrix.py --godot-bin <godot 4.7.2> --output-dir artifacts/baseline_2026-10-29/witness_keep --policies bando_selective --seat witness --copy keep
python -I tools/economy_baseline_report.py artifacts/baseline_2026-10-29/<cartella>/summary.json --output-dir artifacts/baseline_2026-10-29/report
```

Gli altri confronti cambiano un solo fattore rispetto a `bando_selective`:
`--copy copy`, `--seat reserve`, `--initial-denari -15`; piu' `prudent_never`
con `--seat witness --copy keep`. Tre seed: 424242, 777001, 1782373819.
Tabelle complete per campagna e per Era in
`artifacts/baseline_2026-10-29/report/report.md`.

| Configurazione | Percorsi | Saldo finale (3 seed) | Min | Acquisti | Bandi | Racconti mancati | Non valide |
| --- | ---: | --- | ---: | ---: | ---: | --- | ---: |
| bando, acquisti selettivi | 42-43 | 9 / 28 / 36 | -4 | 56-78 | 12 | - | 0 |
| bando, nessun acquisto | 42-43 | 353 / 421 / 363 | 0 | 0 | 12 | - | 2 |
| prudente, nessun acquisto | 42-43 | 192 / 232 / 220 | 0 | 0 | 6-7 | `scraping`, a volte `seats` | 1 |
| selettivi, testimonianza + custodia | 42-43 | 9 / 28 / 36 | -4 | 53-82 | 12 | - | 1 |
| selettivi, testimonianza + copia | 42-43 | 9 / 30 / 30 | -3 | 56-85 | 12 | - | 2 |
| selettivi, riserva + custodia | 42-43 | 9 / 28 / 36 | -4 | 54-79 | 12 | - | 2 |
| selettivi, debito iniziale -15 | 42 | 8 / 14 / 36 | -15 | 56-76 | 12 | - | 2 |
| prudente, testimonianza + custodia | 42-43 | 215 / 240 / 222 | 0 | 0 | 6-7 | `scraping`, a volte `seats` | 2 |

## Risultati

1. **La campagna ha sempre la stessa lunghezza.** In tutte le 24 campagne le
   Ere si chiudono ai percorsi 12, 23, 33 e 42 (in sette campagne la prima Era
   dura un percorso in piu': 13, 24, 34, 43). La convergenza del Registro
   (`settled` in `scripts/systems/run/registry_evolution.gd`) non scatta mai:
   ogni Era termina per esaurimento al tetto `ERA_EVIDENCE_CEILING` (12, 11,
   10, 9). Nessuno stile simulato abbrevia o allunga la campagna.
2. **Il contenuto e' concentrato nella prima meta'.** Su 42 percorsi, 29-32 non
   aprono alcuna scena di campagna. Con lo stile bando i dieci racconti sono
   tutti visti fra il percorso 2 e il 14-26; restano `middle` (24-25) e
   `departure` (34-35). Dopo il congedo nessun racconto e' piu' proposto:
   l'intera ultima Era (8-9 percorsi) non porta contenuto nuovo. Lo stile
   prudente distribuisce meglio i racconti (fino al percorso 26-28) ma ne perde.
3. **L'arco del posto avviene in un'unica entrata.** `seat_kept`, caso, seguito,
   confronto, risposta, scelta della copia e scena della copia arrivano nello
   stesso percorso (5 o 8 con lo stile bando, 8-14 con lo stile prudente):
   quattro scene e tre decisioni consecutive. Causa: dopo ogni chiusura
   `scripts/ui/opening_prologue.gd` riapre subito la scena o il pannello
   successivo, e `get_campaign_dialogue()` li rende disponibili insieme.
4. **Accesso dei racconti per stile.** `scraping` (gradino 9, senza Era) manca
   a tutte le campagne prudenti; `seats` (gradino 6) a una su tre per seed.
   Il prudente chiude 6-7 bandi su 12 e non raggiunge mai il gradino 8.
5. **I Denari hanno pochi usi.** Senza acquisti il saldo cresce fino a 190-420.
   Il Banco offre solo favore (3), pressione (3) e polizza (5), piu' 1 per Era;
   gli altri costi sono riserva (6) e copia (5), una sola volta. Con acquisti
   selettivi il saldo finisce vicino a zero dopo 53-85 acquisti.
6. **Le scelte del posto non lasciano traccia economica.** Riserva e
   testimonianza finiscono con lo stesso saldo per seed; la copia paga 5 e
   recupera 8-18 Denari di sconto, ma il saldo finale differisce di -6..+2. Il
   debito iniziale di -15 si riassorbe in 2-3 percorsi. Il significato delle
   scelte quindi non passa dal conto, che le assorbe.
7. **Ripetizione dello scambio sulla copia.** `scripts/content/arena_characters.gd`
   ha un solo scambio per ciascuna destinazione, mostrato alla prima arena quando
   `run_seed % 4 == 0`. In gioco reale il seed e' l'orario Unix: circa un
   percorso su quattro dopo la scelta, quindi intorno a otto ripetizioni identiche.

## Prima stima per le dieci ore

Con 42 percorsi fissi, 600 minuti richiedono circa 14 minuti attivi per
percorso. Il dato umano non esiste: e' un rapporto aritmetico, non una stima. La
struttura offre pero' uno scheletro stabile, quattro Ere di 12/11/10/9 percorsi
che possono ospitare quattro atti senza cambiare la regola del Silenzio.
Oggi 29-32 percorsi su 42 sono composti solo dal rito; la durata dipende quindi
soprattutto da quanto contenuto nuovo si aggiunge a quei percorsi.

## Proposta comparabile per l'arco del posto

Ogni variante conserva prezzi, rami e memoria attuali; cambia solo quando le
parti si aprono. Nessuna e' ancora implementata.

| | A. Attuale | B. Un passo per percorso | C. Un passo per Era |
| --- | --- | --- | --- |
| Trigger | tutto all'entrata dopo `seat_kept` | ogni passo all'entrata del percorso successivo | caso in Era 1, confronto in Era 2, copia in Era 3 |
| Prezzo e alternative | riserva 6 o testimonianza; copia 5 o custodia; rinvio | invariati | invariati |
| Conseguenze visibili | scene e Archivio subito | scene distribuite su 4-5 percorsi | scene nelle tre Ere; la copia da' contenuto all'ultima Era |
| Persistenza | profilo, gia' coperta | profilo; serve un marcatore di passo | profilo; serve il controllo dell'Era |
| Assenza prima della fine | non puo' accadere | improbabile (passi dal 5-14) | rischio basso: Era 3 garantita prima dell'Assenza |
| Sconto della copia | 8-18 polizze | invariato | piu' breve (resta l'ultima Era) |
| Rischio | sovraccarico, quiz ravvicinato | arco poco legato alle Ere | attese lunghe fra passi; serve un richiamo |

Raccomandazione per la decisione: C, con un richiamo breve all'inizio di ogni
passo; e' l'unica variante che porta contenuto nell'ultima Era. Il quiz e la
ripetizione dello scambio vanno decisi a parte.

## Variante C implementata - 30 ottobre 2026

Scelta dell'utente: C. Ogni passo si apre dalla sua Era (`SEAT_STEP_ERAS`
in `scripts/systems/run_manager.gd`) con un richiamo di tre battute come prima
scena dell'entrata; scene d'Era e racconti dovuti hanno la precedenza e il
richiamo non si accoda mai a un'altra scena dello stesso percorso. Il caso puo'
seguire `seat_kept` senza richiamo se l'Era e' gia' almeno 1. Prezzi, rami,
rinvii e memoria sono invariati. Regole in `docs/canon/MECHANICS_UNIFIED.md`,
flow in `docs/canon/RUN_ARCHITECTURE_CANON.md`, dati in `docs/data_schema.md`,
testi in `docs/content_bible.md`.

Simulazione sullo stesso comando della baseline (9 campagne, tutte all'Assenza;
4 marcate non valide solo per l'errore di chiusura):

| Passo | Prima (percorso) | Dopo (percorso) |
| --- | --- | --- |
| Caso e seguito | 5-14, tutto insieme | 13-15 (Era 1) |
| Confronto e risposta | stesso percorso del caso | 25-28 (Era 2) |
| Copia e scena | stesso percorso del caso | 35-36 (Era 3, dopo il congedo) |
| Polizze scontate con copia pagata | 8-18 | 5-13 |

L'ultima Era riceve ora una scena e una decisione dopo il congedo; i percorsi
37-42 restano senza contenuto nuovo. Output in `artifacts/seat_eras_2026-10-30/`.

Verifiche Windows locali, Godot 4.7.2: nuovo `scripts/ci/seat_steps_era_contract.gd`;
contratti di caso, confronto, memoria, copia, eco, reset e ordine dei racconti;
contratto dei dialoghi illustrati; playbook FULL_RUN 52/52
(`artifacts/seat_eras_2026-10-30/playbook/testing_playbook_summary.json`),
con la campagna nella UI reale fino all'Assenza. Non sostituiscono checkpoint
Linux, lettura umana dei richiami o prova del ritmo con persone.

## Smontaggio dell'ultima Era implementato - 30 ottobre 2026

Scelta dell'utente: opzione 1, con testi e quattro regole approvati (tutto il
conto come prezzo, nessun rinvio, rito spogliato dopo il congedo, conto fermo
anche in debito). Unica variazione rispetto alla proposta: la copia del posto,
che costa Denari, precede la chiusura del conto. Calendario dell'Era, una scena
per percorso: copia, `Il conto chiuso`, `L'ultimo bando`, `L'ultima copia`,
congedo. Regole in `docs/canon/MECHANICS_UNIFIED.md`, flow in
`docs/canon/RUN_ARCHITECTURE_CANON.md`, dati in `docs/data_schema.md`, testi in
`docs/content_bible.md` e `scripts/content/final_era.gd`.

Matrice con testimonianza e custodia (9 campagne, tutte all'Assenza; 2 non
valide solo per l'errore di chiusura), output in `artifacts/final_era_2026-10-30/matrix/`:

| Scena | Percorso |
| --- | --- |
| Copia del posto | 34-35 |
| Il conto chiuso | 35-36 |
| L'ultimo bando | 36-37 |
| L'ultima copia | 37-38 |
| Congedo | 38-40 |
| Fine campagna | 42-45 |

Osservazioni: il saldo arriva alla chiusura con 4-317 Denari e ha ora una
destinazione; l'ultimo bando non e' mai chiuso dalle policy simulate (con la
scala completa la quota e' 42 Gloria); le campagne durano 42-45 percorsi
contro 42-43 della baseline, causa non ancora isolata; dopo il congedo restano
3-6 percorsi di rito senza Banco ne' bandi. Le policy scelgono sempre la
gradinata e la gesta: non rappresentano preferenze.

Verifiche Windows locali, Godot 4.7.2: nuovo `scripts/ci/final_era_runtime_contract.gd`,
contratti del posto, ordine dei racconti, dialoghi illustrati e playbook
FULL_RUN 52/52 (`artifacts/final_era_2026-10-30/playbook2/testing_playbook_summary.json`);
la campagna nella UI reale registra conto, ultimo bando con strofa e copia
prima dell'Assenza. Fixture visiva `tools/final_era_capture.gd`: 19 catture
IT/EN/ES a 720p e 1080p in `artifacts/final_era_2026-10-30/captures/`, alcune
ispezionate. Mancano checkpoint Linux, lettura umana dei testi e prova del
ritmo con persone.

## Ultimo bando "con la voce bassa" - 30 ottobre 2026

Analisi sulle 33 campagne simulate: con la scala completa la quota 42 entro 7
arene e' raggiunta in circa il 23-29% dei percorsi da chi insegue i bandi; lo
stile prudente, nell'ultima Era, supera 23 Gloria solo nell'8% dei percorsi.
Lo 0 su 9 della matrice precedente era un solo tentativo per campagna.

Scelta dell'utente: opzione B. Dopo la scena `L'ultimo bando` il bando del
percorso chiede il gradino precedente (38 con la scala completa) e concede
tutte e 7 le arene; il checkpoint conserva quota e scadenza. Pannello e
fascicolo dichiarano l'ultimo bando senza promettere Denari o un bando
successivo; con il conto chiuso ogni bando chiuso lo dice.

Stima: con quota 38 almeno il 35% dei percorsi di chi insegue i bandi, limite
inferiore perche' le policy misurate puntavano a 42. Matrice dopo il cambio
(`artifacts/final_era_2026-10-30/matrix_bando/`): quote 38 per gli stili bando
e 20-26 per il prudente, 7 arene; nessuno dei tre tentativi indipendenti degli
stili bando ha chiuso (Gloria 0, 36 e 37), il prudente incassa comunque a
11-14. Il campione e' troppo piccolo per misurare la probabilita'; la campagna
nella UI reale del playbook chiude l'ultimo bando. Playbook FULL_RUN 52/52
(`artifacts/final_era_2026-10-30/playbook_bando/testing_playbook_summary.json`).

## Racconti garantiti a ogni stile - 31 ottobre 2026

Scelta dell'utente: opzione A. `seats` (gradino 6) e' garantito dall'Era 1 e
`scraping` (gradino 9) dall'Era 2, come gli altri racconti del posto vuoto; il
bando li anticipa. Prima lo stile prudente perdeva sempre `scraping` e in un
caso su tre `seats`. Matrice (`artifacts/tales_2026-10-31/matrix/`): 9
campagne all'Assenza (4 non valide solo per l'errore di chiusura), nessun
racconto perso; il prudente ascolta `seats` ai percorsi 13-15 e `scraping` ai
26-27, gli stili bando restano invariati. Playbook FULL_RUN 52/52
(`artifacts/tales_2026-10-31/playbook2/testing_playbook_summary.json`). Il
contratto del caso segna `seats` come gia' ascoltato per conservare il suo
scenario con un solo racconto prima del caso.

## Scambio sulla copia una sola volta - 31 ottobre 2026

Dopo la variante C la copia si sceglie al percorso 34-35, quindi lo scambio
compariva 2-3 volte (non circa otto come nella baseline), ma 1-2 volte dopo il
congedo, contraddicendo Dima che lascia il posto. Scelta dell'utente: opzione
A. Lo scambio compare una volta, nel primo percorso dopo la scelta, e mai dopo
il congedo; regola in `docs/canon/RUN_ARCHITECTURE_CANON.md`, dati in
`docs/data_schema.md`, contratto `scripts/ci/seat_copy_echo_contract.gd`.

## Chiusura del pacchetto - 31 ottobre 2026

L'utente ha chiesto di procedere con tutto quello che restava. Decisioni e
interventi, con il motivo:

- **Lunghezza della campagna: invariata.** Lo scheletro resta di 42 percorsi
  contati (tetti 12/11/10/9). Le campagne di 42-45 percorsi non dipendono da
  un difetto: un percorso chiuso prima di `REGISTRY_EVIDENCE_MIN_ARENAS` (2)
  arene non e' prova per il Registro, regola contro l'abbandono immediato.
  Dopo l'ultimo bando la policy simulata incassa spesso alla prima arena, e
  nell'Era 1 un `Raddoppia o muori` perso all'arena 1 ha lo stesso effetto.
  Alzare i tetti senza contenuto nuovo sarebbe attesa, esclusa dal mandato.
- **Usi dei Denari: nessuna nuova meccanica.** Chi usa il Banco spende tutto
  (53-85 acquisti, saldo finale 0-36, anche debito); l'accumulo riguarda solo le
  policy che non comprano, e nell'ultima Era il saldo ha ora una destinazione.
  Un nuovo pozzo di spesa senza prova umana violerebbe la regola di non
  drenare valuta; il registro di sessione misura saldo, entrate e uscite per
  percorso, cosi' la sessione cronometrata dira' se i giocatori accumulano.
- **Errore di chiusura delle simulazioni: corretto.** `tools/campaign_sim.gd`
  chiude come i contratti; la matrice successiva ha 9 campagne valide su 9 e
  nessun avviso ObjectDB (`artifacts/remaining_2026-10-31/matrix/`), contro
  12 non valide su 24 nella baseline.
- **Misura della sessione umana: pronta.** `RunState.active_msec` conta il
  tempo dentro il percorso a finestra attiva; `user://session_log.jsonl`
  registra una riga per percorso chiuso; `tools/session_timing_report.py` la
  riassume. Procedura in `docs/playtest_guide.md`, dati in `docs/data_schema.md`,
  contratto `scripts/ci/session_log_contract.gd`.

Non eseguibili dall'agente: la sessione umana cronometrata, il checkpoint Linux
canonico (WSL non installato) e qualunque passo Steam.

## Decisioni da prendere prima di cambiare il gameplay

1. Lunghezza: confermata a 42 percorsi contati, vedi sopra.
2. Variante dell'arco del posto: decisa (C), vedi sopra.
3. Contenuto dell'ultima Era: deciso (smontaggio), vedi sopra. Restano da
   valutare la quota dell'ultimo bando e i percorsi dopo il congedo.
4. Racconti per chi gioca prudente: decisi (opzione A), vedi sopra.
5. Denari: nessuna nuova meccanica prima della prova umana, vedi sopra.
6. Scambio sulla copia: deciso (una sola volta), vedi sopra.

## Prove necessarie prima del primo cambiamento

- Una sessione umana cronometrata di almeno due ore sul candidato attuale:
  minuti per percorso, lettura, pause, momenti di noia, cosa si ricorda.
  Nessun numero di questo rapporto la sostituisce.
- Contratto runtime per la variante scelta dell'arco del posto: ordine, rinvio,
  ripresa da checkpoint, reset e Assenza.
- Ripetizione della matrice dopo ogni cambio di regola, con lo stesso comando.

## Stabilita'

Il messaggio `ERROR: N resources still in use at exit` con avviso ObjectDB
compare in 12 campagne su 24 con fino a otto processi paralleli; nella matrice
del 28 ottobre, con due processi, erano 2 su 9. Si verifica dopo `SIM_SUMMARY`, alla chiusura del processo, e non
modifica i dati della campagna (vedi determinismo). Per una campagna lunga su
piu' sessioni va indagato con `--verbose` prima del candidato di release.

## File

- `tools/run_economy_matrix.py`: parametri `--seeds`, `--policies`, `--seat`,
  `--copy`, `--initial-denari`; conserva le righe `SIM_RUN` nel riepilogo.
- `tools/economy_baseline_report.py`: nuovo, aggrega per campagna e per Era.
- `docs/testing.md`, `docs/development_plan.md`, `docs/README.md`,
  `docs/support/sospensione_10_ore_2026-10-29.md` e questo rapporto.
- Variante C: `scripts/systems/run_manager.gd`, `scripts/systems/run/run_state.gd`,
  `scripts/content/campaign_dialogues.gd`, `assets/i18n/{it,en,es}.csv` e
  traduzioni compilate, `scripts/ci/seat_steps_era_contract.gd` e UID,
  `scripts/ci/run_campaign_runtime_contract.py`, contratti di caso, confronto e
  copia; canon meccanica, architettura e UI, schema dati, bibbia dei contenuti.
- Smontaggio: `scripts/systems/run_manager.gd`, `scripts/systems/save_manager.gd`,
  `scripts/systems/game_events.gd`, `scripts/content/campaign_dialogues.gd`,
  `scripts/content/final_era.gd`, `scripts/ui/seat_case.gd`,
  `scripts/ui/main_menu.gd`, `scripts/ui/betting_circle_ui.gd`,
  `scripts/ui/ui_root.gd`, `scripts/ui/run_manager_ui_port.gd`, traduzioni,
  `scripts/ci/final_era_runtime_contract.gd`, contratti di campagna, posto,
  ordine dei racconti e dialoghi illustrati, `tools/campaign_sim.gd`,
  `tools/final_era_capture.gd`; canon meccanica, architettura, UI e lore,
  schema dati, bibbia dei contenuti, grammatica degli oggetti e testing.

Checkpoint Linux, sessioni umane, durata e coinvolgimento restano aperti.
