# Gallicus: percorso di pubblicazione Steam

## Traguardo e stato

Pubblicare Gallicus 1.0 come campagna finita Windows x64 in IT/EN/ES.
La roadmap di prodotto resta in `docs/development_plan.md`; questa procedura
copre distribuzione e lancio. Early Access, demo, achievement, Steam Cloud e
supporto Steam Deck non entrano automaticamente nello scope.

Snapshot del 6 settembre 2026:

| Area | Stato verificato | Evidenza o passo necessario |
| --- | --- | --- |
| Gioco | `DEVELOPMENT` | CP-03 e validazione completa della campagna aperti |
| Build locale | export Windows con pass audiovisivo e percorso da tastiera verificati localmente | `docs/support/av_pass_2026-09-06.md`; anomalia cold import Windows aperta |
| Checkpoint Linux della nuova build | aperto | le firme CP-02 appartengono ai loro commit |
| Asset originali | 17 raster ImageGen e 31 audio da sintesi originale | manifest in `assets/ui/generated/` e `assets/audio/original/` |
| Diritti, crediti e audio | gate aperto; MP3 precedenti esclusi dalla build | provenienza registrata; ascolto umano, crediti e verifica finale da completare |
| Partner, AppID, fee, permessi | non verificati | leggere lo stato Steamworks con il titolare |
| Store, Coming Soon, review build | non verificati | registrare stato e data dal portale |
| Data e prezzo | non confermati in questo percorso | decisione del titolare |

"Non verificato" non significa assente. Non registrare credenziali, dati
bancari o fiscali nel repository. Ogni aggiornamento di stato riporta data,
responsabile ed evidenza; le checkbox sono in `docs/release_checklist.md`.

## Sequenza di consegna

| Passaggio | Lavoro | Prova di chiusura |
| --- | --- | --- |
| Preparazione partner | verificare account, onboarding, AppID, fee e permessi; nominare chi pubblica | stato del portale e vincoli di calendario annotati |
| Preparazione store | descrizioni IT/EN/ES, capsule, icone, screenshot di gameplay, trailer rappresentativo, requisiti, contatto supporto e prezzo proposto | materiali revisionati contro il gioco reale |
| Coming Soon | completare survey e checklist store, inviare alla review e pubblicare la pagina approvata | esito review e data di visibilita' pubblica |
| Candidato Steam | completare gate prodotto, configurare depots e avvio, caricare e provare dal client | commit, manifest/hash, BuildID e verbale di installazione |
| Review build | inviare build quasi finale e configurazione previste per la release | esito Valve e correzioni verificate |
| Lancio | confermare checklist, build distribuita, prezzo e data; eseguire pubblicazione autorizzata | pagina acquistabile e installazione della build pubblica |
| Verifica dopo il lancio | provare avvio, lingua, save/resume e raccogliere segnalazioni | esito annotato, responsabile supporto e procedura hotfix |

La preparazione store puo' procedere durante i gate del gioco. Non richiede
di anticipare nuove feature o dichiarare concluso CP-03. La pubblicazione
del gioco richiede tutti i gate; Coming Soon e' una consegna separata.

