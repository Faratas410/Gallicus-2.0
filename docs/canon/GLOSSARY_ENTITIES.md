# CANON — GLOSSARY ENTITIES

Status: Single source of truth

If another doc conflicts, this doc wins.

Last merged from: docs/the_register.md, docs/felix_gallicus.md, docs/registry_silence.md, docs/registry_corruption.md, docs/scar_system.md, docs/bet_progression.md, docs/meta_progression.md, canon addendum "Registro, Precedente e Seconda Era"

## Canon Contract

This document is authoritative for its category.
No other file may redefine these concepts.
All changes to systems described here must update this document in the same PR.


## Index

- [The Register](#the-register)
- [Felix Gallicus](#felix-gallicus)
- [Owls (Gufi)](#owls-gufi)
- [Registry: Silence](#registry-silence)
- [Registry: Corruption](#registry-corruption)
- [Scar](#scar)
- [Bet](#bet)
- [Meta progression](#meta-progression)
- [Run](#run)
- [End state](#end-state)
- [Condemnation](#condemnation)
- [Pact](#pact)

## The Register

Type: Entity

One-liner: Infrastruttura diegetica impersonale che registra pattern di rischio e convalida irreversibilità.

Details: Sistema amministrativo non morale; parla raramente con tono freddo.

Appears in: Run / Meta

Related: Felix Gallicus, Scar, Registry: Silence, Registry: Corruption

## Felix Gallicus

Type: Entity

One-liner: Anomalia d’archivio: caso precedente non classificabile dal Registro.

Details: Non appare in scena; emerge come precedente nei log.

Appears in: Meta / Run

Related: The Register, Final narrative structure

## Owls (Gufi)

Type: Institution

One-liner: Amministrazione dell’Arena che gestisce Registro, quote e legittimazione spettacolare del rischio.

Details: Non sono entità soprannaturali né autorità morali; operano come apparato gestionale che monetizza instabilità e reiterazione dopo il precedente.

Appears in: Lore / Meta

Related: The Register, Registry Precedent State, Felix Gallicus

## Registry: Silence

Type: State

One-liner: Stato/manifestazione narrativa del Registro legato all’assenza di risposta o riduzione del segnale.

Details: Rappresenta una modalità diegetica del sistema Registro.

Appears in: Run / Meta

Related: The Register, Registry: Corruption

## Registry: Corruption

Type: State

One-liner: Stato/manifestazione narrativa del Registro legato a distorsione del comportamento atteso.

Details: Descrive deriva/anomalia del sistema e del linguaggio registrale.

Appears in: Run / Meta

Related: The Register, Registry: Silence, Felix Gallicus

## Scar

Type: System

One-liner: Cicatrice persistente che certifica una perdita o irreversibilità accettata.

Details: È memoria della run ed elemento usato dal Registro per classificare il soggetto.

Appears in: Run / Meta

Related: The Register, Bet, Meta progression

## Bet

Type: System

One-liner: Scommessa/patto che definisce rischio e ritorno atteso nella run.

Details: Firma decisionale con input utente e conseguenze sistemiche.

Appears in: Run

Related: Bet progression, Core loop

## Meta progression

Type: Meta

One-liner: Progressione persistente tra run centrata su sblocco di nuove possibilità, non su power scaling lineare.

Details: Persistono unlock/gating/reward secondo regole documentate.

Appears in: Meta

Related: Bet progression, Scar, Core loop


## Run

Type: Runtime concept

One-liner: Un ciclo completo di gioco governato da un solo RunManager, dall’avvio all’esito finale.

Details: Include selezione/rischio, progressione di fase e chiusura; è l’unità operativa canonica per stato e outcome.

Appears in: Runtime / Mechanics

Related: Bet, Scar, End state

## End state

Type: Outcome

One-liner: Esito terminale di una run, con chiusura amministrativa del circuito decisionale.

Details: Comprende fallimento/successo/chiusura registrale secondo i vincoli definiti nei canon meccanici e narrativi.

Appears in: Run / Mechanics / Lore

Related: Run, The Register, Condemnation

## Condemnation

Type: Outcome class

One-liner: Classe di esito negativo/irreversibile usata per formalizzare il costo finale di una traiettoria di rischio.

Details: Citata in design come “condanna”; non è premio, ma certificazione di perdita coerente con il patto accettato.

Appears in: Mechanics / Lore

Related: End state, Scar, Bet

## Pact

Type: System contract

One-liner: Accordo di rischio esplicito che vincola la run a condizioni e conseguenze definite.

Details: Presente nel flow runtime e nella UI come momento di firma; abilita payoff solo con tradeoff irreversibili.

Appears in: Runtime / Mechanics / UI

Related: Bet, Run, Condemnation

## SOURCE: Glossary extraction notes

- SOURCE: docs/the_register.md
- SOURCE: docs/felix_gallicus.md
- SOURCE: docs/registry_silence.md
- SOURCE: docs/registry_corruption.md
- SOURCE: docs/scar_system.md
- SOURCE: docs/bet_progression.md
- SOURCE: docs/meta_progression.md


## Registry Precedent State

One-liner: Hidden persistent boolean flag that marks the transition from Registro Integro to Registro con Precedente.

Details: Default `false`; set to `true` after first classified terminal run; never shown directly in UI; once active, liberty is no longer eligible and generation pressure shifts toward reiteration without direct combat-stat changes.


## Archivi/Museo

Type: Meta surface

One-liner: Superficie meta che colleziona fascicoli/entry sbloccate dagli esiti finali del Registro.

Details: Riceve unlock runtime tramite evento `archive_entry_unlocked(entry_id)` emesso a finale registrale (`register_final=true`), con ID stabili derivati da `ending_key`.

Appears in: Meta / UI

Related: The Register, End state, Meta progression

## Achievements

Type: Meta recognition

One-liner: Riconoscimenti non-diegetici collegati all'esito finale registrale.

Details: A finale registrale il runtime emette `achievement_unlocked(achievement_id)` con ID stabili (`ach_end_corruption`, `ach_end_glory`, `ach_end_scars`, `ach_end_pattern`) derivati da `ending_key`.

Appears in: Meta

Related: End state, Archivi/Museo, Meta progression

## REGISTRY_PRESSURE

Type: Meta metric

One-liner: Valore persistente nascosto che rappresenta la pressione classificatoria cumulata del Registro.

Details: Aggiornato a fine run da RunManager usando Glory e Corruption; metrica interna non esposta in UI.

## ERA

Type: Registry state band

One-liner: Banda di stato amministrativo finita del Registro (`0..4`, con `4` = Absence).

Details: Progressione monotona e non esposta al player; influenza policy di tono/classificazione senza nuove fasi o azioni utente.