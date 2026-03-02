# Guida rapida — Template per era (riferimenti repo)

## Obiettivo
Mappa dei file da usare per creare nuovi template per era, distinguendo:
- layer canonico (vincoli)
- layer runtime (selezione/propagazione)
- layer UI/asset (render)

## 1) Canon (vincoli prima dell'implementazione)
- `docs/canon/REGISTRY_SYSTEM_SPEC.md`
  - Definisce modello a ere, transizioni, vincoli di non-loop e assenza di naming era esplicito in UI.
- `docs/canon/REGISTRY_ERA_CHRONICLE.md`
  - Definisce tono/stratificazione diegetica per era.
- `docs/canon/MECHANICS_UNIFIED.md`
  - Addendum meccanico su `registry_has_precedent`, liberty first-era e impatti di generazione.
- `docs/canon/CANON_DEPENDENCY_MATRIX.md`
  - Matrice di ownership canonica (chi può definire cosa).

## 2) Runtime (dove agganciare i template era)
- `scripts/systems/run_manager.gd`
  - Autorità che calcola l'era operativa (quick-cut), costruisce payload testuale per era e propaga tema arena verso UI.
- `scripts/systems/run/run_arena_theme_policy.gd`
  - Policy stateless di selezione tema arena e arene speciali.
- `data/arena_themes.gd`
  - Registro dati temi (title/subtitle + path texture background/overlay).
- `scripts/systems/game_events.gd`
  - Contratti segnale (`arena_theme_changed`) usati per la propagazione verso la UI.

## 3) UI (consumo payload + nodi)
- `scripts/ui/ui_root.gd`
  - Consuma `arena_theme_changed` e aggiorna label/panel del tema arena.
- `scenes/UI.tscn`
  - Nodi visuali effettivi dei pannelli titolo/sottotitolo tema arena.

## 4) Atlas/UI skin (oltre atlas: catena completa)
- `project.godot`
  - Autorità globale tema (`[gui] theme/custom`).
- `ui/theme/official_theme.tres`
  - Mappa stylebox di Button/Panel verso risorse ufficiali.
- `ui/official/styleboxes/*.tres`
  - StyleBoxTexture che puntano agli AtlasTexture.
- `ui/official/atlas/*.tres`
  - Slice (`Rect2`) che puntano all'atlas PNG sorgente.
- `assets/MainMenu/UI assets (1x).png`
  - Sorgente atlas corrente.

## 5) Altri riferimenti utili non-atlas
- `scripts/Arena.gd`
  - Varianti background runtime e caricamento texture arena.
- `scenes/Arena.tscn`
  - Container visuale arena.
- `scripts/ui/menu_ambience.gd`
  - Uso AtlasTexture runtime (torce) da strip PNG, utile come pattern alternativo all'atlas `.tres` statico.
- `scenes/Main.tscn`
  - Wiring tema/stile main menu e stylebox ufficiali.

## Checklist pratica per creare "template per era"
1. Definisci il comportamento era in canon (se cambia regole, aggiorna canon owner).
2. Estendi dati in `data/arena_themes.gd` (title/subtitle/path).
3. Aggancia logica di scelta in `run_arena_theme_policy.gd` / `run_manager.gd`.
4. Propaga via `GameEvents.arena_theme_changed`.
5. Renderizza in `ui_root.gd` + nodi `UI.tscn`.
6. Se serve nuovo skin, passa da `official_theme -> styleboxes -> atlas` (non hardcodare su singoli nodi se evitabile).