Valve richiede due checklist e review distinte, store e build; la store
presence va inviata prima della build. Per la review della build occorre
caricare il candidato sul branch default. La release non avviene in automatico
dopo l'approvazione.
[Release Process](https://partner.steamgames.com/doc/store/releasing).

## Calendario da confermare prima di annunciare il lancio

- Prevedere almeno due settimane di pagina Coming Soon pubblica prima
  dell'uscita. [Release Process](https://partner.steamgames.com/doc/store/releasing).
- Verificare l'attesa Steam Direct di 30 giorni dal pagamento della fee,
  prevista per i primi titoli, e la data effettiva abilitata per l'AppID.
  [Steam Direct](https://partner.steamgames.com/steamdirect).
- Store e build hanno normalmente review di 3-5 giorni lavorativi; Valve
  raccomanda di prevederne almeno 7 per ciascuna, incluse possibili correzioni.
  [Review Process](https://partner.steamgames.com/doc/store/review_process).

Questi tempi sono vincoli, non una data promessa. Le attese possono
sovrapporsi: pianificare dalla dipendenza piu' tardiva tra portale, review,
Coming Soon e gate interni. Fonti verificate il 6 settembre 2026; ricontrollare
le regole e il calendario dell'AppID prima di ogni invio o annuncio.

## Materiali fedeli alla build

Le capsule devono avere titolo/logo leggibile; gli screenshot store devono
mostrare gameplay. Le funzionalita' dichiarate devono essere disponibili
nella build, senza presentare promesse future come gia' rilasciate.
[Review Process](https://partner.steamgames.com/doc/store/review_process).

Per Gallicus usare il marchio originale e il tema approvato, mantenendo
riconoscibile il ritual loop. Catturare immagini e trailer dalla build
identificata, controllare testi nelle tre lingue e leggibilita' delle capsule
nei formati correnti Steamworks. I mockup ImageGen non sono screenshot di
gameplay. Linux e' la superficie CI: non dichiarare una release Linux o
compatibilita' Deck solo perche' quella CI e' verde. Misurare i requisiti
hardware sulle macchine di prova, senza inventarli.

## Contenuti generati e provenienza

Il Content Survey precede le review. La sezione AI riguarda contenuti
distribuiti e fruiti dai giocatori, inclusi arte, audio, narrativa e
localizzazione; distingue contenuti pre-generati e generati durante il gioco.
[Content Survey](https://partner.steamgames.com/doc/gettingstarted/contentsurvey).

Preparare l'inventario dal manifest ImageGen e dagli asset realmente inclusi
nell'export; verificare anche copy, traduzioni e audio, senza limitare la
dichiarazione ai 16 raster attuali. L'uso di Astra per sviluppare non introduce
da solo generazione live nel runtime. Il titolare verifica la descrizione
finale rispetto al questionario corrente e ai contenuti, comprese le sezioni
generali e mature. La bozza non vale come survey inviato.

La sostituzione delle immagini non risolve le attribuzioni dei pacchetti
audio rimasti. Il rinvio autorizzato durante la bonifica resta consentito
in sviluppo; crediti e provenienza devono essere chiusi prima del rilascio.
La generazione originale non sostituisce questa verifica.

## Accettazione della build distribuita

Prima dell'upload identificare un candidato riproducibile con commit,
manifest dell'export e SHA-256. Registrare poi AppID, DepotID, BuildID,
branch, configurazione di avvio e data di prova. Le istruzioni tecniche di
upload vanno verificate sulla documentazione
[SteamPipe](https://partner.steamgames.com/doc/sdk/uploading).

Procedura di progetto, in aggiunta a `docs/testing.md`:

1. Provare la build su branch di test e installarla tramite client Steam
   su Windows pulito, fuori dal repository e senza Godot installato.
2. Controllare che parta dal client, contenga le dipendenze necessarie e
   non includa profili personali, strumenti dev o flag smoke nell'avvio normale.
3. Verificare IT/EN/ES, mouse/tastiera, impostazioni, audio, nuovo profilo,
   uscita e ripresa; controllare anche save migration da schema supportato.
4. Verificare aggiornamento da una build precedente, conservazione dei save
   e comportamento dopo il finale. Classificare warning noti e log di chiusura;
   un'allowlist tecnica non chiude da sola un problema di release.
5. Ripetere le verifiche influenzate da ogni modifica al candidato e controllare
   il BuildID effettivo su default prima di review e lancio. Collegare le tre
   campagne umane e la CI Linux al candidato, senza riusare firme obsolete.
6. Conservare il riferimento all'ultima build stabile e preparare una
   procedura di ripristino compatibile con i save; non presumere che un
   downgrade dell'eseguibile possa leggere uno schema piu' recente.

## Responsabilita' e chiusura

Astra prepara documenti, materiali e verifiche entro la richiesta. Il titolare
decide dati commerciali, prezzo, data e autorizza le operazioni sul portale.
Preparare tutto il necessario prima della decisione finale, senza richiedere
di nuovo autorizzazioni gia' concesse per la stessa azione.

Questo workflow non autorizza pagamenti, upload, invii a review, modifiche
pubbliche o pubblicazione. Il signoff `SIGNED FOR GALLICUS 1.0` attesta il
prodotto; lo stato di distribuzione diventa `PUBLISHED ON STEAM` solo dopo
release effettiva e verifica della build pubblica. Registrarli separatamente.
