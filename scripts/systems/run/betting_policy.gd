extends RefCounted
class_name BettingPolicy

func build_bet_offer(
	rng_seed: int,
	_arena_index: int,
	_corruption: int,
	_glory: int,
	_doubles: int,
	_bet_history: Array,
	config: Dictionary
) -> Dictionary:
	var available_bets: Array[Dictionary] = config.get("available_bets", []) as Array[Dictionary]
	var desired_count: int = int(config.get("desired_count", 4))
	desired_count = mini(desired_count, available_bets.size())
	var last_bet_offers: Array = config.get("last_bet_offers", []) as Array
	var last_selected_bet_id: StringName = StringName(str(config.get("last_selected_bet_id", "")))
	var forced_archetype: StringName = StringName(str(config.get("forced_archetype", "")))
	var filtered: Array[Dictionary] = _filter_recent_bets(available_bets, desired_count, last_bet_offers, last_selected_bet_id)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = rng_seed
	var picks: Array[Dictionary] = _pick_weighted_bets(filtered, desired_count, rng, config)
	var picked_ids: Array[StringName] = []
	for bet_value: Dictionary in picks:
		var bet_id: StringName = StringName(str(bet_value.get("id", "")))
		if bet_id != &"":
			picked_ids.append(bet_id)
	return {
		"offer": picks,
		"last_bet_offers": picked_ids,
		"clear_forced_archetype": forced_archetype != &"",
	}

func build_reward_text(inputs: Dictionary) -> Dictionary:
	var score: int = int(inputs.get("audience_score", 0))
	var run_seed: int = int(inputs.get("run_seed", 0))
	var arena_index: int = int(inputs.get("arena_index", 0))
	var phrases: Dictionary = inputs.get("audience_phrases", {}) as Dictionary
	var disable_threshold: int = int(inputs.get("cashout_disable_threshold", -3))
	var penalty_threshold: int = int(inputs.get("cashout_penalty_threshold", 0))
	var penalty_multiplier: float = float(inputs.get("cashout_penalty_multiplier", 0.8))
	var has_registry_precedent: bool = bool(inputs.get("registry_has_precedent", false))
	var audience_label: String = _get_audience_label(score, disable_threshold)
	var audience_reason: String = _get_audience_reason(score, phrases, run_seed, arena_index)
	var cashout_policy: Dictionary = _build_audience_cashout_policy(
		score,
		disable_threshold,
		penalty_threshold,
		penalty_multiplier,
		has_registry_precedent
	)
	return {
		"audience_label": audience_label,
		"audience_reason": audience_reason,
		"cashout_enabled": bool(cashout_policy.get("cashout_enabled", true)),
		"cashout_lock_reason": str(cashout_policy.get("cashout_lock_reason", "")),
		"cashout_modifier": float(cashout_policy.get("cashout_modifier", 1.0)),
		"cashout_modifier_text": str(cashout_policy.get("cashout_modifier_text", "")),
	}

func pick_weighted_bet(roll: int, candidates: Array[Dictionary], config: Dictionary) -> Dictionary:
	if candidates.is_empty():
		return {}
	var total_weight: int = 0
	for candidate: Dictionary in candidates:
		total_weight += _get_weight(candidate, config)
	if total_weight <= 0:
		return candidates[0]
	var safe_roll: int = clampi(roll, 1, total_weight)
	var running: int = 0
	for candidate: Dictionary in candidates:
		running += _get_weight(candidate, config)
		if safe_roll <= running:
			return candidate
	return candidates[candidates.size() - 1]

func _filter_recent_bets(
	bets: Array[Dictionary],
	desired_count: int,
	last_bet_offers: Array,
	last_selected_bet_id: StringName
) -> Array[Dictionary]:
	if bets.size() <= desired_count:
		return bets
	if last_bet_offers.is_empty():
		return bets
	var filtered: Array[Dictionary] = []
	for bet_value: Dictionary in bets:
		var bet_id: StringName = StringName(str(bet_value.get("id", "")))
		if bet_id == &"":
			continue
		if bet_id == last_selected_bet_id:
			continue
		if last_bet_offers.has(bet_id):
			continue
		filtered.append(bet_value)
	if filtered.size() < desired_count:
		return bets
	return filtered

