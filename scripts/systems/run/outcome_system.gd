extends RefCounted
class_name RunOutcomeSystem

const BetCatalogScript = preload("res://scripts/content/bet_catalog.gd")

const BET_CASH_OUT: StringName = &"CASH_OUT"
const BET_DOUBLE_OR_DIE: StringName = &"DOUBLE_OR_DIE"
const BET_DEBT_CHAIN: StringName = &"DEBT_CHAIN"
const BET_BLOOD_TAX: StringName = &"BLOOD_TAX"
const BET_CROW_PLEASER: StringName = &"CROW_PLEASER"
const BET_LAST_BREATH: StringName = &"LAST_BREATH"

const SCAR_CRACKED_BONES: StringName = &"SCAR_CRACKED_BONES"
const SCAR_OPEN_WOUND: StringName = &"SCAR_OPEN_WOUND"
const SCAR_DEBT_BRAND: StringName = &"SCAR_DEBT_BRAND"
const SCAR_SHAME_MARK: StringName = &"SCAR_SHAME_MARK"
const SCAR_RUSTED_ARMOR: StringName = &"SCAR_RUSTED_ARMOR"
const SCAR_ONE_EYE: StringName = &"SCAR_ONE_EYE"

const RISK_VOLATILE_RECORD: StringName = &"VOLATILE_RECORD"
const RISK_SEVERE_JUDGMENT: StringName = &"SEVERE_JUDGMENT"

func resolve_level3_arena(
	rng: RandomNumberGenerator,
	rng_seed: int,
	escalation_level: int,
	active_scar_ids: Array[StringName],
	risk_profile: StringName,
	risk_profiles: Array[Dictionary]
) -> Dictionary:
	var base_win: float = 0.66
	var base_failure: float = 0.4
	var pressure_mod: float = 0.0
	var escalation_penalty: float = get_escalation_win_penalty(escalation_level)
	var escalation_adverse_mod: float = get_escalation_adverse_penalty(escalation_level)
	if _contains_scar(active_scar_ids, SCAR_CRACKED_BONES):
		base_win -= 0.12
		base_failure += 0.18
	if _contains_scar(active_scar_ids, SCAR_OPEN_WOUND):
		base_win -= 0.05
		base_failure += 0.1
	if _contains_scar(active_scar_ids, SCAR_SHAME_MARK):
		base_win -= 0.06
		base_failure += 0.12
	if _contains_scar(active_scar_ids, SCAR_RUSTED_ARMOR):
		base_failure += 0.15
	if _contains_scar(active_scar_ids, SCAR_DEBT_BRAND):
		escalation_penalty += 0.05
		escalation_adverse_mod += 0.04
	if _contains_scar(active_scar_ids, SCAR_ONE_EYE):
		base_failure += 0.1
		base_win -= 0.03

	var profile: Dictionary = _get_risk_profile_def(risk_profile, risk_profiles)
	if not profile.is_empty():
		var win_mod: float = float(profile.get("win_mod", 0.0))
		var adverse_shift: float = float(profile.get("pressure_mod", 0.0))
		pressure_mod = adverse_shift
		base_win += win_mod
		base_failure += adverse_shift
		if risk_profile == RISK_VOLATILE_RECORD:
			base_win = 0.5 + (base_win - 0.5) * 1.35
			base_failure = 0.5 + (base_failure - 0.5) * 1.25
	var win_chance: float = clampf(base_win - escalation_penalty, 0.2, 0.85)
	var failure_chance: float = clampf(base_failure + escalation_adverse_mod, 0.2, 0.85)

	rng.seed = rng_seed
	var won: bool = rng.randf() <= win_chance
	var condemnation_flag: bool = rng.randf() <= failure_chance
	var notes: Array[StringName] = []
	if condemnation_flag:
		notes.append(&"CONDEMNATION")
	if risk_profile != &"":
		notes.append(StringName("RISK_" + String(risk_profile)))
	var outcome_tier: StringName = &"ADVERSE"
	if won:
		outcome_tier = &"FAVORABLE"
	if not won and condemnation_flag:
		outcome_tier = &"TERMINAL"
	var outcome_reason: String = "Condanna registrata"
	if won and not condemnation_flag:
		outcome_reason = "Esito favorevole registrato"
	elif won:
		outcome_reason = "Esito favorevole con condanna registrata"
	# Canon ritual vocabulary (Patch 9A).
	# Legacy outcome aliases removed in C4.
	return {
		"risk_profile": String(risk_profile),
		"pressure_mod": pressure_mod,
		"failure_chance": failure_chance,
		"condemnation_flag": condemnation_flag,
		"outcome_tier": String(outcome_tier),
		"outcome_reason": outcome_reason,
		"resolve_debug": {
			"base_failure_chance": base_failure,
			"escalation_mod": escalation_adverse_mod,
			"scar_mod": base_failure - 0.4 - pressure_mod,
			"risk_pressure_mod": pressure_mod,
			"final_failure_chance": failure_chance,
			"condemnation_flag": condemnation_flag,
			"outcome_tier": String(outcome_tier),
		},
		"won": won,
		"notes": notes,
	}

