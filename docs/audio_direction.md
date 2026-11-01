# Gallicus Audio Direction

## Chiusura del pool SFX

`SfxBus.stop_all()` interrompe le voci del pool, rilascia gli stream associati
e invalida le risposte della folla programmate prima dello stop usando una
generazione; i richiami successivi restano validi anche nello stesso millisecondo. `_exit_tree`
applica la stessa pulizia prima di rilasciare il pool e la cache; se una voce
aveva uno stream assegnato, lascia 250 ms reali al driver durante l'uscita,
senza introdurre attesa durante il gioco. Le verifiche
headless attendono anche l'elaborazione asincrona del driver in tempo reale:
la chiusura del processo non e' una prova di ascolto o di qualita' sonora.

## Tesi sonora

L'audio deve far percepire peso, procedura e conseguenza. Ogni suono nasce da
un oggetto o da uno spazio credibile: pietra, cera, bronzo, carta, ferro,
sabbia, folla e respiro.

Il mood e' rituale e amministrativo, non action-horror.

## Famiglie

| Famiglia | Materiale sonoro | Uso |
| --- | --- | --- |
| Soglia | pietra, porta, ambiente | entrata e uscita dall'arena |
| Registro | lastra, pagina pesante, incisione | apertura, consultazione, archivio |
| Firma | stilo, cera, sigillo | scelta e patto |
| Giudizio | pietra, metallo, riverbero | colpi rituali e responso |
| Quietanza | carta, monete smorzate, corda | incasso |
| Condanna | ferro, bruciatura, colpo basso | marchio e scar |
| Rilancio | doppia incisione, cera spezzata | continuazione |
| Folla | respiro collettivo, mormorio, impatto | pressione e gesto pubblico |
| Silenzio | sottrazione, ambiente sospeso | transizione del Registro |
| Assenza | singolo battito e cessazione | finale terminale |

## Mappa delle azioni

- Hover/focus: movimento materico breve, non click digitale.
- Attivazione: conferma distinta dal focus.
- Firma: attacco secco, coda corta di cera o pietra.
- Patto sigillato: colpo piu' grave e stabile.
- Gesto pubblico: risposta della folla proporzionale alla pressione.
- Colpo del sigillo: tre impatti leggibili e non identici.
- Cashout: chiusura contabile, non fanfara.
- Condanna: impatto pesante senza jump scare.
- Double: incisione aggiuntiva con tensione crescente.
- OF-03 usa il cue `registry_second_incision`: graffio asciutto nella cera e
  breve chiusura di bronzo, senza semantica level-up o fanfara.
- OF-04 usa il cue `arena_threshold_cross`: pietra sfregata, passo breve sulla
  sabbia e risposta di bronzo, senza fanfara o semantica di vittoria.
- OF-05 usa il cue `registry_table_open`: lastra che scorre, cerniera di bronzo
  e assestamento grave, senza click digitale o semantica di ricompensa.
- OF-06 usa il cue `registry_promise_sign`: graffio asciutto dello stilo nella
  cera seguito da una breve impressione di bronzo, senza click digitale o
  fanfara.
- OF-07 usa il cue `registry_pact_validate`: assestamento grave della tavoletta,
  compressione breve della cera e colpo di bronzo, senza il doppio cue
  `cursor_select` o semantica di ricompensa.
- OF-08 usa `arena_gesture_placa` per tessera deposta, sabbia che si assesta e
  respiro della folla che cala; `arena_gesture_provoca` usa graffio nella
  sabbia, colpo di pietra/bronzo e reazione breve. Entrambi sostituiscono
  `cursor_select` soltanto in questo gesto e restano mono PCM16 44,1 kHz,
  0,55-0,85 s, con picco massimo -3 dBFS.
- OF-09 usa `registry_judgment_seal_strike` per i primi due colpi: impatto
  secco di pietra e bronzo con crepa breve; `registry_judgment_seal_resolve`
  chiude il terzo colpo con peso piu' grave e cera/bronzo che serrano il
  verbale. Entrambi sostituiscono i cue generici del rito e restano mono PCM16
  44,1 kHz, con picco massimo -3 dBFS.
