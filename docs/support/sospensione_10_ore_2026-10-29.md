# Gallicus: stato alla sospensione dell'obiettivo - 29 ottobre 2026

Ripresa: l'utente ha riattivato l'obiettivo il 29 ottobre. Il primo pacchetto
(baseline e mappa degli eventi) e' in
`docs/support/baseline_economia_ritmo_2026-10-29.md`; questo documento resta
il passaggio di consegne della sospensione precedente.

## Allineamento della base - 29 ottobre 2026

La PR #541 e' stata unita su richiesta; la revisione e' stata preparata sulla
base del merge `8a298b3d2b665812191754370f1b9f2552e6607a`. Il candidato
include il lavoro delle dieci ore e la correzione audio. La fotografia del lavoro locale
precedente, con hash verificati, e i 14 file rimossi dalla base upstream sono
conservati in `artifacts/pre_alignment_2026-10-29/`.
Godot 4.7.2 ha reimportato la copia finale e il playbook e' passato 51/51
anche nel checkout principale: `artifacts/alignment_main/playbook/testing_playbook_summary.json`.
Campagna, riavvio terminale e verifica separata del reset sono passati sul
profilo isolato; i log di campagna non riportano errori o warning. Sono prove
Windows locali, non accettazione Linux, audiovisiva o di durata umana.

### Chiusura audio: candidato del 29 ottobre

Revisione successiva: la cancellazione dei richiami differiti usa una
generazione invece dell'orologio, cosi' un nuovo richiamo nello stesso
millisecondo dello stop resta valido. Il tempo di tenuta del sigillo torna a
0,8 secondi, come sulla base precedente: l'aumento a 1,8 non aveva un
riscontro umano sul ritmo. Le verifiche del candidato precedente non sono
trasferibili automaticamente a queste modifiche.

La diagnosi ha identificato playback del driver Dummy ancora attivi alla
chiusura, anche quando il contratto di gioco aveva raggiunto il suo marker.
Nel candidato `SfxBus` arresta le voci, rilascia gli stream, invalida i
richiami differiti e lascia al driver 250 ms reali in uscita se era stato
assegnato uno stream. Non introduce attese durante il gioco. Un contratto
dedicato avvia una voce e chiude immediatamente; un altro verifica lo stop e
l'annullamento dei richiami. La chiusura dei fixture attende il driver senza
modificare le asserzioni del runner. Le ripetizioni e i log sono nella cartella
`artifacts/alignment_2026-10-29_v3/candidate/artifacts/`; si tratta di prove
Windows headless, non di ascolto umano ne' del checkpoint Linux.

La ripetizione finale del playbook sul candidato aggiornato e' **51/51**:
`artifacts/alignment_2026-10-29_v3/candidate/artifacts/alignment_final2/testing_playbook_summary.json`.
Il runner include i due nuovi contratti audio, arriva all'Assenza e supera il
riavvio terminale; i log di campagna non riportano errori o warning. Le prove
di uscita immediata ripetute quattro volte sono terminate senza leak. WSL non
risulta installato: checkpoint Linux non eseguito. La verifica visiva umana,
l'ascolto e la durata effettiva della campagna restano aperti.

La correzione e i test sono stati applicati anche al checkout principale:
`scripts/audio/sfx_bus.gd`, `scripts/ci/audio_test_teardown.gd`,
`scripts/ci/audio_shutdown_contract.gd`,
`scripts/ci/audio_abrupt_shutdown_contract.gd`,
`scripts/ci/run_campaign_runtime_contract.py`, i contratti di caso, confronto,
memoria, copia, richiamo, quietanza e campagna, oltre a `docs/audio_direction.md`
e `docs/testing.md`. La revisione successiva e' descritta nel rapporto pre-commit.

Prima dell'allineamento il checkout era fermo a `b81a4fc`, dieci commit dietro
`a11b163`; la testa della PR era `744d5cf`. Essa includeva la base aggiornata
e una prova visiva del rito.
Le simulazioni economiche in questo rapporto e nel rapporto di campagna sono
state condotte sulla base precedente al riequilibrio `d4d5225`: sono evidenza
storica, non un bilanciamento valido per il candidato aggiornato.

Una bozza isolata in `artifacts/alignment_2026-10-29_v3/candidate` combina la
testa della PR e il lavoro locale usando la fotografia `9e40866` come base di
confronto. L'import Godot 4.7.2 e' terminato. Il primo playbook Windows aveva
50 passi riusciti su 51: il contratto di campagna si interrompeva dopo il
marker della quietanza per risorse audio ancora in uso alla chiusura. Il test
seed e lo smoke FULL_RUN passano; il runner non e' arrivato al viaggio.
La pulizia del pool audio nel candidato ha superato una prova isolata, ma non
aveva eliminato il problema nel playbook; la correzione successiva e' descritta
sopra. Riepilogo storico e log nel
candidato sotto `artifacts/alignment_playbook/`. La cartella e' un artefatto
locale ignorato; il contenuto sorgente e' stato poi applicato a `main`.
Sei contratti del posto e dell'ordine dei racconti sono passati separatamente;
un contratto aggiuntivo ha verificato che reset e ricaricamento cancellino
scelta, confronto, copia e conto. Una seconda prova del runner ha superato la
quietanza, ma si e' fermata sulla chiusura audio del contratto della copia.
Il contratto di viaggio lanciato direttamente su profilo isolato raggiunge
l'Assenza al percorso 50 e il marker di completamento, senza errori di uscita
nel log `artifacts/direct_campaign.log` del candidato. Non sostituisce il
runner completo, ne' una prova umana; qui diverse scene del posto risultano
concentrate nel percorso 16, confermando il rischio di ritmo della revisione.
Restano da valutare la coerenza della prova pixel con le revisioni visuali
successive e il comportamento percepito da persone. Conservare le modifiche
locali esistenti fino alla revisione dell'utente.

