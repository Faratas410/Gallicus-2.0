# Campaign Coherence & Pre-Human Completion Pass

## Candidato e mandato

Richiesta esplicita dell'utente del 12 settembre: completare il prodotto
end-to-end prima delle prove umane, usando la roadmap come input. Il mandato
autorizza questo pacchetto oltre ai freeze storici CP-03. Non sostituisce le
sessioni umane, il checkpoint Linux o l'autorizzazione a pubblicare su Steam.

Base: `97476b0763842bd7ade51cc40080af3aea16c059`, branch locale `main`, pulito
all'ingresso. La consegna comprende modifiche non committate. Nessun commit,
push, PR o operazione Steam. Manifest del candidato e build Windows in
`artifacts/exports/campaign_completion_2026-09-12/`.

## Percorso ricostruito

| Passaggio reale | Funzione nell'arco | Persistenza e payoff |
| --- | --- | --- |
| Boot, impostazioni e soglia | luogo e atto di ingresso | profilo e preferenze; guardia terminale prima del Registro |
| Prologo al primo ingresso | rischio, segno, memoria | due frasi; mai riprodotto dal Continue |
| Registro e due promesse | confronto fra vincoli | primo checkpoint anche prima della firma |
| Firma e tavoletta | scelta irreversibile, poi riconoscimento | BET_SIGNED; il secondo gesto legge il vincolo, non sceglie un nuovo patto |
| Gesto pubblico | esposizione e pressione | INTERMEDIATE_CHOICE prima del gesto; la folla non decide il verdetto |
| Tre colpi del sigillo | richiesta e produzione del responso | esito reale; PUSH_LUCK dopo la risoluzione |
| Quietanza, marchio, seconda incisione | chiusura, costo, nuova esposizione | route esistenti; BET_OFFER dopo il rilancio |
| Fascicolo | esito e tracce del percorso | identita' di chiusura unica; condanne e conoscenza persistenti |
| Archivio | consultazione dei vincoli disponibili e delle registrazioni | titoli e significato dei patti, senza contatori di battute |
| Silenzio | mancanza di responso, non vittoria | incremento unico dell'Era; ritorno utility dopo due secondi |
| Tre percorsi di ramp | continuita' materiale e sonora | ambiente piu' rarefatto; testo, focus e SFX restano leggibili |
| Quarto Silenzio, Assenza | cessazione della classificazione | arena vuota senza figure umane, nero e battito; soltanto crediti e uscita |
| Riavvio dopo l'Assenza | finalita' | nessun RegisterState, Continue o nuova campagna; nessun replay del congedo |

RunManager conserva tutte le decisioni, GameEvents gli intenti/eventi e la UI
la presentazione. Nessuna nuova fase, ricompensa o soglia di campagna. I
coefficienti delle conseguenze restano quelli esistenti, ora applicati anche
alle cicatrici prima ignorate. Ere e firma non compaiono nell'interfaccia.

## Difetti chiusi e ridondanze valutate

- La vecchia prova di campagna inseriva storie direttamente in RunState.
  Il nuovo contratto percorre pulsanti disponibili, offerte e risultati reali:
  nessuna storia, ricompensa, esito o metrica di campagna viene inserita.
- L'ingresso nel primo Registro non scriveva BET_OFFER. Ora il gioco e'
  riprendibile anche se si esce prima di firmare.
- Il gesto pubblico conservava BET_SIGNED. Ora INTERMEDIATE_CHOICE viene
  scritto all'ingresso e Continue non ripete la tavoletta gia' riconosciuta.
- Il JSON numerico perdeva precisione nello stato RNG delle cicatrici. Ora la
  scrittura usa una stringa decimale e il lettore accetta anche i numeri legacy;
  il test verifica identita' dello stato a 64 bit e delle estrazioni successive.