- END_RUN: timbro e fascicolo, differenziati dal finale terminale.
- OF-10 usa `registry_dossier_update` per carta e timbro breve,
  `registry_dossier_close` per chiusura grave e sigillo terminale, e
  `registry_dossier_route` per sollevamento della linguetta e pagina. I tre
  cue sostituiscono il click generico soltanto nel fascicolo, sono mono PCM16
  44,1 kHz e non superano -3 dBFS.

Nessuna azione importante puo' essere muta senza una ragione documentata.

## Musica

- La musica sostiene durata e pressione, non detta il risultato.
- Layer e densita' possono cambiare con il Registro senza esporre l'Era.
- Le transizioni sono graduali lungo la ramp.
- Il Silenzio sottrae layer prima di introdurre qualsiasi nuovo elemento.
- L'Assenza non usa una traccia celebrativa.

Le tracce con naming o mood demoniaco/action non sono ammesse. I 30 MP3
legacy di questo tipo sono stati rimossi dal repository il 1 novembre 2026.

## Mix

- Bus minimi: Master, Music, SFX.
- In CP-02 il bus `SFX` viene creato a runtime se assente, inviato a `Master` e
  regolato dal profilo persistente; i livelli per-cue restano invariati.
- UI e gesti critici restano leggibili sopra ambience e musica.
- Evitare picchi improvvisi su condanna e finale.
- Volumi coerenti tra SFX della stessa famiglia.
- Test su cuffie, speaker laptop e volume ridotto.

## Ere

- Era 0: ambiente completo, materiali nitidi.
- Era 1: colpi piu' asciutti e ritmo piu' rigido.
- Era 2: rare discontinuita' spaziali, mai glitch digitali.
- Era 3: meno folla, code piu' corte, maggior vuoto.
- Era 4: cessazione dell'apparato e singolo battito terminale.

## Produzione

- WAV per SFX brevi.
- Normalizzazione coerente e loop puliti.
- Nessun materiale copyrighted o con licenza ignota.
- Placeholder procedurali ammessi durante sviluppo, mai nella release se
  comunicano semantica action/combat o risultano incoerenti.
- Ogni asset deve avere owner, uso, path e stato di licenza.

### Media Vertical Slice

- L'integrazione runtime resta congelata fino alla decisione go/no-go di
  `CP-03`; il Core Playable Candidate usa soltanto audio gia' collegato o fix
  necessari alla leggibilita' del loop.
- I prototipi `MV-04` vivono in
  `docs/support/media_vertical_slice/audio_prototypes/` e non sono consumer
  runtime.
- Tre stem sincronizzati da 48 secondi rappresentano pietra, bronzo e
  aria/respiro; il mix allegato serve soltanto all'ascolto comparativo.
- L'ambience da 36 secondi e i cue di soglia/Registro sono procedurali,
  deterministici e normalizzati a -3 dBFS.
- L'adozione richiede ascolto su cuffie e speaker, verifica del seam, decisione
  esplicita sui diritti e mastering umano.
- Gli MP3 legacy senza provenienza documentata erano candidati `REPLACE` o
  `REMOVE`; sostituiti nel consumer e rimossi dal repository il 1 novembre 2026.

## Accettazione

- tutti i gesti della mappa object-first hanno un cue;
- focus e attivazione sono distinguibili;
- il mix resta leggibile in tutte le schermate;
- reduced motion non rimuove feedback audio necessario;
- impostazioni persistono correttamente;
- mute SFX a `0` silenzia il bus senza modificare o sostituire i cue;
- nessun path audio mancante o warning di import.

## Assenza nella bonifica

La richiesta ImageGen riguarda le immagini; musica e cue preesistenti non
sono nuovi asset generati. Crediti e attribuzioni sono sospesi, non approvati
per release. La bonifica esplicitamente richiesta autorizza l'integrazione
tecnica del finale oltre al freeze precedente, senza chiudere il gate umano.

