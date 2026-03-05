# CANON DEPENDENCY MATRIX

| Canon File | Category Owner | May Reference | May Not Define |
| --- | --- | --- | --- |
| FOUNDATIONS | Governance root | All canon files | Runtime implementation details |
| PROCESS_AND_FREEZE | Operations + zone policy | FOUNDATIONS, RUN_ARCHITECTURE_CANON, MECHANICS_UNIFIED, UI_CANON | Gameplay rules and lore content |
| RUN_ARCHITECTURE_CANON | Runtime authority + flow contracts | FOUNDATIONS, PROCESS_AND_FREEZE, MECHANICS_UNIFIED, GLOSSARY_ENTITIES | Narrative/lore interpretation |
| MECHANICS_UNIFIED | Gameplay mechanics and rules | FOUNDATIONS, RUN_ARCHITECTURE_CANON, GLOSSARY_ENTITIES | Runtime ownership or flow authority |
| UI_CANON | UI contracts + visual governance | FOUNDATIONS, RUN_ARCHITECTURE_CANON, PROCESS_AND_FREEZE | Gameplay decision logic |
| LORE_UNIFIED | Narrative canon | FOUNDATIONS, GLOSSARY_ENTITIES, REGISTRY_ERA_CHRONICLE | Runtime architecture or mechanics enforcement |
| GLOSSARY_ENTITIES | Shared term definitions | FOUNDATIONS, LORE_UNIFIED, MECHANICS_UNIFIED | Category-specific runtime rules |
| REGISTRY_SYSTEM_SPEC | Registry systemic behavior (non-phase) | FOUNDATIONS, LORE_UNIFIED, MECHANICS_UNIFIED | Phase routing / run authority |
| REGISTRY_ERA_CHRONICLE | Registry era chronology (lore) | FOUNDATIONS, LORE_UNIFIED, REGISTRY_SYSTEM_SPEC | Runtime behavior contracts |

1. Each canon file owns definitions in its own category only.
2. Cross-canon references are allowed only as listed in this matrix.
3. Conflicts are resolved by category owner, never by duplicate definitions.
4. New documentation must link to canon files instead of redefining canon terms.
5. PRs changing governed systems must update the owning canon file in the same PR.
