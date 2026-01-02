GALlicus – GOLDEN CHECKLIST (CODEX EDITION)

IMMUTABLE – NON NEGOTIABLE
This document defines the hard technical constraints Codex MUST respect
when applying changes to the Gallicus repository.

Codex MUST read and comply with this checklist before and during any change.

1. ENGINE & LANGUAGE (STRICT)

Engine: Godot 4.5.1

Language: Strictly typed GDScript

Warnings = Errors (zero warnings allowed)

No Variant inference

No implicit types

No untyped Dictionary.get()

Use maxi/maxf/mini/minf instead of max/min

Explicit casts required when needed

Project must run without parse or type errors

2. ENTRY POINT (INVIOLABLE)

Entry scene:
res://scenes/Main.tscn

Main.tscn must:

load without errors

start gameplay correctly

No change may break startup

3. ARCHITECTURE (FIXED)
RunManager

Exactly ONE RunManager is allowed

Official path:
res://scripts/systems/run_manager.gd

Group: run_manager

 No legacy or duplicate managers

Responsibility split (hard rule)

RunManager → run state, economy, flow

Arena → spawn, enemies, waves

Player → input, combat, health

UI → visualization only

4. COMMUNICATION RULES

Systems communicate only via signals / events

Global events via GameEvents singleton

 No direct cross-system state access

 No circular dependencies

All get_node() calls must be null-safe

5. INPUT MAP (CONTRACT)

These inputs MUST NOT be renamed or removed:

move_left

move_right

move_up

move_down

attack_light

attack_heavy

block

dodge

pause

Inputs may be extended, never modified.

6. RUN STATE OWNERSHIP

Run state lives only in RunManager

Player, Arena, UI do NOT persist state

Reset run = full reset (unless explicitly stated)

7. ECONOMY RULES

Coins / Tokens:

logic → RunManager

display → UI

 No other node modifies economy directly

8. UI – GOLDEN RULE

UI is reactive only

UI listens to signals/events

UI does NOT:

calculate

decide

mutate game state

manage economy

9. SAFETY RULES (MANDATORY)

Dictionary.get() always has typed fallback or explicit cast

NodePaths are optional and validated

Callables are verified before connect

No method calls “by assumption”

10. PATCH RULES (FOR CODEX)

One task = one patch

Changes must be:

minimal

localized

directly related to the task

 No refactors unless explicitly requested

 No unrelated changes in the same patch

11. ABSOLUTE PROHIBITIONS

 Duplicate managers

 Variant inference

 Gameplay logic in UI

 Economy logic outside RunManager

 Player querying RunManager directly (except via signals/events)

 Structural refactors without request

 Multiple fixes bundled together

12. STOP CONDITIONS (CRITICAL)

Codex MUST STOP and report instead of guessing if:

A requested change violates any rule above

Multiple possible targets exist and intent is ambiguous

Fix would require structural refactor not requested

END OF GOLDEN CHECKLIST (CODEX EDITION)