Su REGISTRY_SILENCE/REGISTRY_ABSENCE MusicDirector ferma entrambe le tracce
ed il crossfade. L'Assenza presenta un battito procedurale originale: doppio
impulso grave ogni tre secondi, mono PCM16 24 kHz, nominale -20 dB, con rispetto
di Master e SFX. Nessuna melodia o registrazione esterna. Ascolto, seam e mix
su dispositivi reali restano gate umani aperti.

## Pass originale del 6 settembre 2026

L'utente autorizza VFX, animazioni, soundtrack e SFX nuovi oltre al freeze
operativo precedente. Questo pass non chiude CP-03 o Audiovisual Lock.
Il consumer corrente sostituisce tutte le registrazioni MP3 con la raccolta
originale **Pietra e Aria**: cinque composizioni da 48 secondi, 25 cue materici
e il battito terminale. Nessun campione o melodia esterna; sintesi offline
riproducibile con `tools/generate_original_audio.py` (NumPy solo in produzione).
Non e' audio generato da ImageGen o da un modello musicale.

Manifest: `assets/audio/original/manifest.json`, con ricetta, seed, hash,
formato, durata e livelli. Musica PCM16 stereo 22,05 kHz, SFX PCM16 mono
44,1 kHz; il battito conserva doppio impulso e periodo di tre secondi a 24 kHz.
Gli import Godot usano QOA; il WAV originale resta la sorgente di produzione.
I nomi cue legacy rimangono alias di contratto, con nuovi suoni privi di
semantica action/combat. I vecchi MP3 erano rimasti come sorgenti storiche
escluse dall'export; sono stati rimossi il 1 novembre 2026.

Musica: timbri morbidi di corda e risonanza minerale, armonia aperta D/A,
frasi rade, nessun drone subgrave o riser. Cinque stati usano lo stesso
linguaggio e livello nominale -7 dB, con sorgenti a picco -12 dBFS. Il cambio
stato alterna due player con crossfade di 2,2 s; rientrare nello stesso stato
non riavvia la traccia. I loop hanno endpoint nulli e spazio tra le frasi.

SFX: picco massimo -8 dBFS, hover -12 dBFS prima del gain per-cue. Pool di sei
voci; hover/focus aggregato a intervalli minimi di 120 ms e senza sottrarre
una voce attiva a un gesto. Mute applicato ai bus Music/SFX. Silenzio e Assenza
fermano musica e code SFX; un evento di fase non riattiva la musica durante
il Silenzio. Il battito usa ora un asset importato, senza sintesi nel frame
terminale. Master e slider persistenti continuano a valere.

Verifiche automatiche: `scripts/ci/test_av_asset_contract.py` e
`scripts/ci/run_av_runtime_contract.py`. Ascolto su cuffie/speaker, livello
percepito, fatigue lungo una campagna e crediti finali restano verifiche umane.

Il mix conserva headroom anche nella somma conservativa di sei SFX e due
tracce: il gain massimo nominale per-cue e' -10 dB. Il manifest dichiara
l'assistenza Astra nella composizione delle ricette di sintesi; distinguerla
dall'uso di un servizio neurale audio nel dossier di provenienza Steam.

## Verifica del collegamento al flow - 8 settembre 2026

Il percorso lineare strumentato ha riprodotto Atrium al menu, Registry da
apertura del Registro fino al push-your-luck e Dossier all'esito. Inscription
e Threshold non erano stati attivati. Il director del candidato confrontava gli ID delle
fasi canoniche, mentre run_phase_changed e' emesso dal gate PREP/LIVE/GAME_OVER
(0/1/2). Il consumer cadeva quindi su safe durante le azioni rituali.

Evidenza e registrazione del bus Music sono in
`artifacts/screen_audit_2026-09-08/`; il report e' in
`docs/support/screen_audit_2026-09-08.md`. Le 28 condizioni del contratto AV
continuano a passare: provano player e crossfade invocati direttamente,
non il collegamento completo agli eventi reali. Era la lacuna del candidato
precedente, corretta nel pass seguente.