- Le annotazioni aggiunte durante la chiusura potevano cambiare l'identita'
  fra campione di convergenza e fascicolo. L'identita' viene fissata una volta
  sull'evidenza conclusa, prima degli sblocchi di chiusura; entrambi i consumer
  usano lo stesso valore. La cache e' locale alla run e si azzera al resume.
- Le sconfitte dichiaravano cicatrici con prefisso `SCAR_`, estraneo al
  catalogo: l'inserimento falliva silenziosamente e il resolver ignorava anche
  i modificatori delle cicatrici attive. Gli ID ora coincidono con catalogo,
  RunState e save. Le prove verificano applicazione reale, effetti avversi di
  tutti i sei tipi e conseguenze dei patti attivi. Non e' un ribilanciamento
  dei coefficienti, ma cambia effettivamente il costo delle run segnate.
- Lo smoke Quietanza sceglie un'offerta non terminale quando disponibile:
  la scelta cieca di Raddoppia o Muori poteva terminare il test prima della
  route richiesta con le cicatrici ora attive. Nessun esito forzato, modifica
  al seed o allentamento del validator; nessun effetto sul giocatore.
- L'Archivio elencava numeri di battute e nomi di patti senza significato.
  Riusa ora le descrizioni localizzate del catalogo e distingue esplicitamente
  voce del pubblico e responso. Espone solo patti attivi: elimina anche le voci
  legacy non offerte dal gioco. Le condanne conservano le descrizioni esistenti.
- Il patto dopo la firma e i tre colpi restano: hanno funzione distinta di
  lettura del vincolo e progressione del responso, con cue e input gia' verificati.
  Non vengono aggiunte nuove conferme, countdown o attese fra percorsi.
- Il nero immediato e senza uscita dell'Assenza non distingueva bene fine e
  interruzione. Il congedo di sei secondi riprende la stessa arena, sottrae ogni
  classificazione e termina con due sole utility. Il profilo e' gia' terminale
  prima della presentazione: uscire durante il congedo non riapre il Registro.
- La ramp materiale si applica anche alle superfici riprese dal save. La musica
  usa la stessa intensita' di presentazione per sottrarre fino a circa 6 dB,
  conservando brani, crossfade e livello dei gesti. Nessuna nuova soundtrack.

## Prove e limiti

Il percorso deterministico di riferimento usa seed iniziale `1782373819`,
incrementato di `7919` per percorso. Solo il tempo di presentazione viene
accelerato. La policy esercita offerte diverse e chiusura col marchio; le altre
route sono coperte separatamente dal playbook. Non e' una strategia proposta al
giocatore e non misura la comprensione o il ritmo umano.

Il candidato ha raggiunto l'Assenza in 178 percorsi attraverso la UI, con 54
cicatrici realmente applicate, quattro Silenzi (91, 99, 164, 178) e ripresa dei
quattro checkpoint. Il precedente risultato di 57 percorsi precedeva la
correzione delle cicatrici e non descrive la build consegnata. Il limite di
guardia del test e' 400 percorsi; non e' una durata o un contatore del gioco.
La regressione verifica anche la
coincidenza fra campione e fascicolo, risorse e storia al resume, blocco delle
richieste terminali e boot senza RegisterState. Le catture del percorso sono in
`artifacts/campaign_pass/journey_complete_visual/`; le fixture localizzate sono separate
in `artifacts/campaign_pass/layout/`.

Il playbook comprende contratti statici, migrazioni/recovery CP-02, regressioni
semantiche, integrazione AV e otto route. La regressione di campagna entra nello
stesso job runtime Linux e nel playbook locale, senza nuovo job. I log del pass
sono in `artifacts/campaign_pass/`. Il manifest di export registra sorgenti,
hash, piattaforma e verifiche del candidato realmente distribuito localmente.

### Cache fredda

`check_cold_import.py` copia i file correnti, inclusi gli edit locali, in tre
progetti indipendenti senza `.godot`. Non elimina o riusa la cache di lavoro.
Conserva inventario SHA-256 e ciascun log, anche fallito.