La revisione del 29 ottobre segnala quattro punti progettuali da valutare:
confronto delle tracce troppo simile a un quiz, scene concentrate prima della
firma, valore della copia legato a cinque polizze nella stessa Era e possibile
ripetizione della battuta in gradinata. Non sono considerati risolti dai test
tecnici. Obiettivo e criteri delle dieci ore restano da definire e misurare con
persone; non estendere per inerzia le decisioni di direzione contestate.

L'obiettivo delle circa dieci ore e' in pausa su richiesta dell'utente. Questo
documento e' un passaggio di consegne, non una dichiarazione di completamento.
La ripresa richiede una nuova indicazione dell'utente. La revisione usa come
base il merge `8a298b3`; consultare `git status` e i documenti correnti prima
di intervenire. Il merge della PR e' stato effettuato su richiesta.

## Fatto

- Analizzati il ciclo rituale, la progressione, l'economia e le prime prove di
  campagna. La correzione della quietanza valuta il debito prima del premio del
  bando; un contratto dedicato verifica il caso. La selezione degli intenti
  della folla usa il seed salvato della run. Metodi, simulazioni, limiti e
  riferimenti ai file sono in `docs/support/campagna_economia_2026-10-28.md`.
- Realizzato un primo arco giocabile attorno al posto vuoto: scelta iniziale
  con due vie e rinvio, confronto delle tracce, reazioni dei personaggi e
  scelta tra custodia gratuita e copia per Nerio a 5 Denari. La copia da' uno
  sconto di 1 Denaro sulle polizze fino al prossimo Silenzio. Persistenza,
  ripresa, rami e condizioni economiche hanno contratti locali dedicati; una
  campagna automatica ha raggiunto l'Assenza anche con la copia pagata.
- Redatto il rapporto `docs/support/anima_gallicus_2026-10-29.md`. La sua
  lettura guida e' «L'arena dimentica. Il Registro no»: firma, folla, corpo,
  conti e testimonianze producono memorie diverse, senza risolvere il mistero
  con una spiegazione totale. L'arco del posto traduce parte di questa direzione
  in scelte e conseguenze; il loro effetto emotivo resta da provare con persone.
- Raccolte catture e verifiche locali per le nuove superfici e i dialoghi,
  incluse le tre lingue e due risoluzioni nei fixture indicati nei report.
  Solo alcune immagini sono state ispezionate: non equivalgono ad accettazione
  visiva completa, prova audio o sessione umana.

## Da fare alla ripresa

1. Progettare e realizzare contenuto effettivamente nuovo per l'intera campagna,
   con problemi, personaggi, scelte e conseguenze distribuiti nel tempo. Le
   quattro parti proposte nel rapporto economico sono un'ipotesi, non contenuto
   gia' integrato. Non allungare attese o ripetere run identiche per fare volume.
2. Verificare l'accesso ai racconti nei diversi stili: quattro hanno una via
   per Era, gli altri dipendono dai bandi e dopo il congedo non sono piu'
   proposti. Decidere quali contenuti debbano essere accessibili a chi gioca
   prudentemente e valutare le conseguenze sulle motivazioni dei bandi.
3. Continuare il bilanciamento economico con piu' seed e strategie, compresi
   debito, mancati acquisti e la durata variabile dello sconto; verificare con
   giocatori se costi, benefici e alternative sono comprensibili e desiderabili.
   Le simulazioni automatiche sono indizi, non preferenze umane.
4. Rivedere il percorso completo e la coerenza audiovisiva in sequenza, in
   particolare il portico e i dialoghi illustrati rispetto al Registro pixel
   art. Validare stati reali, IT/EN/ES, 720p/1080p, controller, audio e
   accessibilita'; ottenere la valutazione umana delle schermate.
5. Misurare con sessioni umane la durata attiva, la ripetizione percepita,
   le scelte, gli abbandoni e la comprensione del rapporto fra gesto e memoria.
   Il traguardo di circa 10 ore e il coinvolgimento non sono verificati.
6. Dopo aver deciso le meccaniche, esaminare e ottimizzare il codice senza
   spostare le ownership di `RunManager` e `GameEvents`. Indagare gli avvisi
   ObjectDB e gli errori di risorse segnalati da alcune esecuzioni in chiusura;
   una campagna che raggiunge l'Assenza non prova l'assenza di perdite.
7. Rieseguire le verifiche pertinenti sul candidato finale e completare il
   checkpoint Linux canonico e i gate umani. La pubblicazione Steam segue
   `docs/steam_release.md` e richiede le autorizzazioni previste.

## Dove trovare le prove

- `docs/support/campagna_economia_2026-10-28.md`: correzioni, scelte, file,
  risultati automatici, catture e loro limiti, fino alla polizza sulla copia.
- `docs/support/anima_gallicus_2026-10-29.md`: lettura dell'identita', rischi,
  criteri di progettazione e prove disponibili.
- `docs/development_plan.md`, `docs/testing.md` e i documenti canonici restano
  gli owner operativi e delle regole; questo riepilogo non li sostituisce.