Correzione implementata nel pass di coerenza: gli eventi realmente emessi
betting_opened, pact_sealed_opened e resolve_ritual_opened selezionano la
sezione. INTERMEDIATE_CHOICE e PUSH_YOUR_LUCK arrivano invece nel RunUiPayload
esistente: UI inoltra lo stesso payload a MusicDirector, senza nuovo bus,
segnali duplicati o decisioni di flow. PREP/LIVE non sovrascrivono la sezione.
Il gate GAME_OVER seleziona Dossier; menu, Silenzio e Assenza conservano le
guardie e i due player con crossfade di 2,2 s. Il segnale dichiarato
push_luck_opened non viene emesso dal percorso attivo: non usarlo come prova.

Il contratto AV attraversa ora menu, firma, ripresa, gesto, tre colpi,
rilancio e fascicolo e controlla stream attivo e playback. Il capture lineare
ripete il percorso e registra il bus Music; nessuna invocazione diretta del
director nelle asserzioni di integrazione. Le precedenti prove di crossfade
rimangono test di componente. Evidenze correnti in
`docs/support/consistency_fix_2026-09-08.md`.
La ramp sonora delle Ere e la fatigue all'ascolto restano prove umane aperte.

## Ramp condivisa - 12 settembre 2026

MusicDirector usa material_fade del port reattivo anche per il livello delle
composizioni: attenuazione aggiuntiva = material_fade * 28 dB, da zero a
5,88 dB. La ramp resta di tre percorsi e non espone l'Era. Brani e crossfade
sono quelli esistenti; nessuna modifica al bus o al gain dei gesti. Lo stesso
valore si applica al Continue, senza riavviare una traccia gia' attiva.
Silenzi e Assenza arrestano lo score; il battito inizia sul nero dopo il
congedo, immediatamente sul boot terminale. Ascolto e fatigue restano umani.

## Sabbia e Bronzo - 21 ottobre 2026

Su richiesta dell'utente la raccolta procedurale **Pietra e Aria** e' sostituita
da musica e cue montati da registrazioni reali gratuite. Fonti, commit e
licenze: `tools/audio/sources.json`; crediti: `docs/audio_credits.md`. Solo
CC0 1.0 e CC BY 3.0, nessuna licenza NC/ND, nessun modello neurale audio.
Ricostruzione: `python tools/audio/fetch_sources.py` poi
`python tools/audio/compose.py` (NumPy, SciPy, soundfile, pyloudnorm, ffmpeg).

Musica: cinque loop OGG da 80 s, tutti a 72 BPM in re dorico, in
`assets/audio/score/`: `atrium` (menu), `registry` (arena e patto),
`inscription` (sigillo e rito), `threshold` (SPINGI LA SORTE), `dossier`
(fascicolo). Strumenti: arpa, salterio ad arco, flauti dolci tenore e basso
come aulos e bordone, tamburo a cornice, darbuka, timpani, gong, campane.
Il tema di Gallicus (A-G-F-E-F-D) torna in ogni sezione. Loop chiusi
ripiegando code e riverbero sull'inizio. Master a -18 LUFS, MusicDirector
a -14 dB. Poiche' i loop condividono durata e griglia, il crossfade fa
partire la traccia entrante alla posizione di quella uscente: la battuta non
salta.

Gradinata: due beds sul bus `Ambience` (inviato a `SFX`, quindi regolato dal
cursore effetti). `gradinata_murmur` (voci, passi sulla sabbia, torce) sale
con la Pressione; `gradinata_rhythm` (piedi sui gradoni sui battiti 1 e 3,
mani su 2 e 4, allineato alla griglia della musica) entra sopra il 40% di
Pressione e sempre in SPINGI LA SORTE. Solo in arena, patto e rito; tace nel
menu e nel fascicolo, si ferma con Silenzio e Assenza, si dirada con la ramp
del Registro (`material_fade`).

