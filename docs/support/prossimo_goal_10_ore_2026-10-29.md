# Prossimo goal: Gallicus verso circa dieci ore

## Mandato proposto

Portare la campagna finita di Gallicus verso circa dieci ore di contenuto
significativo, preservando firma, rischio, folla, memorie discordanti e Assenza.
Partire dalle criticita' di economia e ritmo, verificare le meccaniche e il
percorso, produrre contenuto e schermate coerenti in sequenza e ottimizzare il
codice dopo aver definito le regole. Il risultato deve essere misurato con
persone: le simulazioni non determinano durata o coinvolgimento.

Questo documento prepara il lavoro: non riattiva l'obiettivo sospeso, non
approva un nuovo bilanciamento o una direzione visiva e non autorizza release.
Base locale verificata alla preparazione: `main` al commit
`8df5f7b82ffcd6697b05ad4b3c83cce26da751cf`, pulito. All'avvio ricontrollare
HEAD, stato, remoto e regole locali; associare ogni prova al candidato effettivo.

## Problemi di partenza

1. Le simulazioni storiche precedono il riequilibrio `d4d5225`: non sono una
   baseline affidabile per prezzi, progressione o recupero del debito correnti.
2. L'arco del posto puo' concentrare scelte e scene prima della stessa firma;
   il confronto e' guidato, il richiamo in gradinata puo' ripetersi e il valore
   della copia a 5 Denari dipende dal numero di polizze fino al Silenzio.
3. Alcuni racconti richiedono gradini del bando e non vengono piu' proposti
   dopo il congedo. Gli stili prudenti possono vedere meno contenuto.
4. Il progetto non dispone di una misurazione umana di circa dieci ore, ne'
   di prove sufficienti sulla varieta' percepita e sulla coerenza audiovisiva.

## Sequenza proposta

### 1. Baseline economica e del percorso

- Verificare il simulatore sulla base corrente: seed, esito reale della
  quietanza, ripresa, pagamento, sconto, reset e rilevazione degli errori. Usare
  profili isolati e conservare log, configurazione, commit e stato dei file.
- Eseguire la matrice esistente con tre seed e tre policy (`bando_selective`,
  `bando_never`, `prudent_never`). Completare con confronti controllati che
  cambino un solo fattore alla volta: copia pagata o custodia, debito iniziale
  e strategia del Banco. Registrare anche i fallimenti; una policy che cambia
  piu' comportamenti non dimostra la causa di una differenza.
- Per percorso e per Era rilevare saldo iniziale/finale e minimo, entrate e
  uscite per causa, tempo e percorsi in debito, acquisti e polizze scontate,
  bandi e scadenze, Segni, Pressione, scelta del posto, contenuti visti e
  mancati, transizioni e conclusione. Verificare copertura e denominatori.
- Consegnare una tabella con risultati, casi non validi, limiti e ipotesi;
  nessuna modifica dei prezzi solo per eliminare l'accumulo simulato.

### 2. Ritmo, accessibilita' dei contenuti e scelte

- Mappare gli eventi realmente raggiungibili dalla prima firma all'Assenza,
  compresi rinvio, salvataggio, resume, reset, debito e congedo. Individuare
  le concentrazioni e le scene essenziali mancabili per stile di gioco.
- Proporre alternative concrete per distribuire l'arco del posto, evitare il
  quiz ovvio e limitare la ripetizione; per ciascuna specificare trigger,
  prezzo, alternative, conseguenze visibili, persistenza, fine della run e
  cosa succede se l'Assenza arriva prima. Preservare i dati dei profili esistenti.
- Confrontare il costo della copia e il suo beneficio con la custodia gratuita;
  non imporre una spesa o un bonus soltanto per assorbire valuta. Definire
  criteri di rifiuto, inclusi scelta non comprensibile e conseguenza non visibile.
- Fare un playtest senza suggerimenti e confrontare cosa le persone capiscono,
  scelgono e ricordano. Decidere ritmo, costi e modifiche al canone con l'utente
  prima di fissare una soluzione che cambi il significato dell'arco.

### 3. Espansione della campagna

- Progettare una mappa di contenuto per tutta la campagna: problemi nuovi,
  personaggi, scelte, conseguenze e connessioni fra Registro, conti, corpo e
  gradinata. I quattro atti del rapporto precedente sono una sola ipotesi.
- Per ogni aggiunta dichiarare come entra nel loop, varianti e costi, finestre
  di accesso, ordine, stato persistente, resume/reset, fine e compatibilita'
  con le altre scelte. Predisporre un verticale giocabile prima di ampliarlo.
- Per le schermate partire dagli oggetti e dalle reference approvate, una
  schermata alla volta; preparare HTML locale per le revisioni UI, confrontare
  prima/dopo nello stesso stato e risoluzione, quindi raccordare le successive
  dopo la valutazione. Verificare IT/EN/ES e 720p/1080p.
- Non ottenere il target con attese piu' lunghe o run identiche: misurare
  tempo attivo e contenuto distinto per tratto, pause e abbandoni separati.

### 4. Consolidamento e accettazione

- Quando le regole sono stabilizzate, eliminare duplicazioni e costi tecnici
  misurati senza spostare l'autorita' di `RunManager`, `GameEvents` o dei save.
  Aggiornare canon, dati, test e documenti di dominio per ogni cambio.
- Eseguire contratti mirati e playbook sul candidato esatto; controllare
  import, chiusura, save e ripresa. Completare il checkpoint Linux canonico e
  verifiche umane di percorso, controller, accessibilita', audio e visuale.
- Condurre campagne umane complete anche in piu' sessioni: registrare tempo
  attivo, pause, assistenza, blocchi, abbandoni, ripetizione percepita e scelte.
  La mediana e la distribuzione delle prime campagne, non un singolo risultato,
  informano la valutazione del target. Non escludere abbandoni dal resoconto.

## Primo pacchetto alla ripresa

Baseline economica e mappa degli eventi, senza ritoccare prezzi, ritmo o
contenuto. Deliverable: matrice riproducibile, risultati e log dei casi
falliti, inventario delle scelte e dei racconti per stile, primi punti di
blocco e proposta comparabile per l'arco del posto. Concludere con le decisioni
da prendere e le prove necessarie prima del primo cambiamento di gameplay.

## Condizioni di completamento del goal

- Una campagna completa, con contenuto e scelte distribuiti e conseguenze
  osservabili; nessun ramo essenziale perso senza una scelta consapevole.
- Economia verificata su piu' strategie e seed e valutata con persone, inclusi
  debito e utilizzo effettivo delle alternative; limiti e anomalie registrati.
- Durata prossima alle dieci ore sostenuta da campagne umane, con metodo,
  distribuzione e abbandoni riportati, senza padding artificiale.
- Coerenza del percorso e delle schermate valutata su stati reali nelle lingue
  e risoluzioni previste, con input e accessibilita' separatamente verificati.
- Verifiche tecniche sul candidato finale, checkpoint Linux e accettazione
  umana completati; nessuna equivalenza fra test automatici e divertimento.

Riferimenti: `docs/support/campagna_economia_2026-10-28.md`,
`docs/support/revisione_pre_commit_10_ore_2026-10-29.md`,
`docs/support/anima_gallicus_2026-10-29.md`, `docs/playtest_guide.md`,
`docs/testing.md`, `docs/development_plan.md` e i rispettivi canon.
