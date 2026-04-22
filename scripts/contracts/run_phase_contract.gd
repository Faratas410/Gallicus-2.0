extends RefCounted
class_name RunPhaseContract

const NONE: int = -1
const PREP: int = 0
const LIVE: int = 1
const GAME_OVER: int = 2
const MAIN_MENU: int = 10
const RUN_INIT: int = 11
const BET_PRESENT: int = 12
const BET_COMMITTED: int = 13
const POST_BET_MESSAGES: int = 14
const INTERMEDIATE_CHOICE: int = 15
const PUSH_YOUR_LUCK: int = 16
const NEXT_BET: int = 17
const RESOLUTION: int = 18 # Legacy compat slot; active resolve flow is ritual/event-driven.