Cue: i 25 nomi esistenti restano (stessi path e guadagni dei contratti
object-first, durate nelle finestre), rifatti con pietra, ghiaia, sabbia,
cera (guiro), bronzo (campane, gong, incudine), carta e monete. Nuovi cue:
`crowd_favor_up`, `crowd_favor_down`, `crowd_triumph`, `crowd_riot`
(da `crowd_favor_changed`, 0,35 s dopo il gesto), `coins_gain` e
`coins_loss` (da `ledger_changed`, saltati se la quietanza o il bando hanno
appena suonato), `bando_closed` (nota `BANDO CHIUSO`). Il battito
dell'Assenza e' ora una grancassa reale piano, doppio colpo ogni 3 s.
Livelli per famiglia nei file (momentary dal piu' forte tratto di 300 ms),
picco massimo -3 dBFS; un limiter su Master a -1 dB protegge gli accumuli.
Piccola variazione d'intonazione su hover, colpi del sigillo e monete.

Alcuni timbri senza registrazione libera raggiungibile (squillo delle monete,
grana della carta, coda della bruciatura, voci lontane della folla) sono
sintetizzati e sempre posati sotto un livello registrato. Restano gate umani:
ascolto su cuffie e speaker, fatica lungo una campagna, credibilita' delle
voci della gradinata.

## Racconto, posto vuoto e Banco - 1 novembre 2026

Su richiesta dell'utente ("musiche e suoni in stile coerente e sempre
gratuiti") la raccolta **Sabbia e Bronzo** si estende agli oggetti rimasti
muti o con cue presi in prestito. Stesso linguaggio e stesse fonti: re dorico,
72 BPM, griglia da 80 s, solo registrazioni gia' fissate in
`tools/audio/sources.json` (CC0 1.0 e CC BY 3.0), nessuna licenza nuova e
nessun modello neurale audio. Crediti invariati.

Musica: `racconto` (`assets/audio/score/racconto.ogg`, sezione `story` di
MusicDirector). La lira di Lauro e' il salterio pizzicato: arpeggio rapido su
ogni battuta e una breve figura cantata; arpa grave sulle fondamentali, il
tema di Gallicus sul flauto a due terzi della velocita' in due strofe (battute
4 e 14), salterio ad arco, tamburo a cornice ogni due battute, cimbalini
all'inizio delle strofe, torce vicine. Nessuna folla: la gradinata tace mentre
si racconta. Master a -18 LUFS come le altre sezioni.

