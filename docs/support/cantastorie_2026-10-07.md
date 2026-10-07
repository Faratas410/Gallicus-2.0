# Lauro, lo storno cantastorie - 7 ottobre 2026

Richiesta dell'utente: "Aggiungiamo un personaggio? Voglio che sia un
cantastorie. Modelli e tono sono nelle tue mani, ma mi piacerebbe fosse colui
che racconta le gesta degli eroi."

## Chi e'

**Lauro, Storno cantastorie.** Uno storno nero a macchie chiare ("come cera
schizzata"), con tre tavolette dipinte sulla schiena. Gli storni imitano le
voci: Lauro canta il richiamo di Orvo prima di Orvo e il vecchio grido di Rugo
meglio di Rugo. Abita la gradinata (strato delle voci calde, vedi
`docs/direction.md`), non l'amministrazione.

Funzione nel mondo: la terza memoria. L'arena dimentica, il Registro copia le
righe, Lauro canta quello che le righe lasciano fuori e ogni sera cambia una
parola. "Io ricordo male, ma ricordo."

Tono: versi brevi, spesso aperti da "Udite"; caldo e preciso sui fatti, mai
buffo. Non giudica, non spiega regole, non da' voce al soggetto.

Canone su Felix: Lauro canta la gesta di chi sedeva accanto a Dima ma non
riesce a finirla, e non inventa la fine. La gradinata non applaude quella
strofa: ascolta. Nessun nome, nessuna celebrazione (LORE_UNIFIED, divieti su
Felix).

## Cosa fa nel gioco

| Dove | Cosa | Owner |
| --- | --- | --- |
| Fascicolo | colonna "LA GESTA DI LAURO": strofa di tre versi sul percorso + nota con la gesta piu' alta | RunManager `_sing_gesta` compone, `ui_root._format_gesta` traduce e mostra |
| Profilo | gesta piu' alta (`gesta_best`: Gloria, arene) | SaveManager, scritto solo da RunManager |
| Scala dei bandi | racconto "La prima strofa" (gradino 1) e "La strofa aperta" (gradino 8) | `campaign_dialogues.gd` `TALES` |
| Arena | otto voci (patto e gesto, distese e compresse) | `arena_characters.gd` |
| Archivio | scheda di Lauro | `arena_characters.gd` `CHARACTERS` |

La strofa: apertura per arene raggiunte; il fatto piu' alto (bando chiuso,
catena di almeno tre sigilli, gradinata che porta, Segno mostrato, sabbia
lanciata, almeno 20 Gloria, altrimenti un verso semplice); chiusura per
quietanza, marchio, cera che cede o fascicolo classificato. Due varianti per
verso, scelte dal seme del percorso. La gesta e' solo presentazione: non
cambia posta, conto, firma o Ere. Silenzio e Assenza non hanno gesta.

La colonna "ULTIMA VOCE" del fascicolo diventa la colonna della gesta, larga
il doppio delle altre due (`size_flags_stretch_ratio = 2`, testo 13 px senza
clip). Se un payload non porta gesta, torna l'ultima voce della folla.
Il fascicolo ora si ricompone anche se si cambia lingua mentre e' aperto.

## Ritratto

`assets/ui/generated/dialogue_lauro.png` e' un **segnaposto** disegnato a
codice (silhouette scura con luce di taglio), non all'altezza dei ritratti di
Nerio, Rugo e Dima. Il prompt per l'arte definitiva, nello stesso stile degli
altri, e' in `assets/ui/generated/manifest.json` (voce `dialogue_lauro`,
`tool: placeholder`). Sostituire il PNG a 1024x1536 RGB con lo stesso nome
basta: nessun riferimento da cambiare.

## Verifica

Candidato locale su `da99a64` piu' le modifiche di questo pacchetto.

- Playbook completo con Godot 4.6.2 Linux (`run_testing_playbook.py`,
  FULL_RUN): 51 controlli verdi, compresi import, CP-02, audit, AV
  (contratti dei personaggi e dei dialoghi illustrati con i dieci racconti),
  campagna e smoke del percorso completo.
- Catture a 1280x720 e 1920x1080: fascicolo in IT/EN/ES con la gesta di un
  bando chiuso, racconto "La prima strofa" con il ritratto segnaposto.
- Scansione mojibake e `git diff --check` puliti.

Playtest umano: da fare. Domande aperte per il playtest: la strofa si legge
nel fascicolo o va data un momento proprio? La gesta piu' alta spinge a
rischiare di piu'?