func build_level3_loss_consequence(
	bet_id: StringName,
	behavior_id: StringName,
	risk_profile: StringName,
	provoke_armed: bool,
	next_loss_adverse_cost: int,
	_scar_open_wound_adverse_cost: int
) -> Dictionary:
	if provoke_armed:
		# Canon ritual vocabulary (Patch 9A).
		# Legacy loss aliases removed in C6B.
		return {
			"condemnation_flag": false,
			"outcome_tier": "TERMINAL",
			"outcome_reason": "Condanna: Provoca fallita",
			"corruption_gain": 0,
			"end_reason": "PROVOCA_FAIL",
			"apply_next_loss_adverse_cost": false,
			"clear_next_loss_adverse_cost": true,
			"scar_id": &"",
			"scar_origin": "",
			"cashout_lock_min": -1,
			"reset_reward_tier": false,
			"reset_escalation": false,
		}
	var executioner_bonus: int = 0
	if risk_profile == RISK_SEVERE_JUDGMENT:
		executioner_bonus = 10
	if bet_id == BET_DOUBLE_OR_DIE:
		# Canon ritual vocabulary (Patch 9A).
		# Legacy loss aliases removed in C6B.
		return {
			"condemnation_flag": false,
			"outcome_tier": "TERMINAL",
			"outcome_reason": "Condanna: Raddoppia o Muori",
			"corruption_gain": 0,
			"end_reason": "THE_FOOL",
			"apply_next_loss_adverse_cost": false,
			"clear_next_loss_adverse_cost": false,
			"scar_id": &"",
			"scar_origin": "",
			"cashout_lock_min": -1,
			"reset_reward_tier": false,
			"reset_escalation": false,
		}
	var adverse_cost: int = 0
	var scar_id: StringName = SCAR_CRACKED_BONES
	var scar_origin: String = "Sconfitta in arena"
	var cashout_lock_min: int = -1
	if behavior_id == BET_DEBT_CHAIN:
		scar_id = SCAR_DEBT_BRAND
		scar_origin = "Condanna: Catena di Debito"
	elif behavior_id == BET_BLOOD_TAX:
		adverse_cost += 25 + executioner_bonus
		cashout_lock_min = 1
		scar_id = SCAR_RUSTED_ARMOR
		scar_origin = "Condanna: Decima di Sangue"
	elif behavior_id == BET_CROW_PLEASER:
		scar_id = SCAR_SHAME_MARK
		scar_origin = "Condanna: Piacere al Pubblico"
	elif behavior_id == BET_LAST_BREATH:
		adverse_cost += 15 + executioner_bonus
		scar_id = SCAR_ONE_EYE
		scar_origin = "Condanna: Ultimo Respiro"
	else:
		adverse_cost += executioner_bonus
	if next_loss_adverse_cost > 0:
		adverse_cost += next_loss_adverse_cost
	# Canon ritual vocabulary (Patch 9A).
	# Legacy loss aliases removed in C6B.
	return {
		"condemnation_flag": adverse_cost > 0 or scar_id != &"",
		"outcome_tier": "ADVERSE",
		"outcome_reason": scar_origin,
		"corruption_gain": maxi(adverse_cost * 10, 0),
		"end_reason": "",
		"apply_next_loss_adverse_cost": next_loss_adverse_cost > 0,
		"clear_next_loss_adverse_cost": true,
		"scar_id": scar_id,
		"scar_origin": scar_origin,
		"cashout_lock_min": cashout_lock_min,
		"reset_reward_tier": true,
		"reset_escalation": true,
	}

func compute_level3_reward_glory(
	behavior_id: StringName,
	reward_tier: int,
	cashout_modifier: float
) -> int:
	var tier: int = maxi(reward_tier, 1)
	match behavior_id:
		BET_CASH_OUT:
			var reward: int = tier
			if cashout_modifier < 1.0:
				reward = int(floor(float(reward) * cashout_modifier))
				reward = maxi(reward, 0)
			return reward
		BET_DOUBLE_OR_DIE:
			return 2 * tier
		BET_DEBT_CHAIN:
			return tier
		BET_BLOOD_TAX:
			return 2 * tier
		BET_CROW_PLEASER:
			return tier
		BET_LAST_BREATH:
			return 2 * tier
		_:
			return 0

func get_escalation_win_penalty(escalation_level: int) -> float:
	var penalty: float = 0.0
	if escalation_level >= 1:
		penalty += 0.04
	if escalation_level >= 2:
		penalty += float(escalation_level - 1) * 0.09
	return penalty

func get_escalation_adverse_penalty(escalation_level: int) -> float:
	var penalty: float = 0.0
	if escalation_level >= 1:
		penalty += 0.03
	if escalation_level >= 2:
		penalty += float(escalation_level - 1) * 0.07
	return penalty

func _contains_scar(active_scar_ids: Array[StringName], scar_id: StringName) -> bool:
	for value: StringName in active_scar_ids:
		if value == scar_id:
			return true
	return false

func _get_risk_profile_def(profile_id: StringName, risk_profiles: Array[Dictionary]) -> Dictionary:
	for profile_value: Dictionary in risk_profiles:
		var profile: Dictionary = profile_value as Dictionary
		if StringName(str(profile.get("id", ""))) == profile_id:
			return profile
	return {}