Il racconto suona mentre e' visibile un dialogo della campagna
(`OpeningPrologue`) o un foglio del posto vuoto (`SeatCase`, compresi i fogli
dell'ultima Era). Le due superfici lo "tengono" con
`MusicDirector.set_story_overlay(holder, open)`: quando un dialogo passa al
foglio del posto, o un esito apre il seguito, la musica non torna al rito nel
mezzo. Gli eventi di sezione che arrivano durante il racconto aggiornano solo
la sezione di ritorno. Menu, inizio percorso, Silenzio e Assenza azzerano i
supporti; la sezione resta sulla stessa griglia, quindi il crossfade conserva
la battuta.

Cue nuovi, mono PCM16 44,1 kHz, picco massimo -3 dBFS:

| Cue | Oggetto e materiale | Uso |
| --- | --- | --- |
| `story_page` | pagina pesante, una nota della lira su La | ASCOLTA nel dialogo, passaggi interni del foglio |
| `story_close` | lira discendente La-Fa-Re-La, tamburo a cornice | ritorno al rito da dialogo o foglio |
| `seat_sheet_open` | foglio sul gradone, prima fila che tace, campana grave | apertura di caso, tracce e copia del posto |
| `seat_choice_mark` | stilo trascinato nella cera, tocco di legno | ogni risposta sul foglio, rinvio compreso |
| `final_sheet_open` | una campana un'ottava sotto, carta lenta, nessuna folla | L'ULTIMA CIFRA e L'ULTIMO FOGLIO |
| `banco_purchase` | monete contate sul banco di legno, ricevuta, timbro | acquisto al Banco, al posto di `registry_table_open` |

`banco_purchase` entra nella finestra che salta `coins_loss` dopo un cue con
monete proprie. `story_page` e `seat_choice_mark` hanno una piccola variazione
d'intonazione come hover e monete.

Produzione: `tools/audio/compose.py --names <nomi>` scrive soltanto i brani o
cue indicati e conserva i file gia' spediti, perche' versioni diverse di
NumPy/SciPy cambiano gli ultimi bit di un render. Comando usato:
`python tools/audio/compose.py --names racconto,story_page,story_close,seat_sheet_open,seat_choice_mark,final_sheet_open,banco_purchase`.
Il manifest elenca ora 47 asset (8 loop, 39 cue). Analisi del loop: picco
-1,2 dBFS, re e la come classi dominanti e quota fuori modo pari a `dossier`.
Restano gate umani: ascolto su cuffie e speaker, giunzione del loop,
fatica della lira lungo i dialoghi di una campagna.

### Ombra: strati di rischio

Direzione approvata dall'utente, con una richiesta in piu': tracce piu' cupe
secondo il tipo di percorso, quasi situazionali in base al rischio. La sezione
musicale non cambia; sotto di lei sale uno strato scuro sulla stessa griglia.

| Sezione | Strato | Materiale |
| --- | --- | --- |
| `safe` (arena e patto) | `registry_ombra.ogg` | fondo di salterio ad arco due ottave sotto, bordone abbassato di un'ottava, battito doppio ogni due battute |
| `tense` (sigillo e rito) | `inscription_ombra.ogg` | fondo, lamento del flauto basso La-Si bemolle-La sulle battute di re minore, battito a ogni battuta, rulli gravi di timpano, gong strisciato |
| `climax` (SPINGI LA SORTE) | `threshold_ombra.ogg` | battito su 1 e 3, rintocco d'incudine ogni due battute, lamento, gong strisciato |

Solo fondamentali e quinte della progressione condivisa: lo strato non
contrasta l'arpa. Il buio viene dal registro, dalla sesta minore su re minore
e dal battito doppio, lo stesso con cui finira' l'Assenza, qui ancora lontano.
Strati masterizzati a -22 LUFS; baricentro spettrale 650-870 Hz contro
1600-2100 Hz delle sezioni.

Rischio, solo presentazione e solo da cio' che il giocatore vede gia':

- famiglia del patto firmato (`rank` in `BetCatalog.PACT_FAMILY_PROFILES`,
  da "Regge spesso" a "Regge di rado"), peso 0,45: e' il tipo di percorso;
- Pressione, peso 0,35;
- debito, +0,10;
- Segni, +0,05 ciascuno fino a tre.

Sotto 0,2 lo strato tace; da 0,2 a 1 sale da -18 dB al livello nominale della
musica, e la sezione cede fino a 3 dB. Dissolvenze di 3 s, avvio alla stessa
posizione della sezione. Menu, racconto e fascicolo non hanno strato; Silenzio
e Assenza lo fermano; la ramp del Registro (`material_fade`) lo attenua come
il resto. `MusicDirector` legge il `rank` dal catalogo dei contenuti su
`bet_placed`: nessuna regola o esito cambia. Limite noto: dopo una ripresa da
salvataggio il `rank` torna a 0 finche' non si firma il patto successivo;
Pressione, debito e Segni restano attivi.

Comando: `python tools/audio/compose.py --only music --names registry_ombra,inscription_ombra,threshold_ombra`.
Il manifest elenca 50 asset (11 loop, 39 cue). Il contratto AV verifica che
il rischio alzi soltanto lo strato della sezione corrente, che debito e Segni
lo scuriscano, che un patto reale imposti il `rank` e che il Silenzio lo
fermi; il calcolo dell'headroom include uno strato a pieno rischio. Restano
umani: soglia e pesi del rischio, leggibilita' sopra i cue, fatica del battito.

Pulizia dello stesso giorno, su richiesta dell'utente: rimossi i 30 MP3 legacy
in `assets/audio/` (nomi e mood demoniaco/action, provenienza mai
documentata, 67,7 MB con gli `.import`). Nessun consumer runtime li caricava.
Il preset continua a escludere `assets/audio/*.mp3` e
`scripts/ci/inspect_export_assets.gd` rifiuta ogni MP3 nel pack, cosi' non
possono rientrare per errore.
