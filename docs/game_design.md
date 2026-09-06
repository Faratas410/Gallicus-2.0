# Gallicus Game Design

## Fantasia centrale

Il giocatore non interpreta Felix e non combatte nell'arena. E' il soggetto
esposto a un apparato che trasforma ogni promessa in prova amministrativa.
Giocare significa scegliere quale atto rendere registrabile e quale costo
accettare per rimandare o forzare una definizione.

## Loop di run

1. Oltrepassare la soglia dell'arena.
2. Aprire il Registro e leggere due offerte.
3. Indicare e firmare una promessa.
4. Riconoscere il patto sigillato.
5. Compiere un gesto davanti alla gradinata.
6. Colpire il sigillo e ottenere un responso.
7. Prendere una quietanza, accettare un marchio o incidere un rilancio.
8. Chiudere, aggiornare o proseguire il fascicolo.

## Loop di campagna

```text
run -> evidenza -> firma comportamentale -> convergenza
-> Silenzio -> mutazione del Registro -> nuova run
```

La campagna termina quando il Silenzio dell'ultima Era produce l'Assenza del
Registro. Questa fine non e' vittoria, sconfitta o liberazione dichiarata:
cessa la classificazione.

## Sistemi

- **Bet:** promessa esplicita con rischio e conseguenza.
- **Patto:** vincolo firmato che rende l'atto irreversibile.
- **Pressione:** presentazione leggibile dell'escalation corrente.
- **Scars:** memoria persistente di un costo accettato.
- **Condanne:** registrazioni avverse, non errori generici.
- **Path:** famiglie interpretative derivate dalle scelte.
- **Firma comportamentale:** profilo interno e multidimensionale.
- **Registro:** apparato impersonale che osserva e conclude.
- **Ere e Silenzi:** struttura finita della campagna.
- **Archivio:** superficie di consultazione della conoscenza ottenuta.

## Regole di scelta

- Il costo deve essere leggibile prima dell'atto.
- Il player puo' essere incerto sull'interpretazione, non sul comando.
- Una scelta bloccata mostra la causa senza esporre formule interne.
- Nessuna scelta e' falsa per ottenere sorpresa.
- Il rischio non viene alterato di nascosto dalle Ere.
- Ripetere una condotta produce memoria, non power scaling.

## Object-First

Le azioni gameplay seguono `docs/object_grammar.md`:

```text
intento -> oggetto -> gesto -> feedback -> registrazione
```

Il bottone puo' essere l'input tecnico, ma non deve essere il concept. Utility
come volume, lingua, risoluzione, back e quit usano convenzioni accessibili.

## Progressione

La progressione persistente riguarda conoscenza e classificazione:

- nuove offerte o letture diventano possibili;
- scars e condanne cambiano l'evidenza disponibile;
- il Registro modifica gradualmente tono e struttura;
- l'Archivio conserva cio' che e' stato definito;
- il giocatore non accumula statistiche di potere.

## Durata e ritmo

- Prima campagna target: 2-4 ore.
- Una run deve essere abbastanza breve da invitare una nuova promessa.
- Ogni run deve produrre almeno una conseguenza o informazione memorabile.
- Le transizioni tra Ere non devono sembrare capitoli dichiarati.
- La ripetizione e' ammessa solo quando il contesto ne cambia il significato.

## Non obiettivi

- combat, nemici o controlli avatar real-time;
- build, equipaggiamento o skill tree;
- economia espandibile;
- missioni giornaliere o loop infinito;
- personificazione morale del Registro;
- Felix come guida, boss o modello da imitare.

## Verifica

- I cambi di regola aggiornano `docs/canon/MECHANICS_UNIFIED.md`.
- I cambi di flow aggiornano `docs/canon/RUN_ARCHITECTURE_CANON.md`.
- I cambi player-facing compilano la scheda object-first.
- I cambi UI visibili richiedono QA visuale.
- I cambi alla campagna richiedono save, determinismo e playtest completo.

## Stato della spine tecnica

La bonifica implementa firma persistente, isteresi, ramp, Silenzi ed Assenza
con guardia al riavvio. Il Registro conserva una lettura delle scelte fino a
cessare la classificazione. La prova accelerata verifica raggiungibilita',
non ritmo o durata target; messa in scena e anti-farming richiedono playtest.
