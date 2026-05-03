class_name RunStateKernel
extends RefCounted

const SCAR_OPEN_WOUND_ID: StringName = &"OPEN_WOUND"
const SCAR_CRACKED_BONES_ID: StringName = &"CRACKED_BONES"
const SCAR_BLOOD_TAG: StringName = &"BLOOD"

func apply_success(run_state: RunState, context: Dictionary) -> void:
	var glory_per_success: int = int(context.get("glory_per_success", 0))
	var glory_multiplier: int = int(context.get("glory_multiplier", 1))
	var increment: int = glory_per_success * glory_multiplier
	run_state.glory = maxi(run_state.glory + increment, 0)

func apply_failure(run_state: RunState, context: Dictionary) -> void:
	var corruption_delta: int = int(context.get("corruption_delta", 0))
	if corruption_delta <= 0:
		return
	var corruption_max: int = int(context.get("corruption_max", 100))
	run_state.corruption = clampi(run_state.corruption + corruption_delta, 0, corruption_max)

func upsert_run_scar(run_state: RunState, scar_id: String, arena_index: int, context: Dictionary) -> bool:
	var normalized_scar_id: StringName = StringName(scar_id)
	if normalized_scar_id == &"":
		return false
	var append_history: bool = bool(context.get("append_history", true))
	if append_history:
		for existing_scar: StringName in run_state.scars_history:
			if existing_scar == normalized_scar_id:
				return false
	if append_history:
		run_state.scars_history.append(normalized_scar_id)
	if context.has("scar_payload"):
		var scar_payload: Dictionary = context.get("scar_payload", {}) as Dictionary
		var normalized_payload: Dictionary = scar_payload.duplicate(true)
		normalized_payload["id"] = normalized_scar_id
		run_state.scars_payload.append(normalized_payload)
	if context.has("run_scar"):
		run_state.scars.append(context.get("run_scar"))
	run_state.last_scar_arena_index = arena_index
	return true

func append_bet_history(run_state: RunState, bet_entry: Dictionary) -> void:
	var bet_id: StringName = StringName(str(bet_entry.get("bet_id", "")))
	if bet_id == &"":
		return
	run_state.bets_history.append(bet_id)

func reset_scars(run_state: RunState) -> void:
	run_state.scars_payload = []
	run_state.scars = []
	run_state.scars_history = []
	run_state.is_hunted_by_crowd = false
	run_state.scar_heal_multiplier = 1.0
	run_state.scar_avoidance_cooldown_multiplier = 1.0
	run_state.scar_avoidance_speed_multiplier = 1.0

func recompute_scar_modifiers(run_state: RunState) -> void:
	var heal_multiplier: float = 1.0
	var avoidance_cooldown_multiplier: float = 1.0
	var avoidance_speed_multiplier: float = 1.0
	for scar: Dictionary in run_state.scars_payload:
		var scar_value_id: StringName = StringName(str(scar.get("id", "")))
		match scar_value_id:
			SCAR_OPEN_WOUND_ID:
				heal_multiplier = minf(heal_multiplier, 0.6)
			SCAR_CRACKED_BONES_ID:
				avoidance_cooldown_multiplier = maxf(avoidance_cooldown_multiplier, 1.4)
				avoidance_speed_multiplier = minf(avoidance_speed_multiplier, 0.85)
			_:
				pass
	run_state.scar_heal_multiplier = heal_multiplier
	run_state.scar_avoidance_cooldown_multiplier = avoidance_cooldown_multiplier
	run_state.scar_avoidance_speed_multiplier = avoidance_speed_multiplier

func recompute_scar_synergies(run_state: RunState) -> bool:
	if run_state.is_hunted_by_crowd:
		return false
	var blood_count: int = 0
	for scar_value: Dictionary in run_state.scars_payload:
		var tags: Array = scar_value.get("tags", []) as Array
		for tag_value in tags:
			if StringName(tag_value) == SCAR_BLOOD_TAG:
				blood_count += 1
				break
	if blood_count >= 3:
		run_state.is_hunted_by_crowd = true
		return true
	return false

func add_scar(run_state: RunState, scar_id: String, context: Dictionary) -> void:
	upsert_run_scar(run_state, scar_id, int(context.get("arena_index", run_state.last_scar_arena_index)), context)

func enforce_invariants(run_state: RunState) -> void:
	# Boundary-safe normalization only (null/default/range clamps), no schema rewrites.
	if run_state.scars == null:
		run_state.scars = []
	if run_state.scars_payload == null:
		run_state.scars_payload = []
	if run_state.scars_history == null:
		run_state.scars_history = []
	if run_state.bets_history == null:
		run_state.bets_history = []
	if run_state.corruption < 0:
		run_state.corruption = 0
	if run_state.glory < 0:
		run_state.glory = 0