Nella sandbox Windows: un crash `0xC0000005`, due import con exit zero ma errore
di lettura dello store certificati. Con i permessi normali necessari a Godot:
tre import indipendenti riusciti senza errori. La serie `cold_final` ripete
tre import riusciti sui sorgenti con il congedo e le cicatrici corrette.
Nessun asset o parametro del
motore e' stato cambiato per ottenere questi risultati. La riproduzione e'
confinata all'ambiente ristretto in questa serie; non e' dimostrata una causa
interna del crash. La procedura operativa usa i permessi corretti e rifiuta
sempre gli errori, anche con exit zero; nessun retry automatico o allowlist.

### Cosa resta umano o esterno

- Tre sessioni CP-03, comprensione senza guida, fatigue audiovisiva e ritmo.
- Durata mediana 2-4 ore e non-farmabilita' percepita: 178 percorsi automatici
  dimostrano raggiungibilita', non certificano questi criteri.
- Il primo Silenzio a 91 e l'intervallo 99-164 sono un rischio di ritmo da
  osservare nelle sessioni: non vanno descritti come escalation umana gia'
  validata. Il pass non ha abbassato le soglie per rendere verde il test.
- Checkpoint Linux sul futuro commit manuale; i verdi CP-02 non si trasferiscono.
- Crediti/diritti finali e pubblicazione Steam secondo gli owner di release.

La Campaign Spine e' tecnicamente verificabile end-to-end localmente. Il
candidato e' destinato alle prove umane, resta DEVELOPMENT e non rappresenta
Content Lock, Audiovisual Lock o Release Lock approvati.

## Consegna verificata

Build: `artifacts/exports/campaign_completion_2026-09-12/Gallicus_Campaign_Candidate.exe`,
139522544 byte. SHA-256:
`679c867ca3c15efd2d31fc1e1e876bcfe7de7bfe093ee486259800f4cb38952b`.
Il manifest nella stessa directory conserva hash completi dei sorgenti,
working tree, artefatti e log. `Start Playtest.cmd` crea un profilo dedicato
nella cartella della build e lo riusa per Continue. L'EXE diretto usa invece
il profilo Gallicus standard.

| Verifica locale | Evidenza e risultato |
| --- | --- |
| 43 contratti statici | `static_delivered/testing_playbook_summary.json`, tutti verdi |
| Import, CP-02, semantica, AV, campagna e otto route | 56 passi del bundle `acceptance`; la sola Quietanza inizialmente fallita e' sostituita dalla verifica mirata `cashout_final_summary.json`, verde dopo la correzione del driver |
| Campagna reale sul renderer | `journey_complete_visual/summary.json`, verde; 178 percorsi, quattro checkpoint, 54 cicatrici, secondo processo terminale |
| Matrice visuale | 289 PNG in `artifacts/visual_qa`, conteggio esatto; `full_visual_final.log` senza ERROR |
| Estensioni localizzate | 48 PNG in `layout`; epilogo ricatturato dopo la correzione narrativa, senza figure umane |
| Import senza cache | `cold_final/summary.json`, tre successi indipendenti con permessi normali |
| Export Windows | `epilogue_corrected_export.log`, riuscito; `epilogue_corrected_pack.log`: 18 raster e 31 audio caricabili |
| EXE fuori dal progetto | `export_candidate_keyboard_summary.json`, percorso tastiera e ritorno al menu riusciti |

I percorsi abbreviati della tabella partono da `artifacts/campaign_pass/`,
salvo dove indicato. I log dei tentativi falliti restano conservati: non sono
signoff del candidato. La matrice 289 precede solo la correzione degli ID di
cicatrice e del driver smoke, senza cambi geometrici successivi; la campagna
renderizzata e le prove semantiche verificano le conseguenze corrette.
La correzione del driver ROUTE_CASHOUT e' stata verificata separatamente;
la route e i controlli statici sono stati rieseguiti, l'EXE rigenerato,
ispezionato e percorso da tastiera. La successiva correzione narrativa
sostituisce soltanto l'immagine terminale e aggiorna i documenti: l'export e
il pack sono nuovamente verificati, insieme al layout localizzato. Le prove
di gameplay e tastiera precedenti restano evidenza dello stesso codice.

