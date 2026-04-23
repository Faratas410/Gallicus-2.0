extends RefCounted
class_name RunPhaseContract

# Single source of truth for RunPhase identity and canonical phase-name rendering.
# Any consumer-local mirror must reference these constants and must not redefine numeric ids.
const NONE: int = -1
const PREP: int = 0
const LIVE: int = 1
const GAME_OVER: int = 2
const MAIN_MENU: int = 10
const RUN_INIT: int = 11
const BET_PRESENT: int = 12
const BET_COMMITTED: int = 13
const POST_BET_MESSAGES: int = 14 # Legacy compat slot; non-mainline in active Level 3 runtime/UI flow.
const INTERMEDIATE_CHOICE: int = 15
const PUSH_YOUR_LUCK: int = 16
const NEXT_BET: int = 17
const RESOLUTION: int = 18 # Legacy compat slot; active resolve flow is ritual/event-driven.

const NAME_BY_ID: Dictionary = {
	NONE: "NONE",
	PREP: "PREP",
	LIVE: "LIVE",
	GAME_OVER: "GAME_OVER",
	MAIN_MENU: "MAIN_MENU",
	RUN_INIT: "RUN_INIT",
	BET_PRESENT: "BET_PRESENT",
	BET_COMMITTED: "BET_COMMITTED",
	POST_BET_MESSAGES: "POST_BET_MESSAGES",
	INTERMEDIATE_CHOICE: "INTERMEDIATE_CHOICE",
	PUSH_YOUR_LUCK: "PUSH_YOUR_LUCK",
	NEXT_BET: "NEXT_BET",
	RESOLUTION: "RESOLUTION",
}

const CANONICAL_LIVE_PHASE_IDS: Array[int] = [
	MAIN_MENU,
	RUN_INIT,
	BET_PRESENT,
	BET_COMMITTED,
	INTERMEDIATE_CHOICE,
	PUSH_YOUR_LUCK,
	NEXT_BET,
	GAME_OVER,
]

# Internal runtime gate phases and boundary compatibility residues are intentionally excluded
# from canonical live flow checks.
const NON_CANONICAL_RUNTIME_PHASE_IDS: Array[int] = [
	NONE,
	PREP,
	LIVE,
	POST_BET_MESSAGES,
	RESOLUTION,
]

static func get_phase_name(phase_id: int) -> String:
	if NAME_BY_ID.has(phase_id):
		return str(NAME_BY_ID.get(phase_id, ""))
	return str(phase_id)


static func is_canonical_live_phase(phase_id: int) -> bool:
	return CANONICAL_LIVE_PHASE_IDS.has(phase_id)


static func is_non_canonical_runtime_phase(phase_id: int) -> bool:
	return NON_CANONICAL_RUNTIME_PHASE_IDS.has(phase_id)