func _pick_weighted_bets(bets: Array[Dictionary], desired_count: int, rng: RandomNumberGenerator, config: Dictionary) -> Array[Dictionary]:
	var picks: Array[Dictionary] = []
	if bets.is_empty():
		return picks
	var pool: Array[Dictionary] = bets.duplicate()
	var count: int = mini(desired_count, pool.size())
	for _i: int in range(count):
		var idx: int = _weighted_pick_index(pool, rng, config)
		if idx < 0 or idx >= pool.size():
			break
		picks.append(pool[idx])
		pool.remove_at(idx)
	return picks

func _weighted_pick_index(pool: Array[Dictionary], rng: RandomNumberGenerator, config: Dictionary) -> int:
	var total_weight: int = 0
	for bet_value: Dictionary in pool:
		total_weight += _get_weight(bet_value, config)
	if total_weight <= 0:
		return 0
	var roll: int = rng.randi_range(1, total_weight)
	var running: int = 0
	for idx: int in range(pool.size()):
		running += _get_weight(pool[idx], config)
		if roll <= running:
			return idx
	return maxi(pool.size() - 1, 0)

func _get_weight(bet: Dictionary, config: Dictionary) -> int:
	var weight: int = maxi(int(bet.get("weight", 1)), 0)
	if not bool(config.get("registry_has_precedent", false)):
		return weight
	var behavior_map: Dictionary = config.get("level3_bet_behavior", {}) as Dictionary
	var high_risk_behaviors: Array = config.get("high_risk_behaviors", []) as Array
	var bet_id: StringName = StringName(str(bet.get("id", "")))
	var behavior_id: StringName = StringName(str(behavior_map.get(bet_id, bet_id)))
	var cash_out_id: StringName = StringName(str(config.get("cash_out_behavior", "")))
	if behavior_id == cash_out_id:
		return maxi(weight - 1, 0)
	if high_risk_behaviors.has(behavior_id):
		return weight + 1
	return weight

func _get_audience_label(score: int, cashout_disable_threshold: int) -> String:
	if score <= cashout_disable_threshold:
		return "FOLLA IN FURIA"
	if score <= -1:
		return "FOLLA OSTILE"
	if score == 0:
		return "FOLLA TIEPIDA"
	if score <= 2:
		return "FOLLA IN ASCOLTO"
	return "FOLLA IN DELIRIO"

func _get_audience_reason(score: int, audience_phrases: Dictionary, run_seed: int, arena_index: int) -> String:
	var mood: String = "DELIRIUM"
	if score <= -1:
		mood = "FURY"
	elif score <= 2:
		mood = "COLD"
	var phrases: Array = audience_phrases.get(mood, []) as Array
	if phrases.is_empty():
		return ""
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = run_seed + arena_index * 37 + score * 13
	var pick_idx: int = rng.randi_range(0, phrases.size() - 1)
	return str(phrases[pick_idx])

func _build_audience_cashout_policy(
	score: int,
	cashout_disable_threshold: int,
	cashout_penalty_threshold: int,
	cashout_penalty_multiplier: float,
	has_registry_precedent: bool
) -> Dictionary:
	var cashout_enabled: bool = score > cashout_disable_threshold
	var cashout_modifier: float = 1.0
	var cashout_modifier_text: String = ""
	var cashout_lock_reason: String = ""
	if not cashout_enabled:
		cashout_lock_reason = "La folla non ti lascia incassare."
	elif score <= cashout_penalty_threshold:
		cashout_modifier = cashout_penalty_multiplier
		cashout_modifier_text = "Incasso penalizzato: x%.1f" % cashout_modifier
	if has_registry_precedent and cashout_enabled:
		cashout_modifier = cashout_modifier * 0.95
		cashout_modifier_text = "Incasso penalizzato: x%.2f" % cashout_modifier
	return {
		"cashout_enabled": cashout_enabled,
		"cashout_lock_reason": cashout_lock_reason,
		"cashout_modifier": cashout_modifier,
		"cashout_modifier_text": cashout_modifier_text,
	}