Resta un warning ObjectDB durante lo shutdown del driver che ricrea la scena
piu' volte. Le due prove complete di campagna non contengono ERROR e il reboot
terminale separato passa. Nessuna nuova allowlist e nessuna eccezione al
validator sono state aggiunte. Reference docs, scan mojibake e diff check
concludono la consegna.

## Correzione narrativa richiesta dall'utente

Nella trama non esistono esseri umani. La prima illustrazione terminale
introduceva cinque figure umane: era un errore dell'agente, non contenuto
canonico. "Soggetti non classificati" non autorizzava questa interpretazione.
Il nuovo edit ImageGen rimuove figure e ombre e mantiene l'arena vuota.
Nessun cast alternativo viene inventato. Tempi, dissolvenza, movimento ridotto,
nero, battito e utility restano quelli gia' verificati.

Le catture terminali in `journey_complete_visual` documentano la vecchia
immagine e sono superate per la sola resa visiva da `layout` e dal log
`epilogue_corrected_layout.log`. Le fixture precedenti sono conservate in
`layout_before_narrative_correction` soltanto come evidenza del prima.
Asset corrente: SHA-256
`2909e736f281344598416c3305d3b1116298aa6d6d4aea2c6631bdd1178e132c`.

File toccati dalla correzione: `assets/ui/generated/registry_departure.png`,
`assets/ui/generated/manifest.json`, `docs/art_direction.md`,
`docs/asset_pipeline.md`, `docs/cinematic_direction.md`,
`docs/canon/REGISTRY_SYSTEM_SPEC.md`, `docs/development_plan.md` e questo report.
Build e manifest locali sono stati aggiornati nella cartella di consegna.

## File modificati o aggiunti

Runtime:

- `scripts/systems/run_manager.gd`
- `scripts/systems/run/run_state.gd`
- `scripts/systems/run/outcome_system.gd`
- `scripts/ui/main_menu.gd`
- `scripts/ui/registry_terminal_view.gd`
- `scripts/ui/ui_root.gd`
- `scripts/audio/music_director.gd`

Contenuto e asset:

- `assets/i18n/it.csv`
- `assets/i18n/en.csv`
- `assets/i18n/es.csv`
- `assets/i18n/it.it.translation`
- `assets/i18n/en.en.translation`
- `assets/i18n/es.es.translation`
- `assets/ui/generated/manifest.json`
- `assets/ui/generated/registry_departure.png`
- `assets/ui/generated/registry_departure.png.import`

Verifica:

- `.github/workflows/godot_smoke_runtime.yml`
- `scripts/ci/audit_runtime_contract.gd`
- `scripts/ci/campaign_runtime_contract.gd`
- `scripts/ci/campaign_runtime_contract.gd.uid`
- `scripts/ci/run_campaign_runtime_contract.py`
- `scripts/ci/check_cold_import.py`
- `scripts/ci/run_testing_playbook.py`
- `tools/campaign_review_capture.gd`
- `tools/campaign_review_capture.gd.uid`
- `tools/visual_qa_capture.gd`

Documentazione:

- `docs/README.md`
- `docs/development_plan.md`
- `docs/testing.md`
- `docs/data_schema.md`
- `docs/content_bible.md`
- `docs/audio_direction.md`
- `docs/cinematic_direction.md`
- `docs/art_direction.md`
- `docs/asset_pipeline.md`
- `docs/canon/RUN_ARCHITECTURE_CANON.md`
- `docs/canon/REGISTRY_SYSTEM_SPEC.md`
- `docs/canon/UI_CANON.md`
- `docs/support/campaign_completion_2026-09-12.md`

Build, profili e catture restano sotto `artifacts/`, ignorata da Git.
