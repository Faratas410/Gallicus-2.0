extends RefCounted
class_name RunBetSystem

func get_reward_scale(chain_level: int) -> int:
	return maxi(chain_level, 1)

func get_doom_scale(chain_level: int) -> int:
	return 1 + maxi(chain_level - 1, 0) * 2

func apply_pure_blood_reward(
	run_data: Dictionary,
	level3_enabled: bool,
	scale: int,
	hp_bonus: int
) -> Dictionary:
	var result: Dictionary = run_data.duplicate(true)
	if level3_enabled:
		result["upgrades"] = {}
		return result
	var upgrades: Dictionary = result.get("upgrades", {}) as Dictionary
	var reward_scale: int = get_reward_scale(scale)
	upgrades["hp_bonus"] = int(upgrades.get("hp_bonus", 0)) + hp_bonus * reward_scale
	result["upgrades"] = upgrades
	return result

func apply_double_or_die_reward(run_data: Dictionary, level3_enabled: bool, scale: int, light_bonus: int, heavy_bonus: int) -> Dictionary:
	var result: Dictionary = run_data.duplicate(true)
	if level3_enabled:
		result["upgrades"] = {}
		return result
	if light_bonus <= 0 and heavy_bonus <= 0:
		return result
	var upgrades: Dictionary = result.get("upgrades", {}) as Dictionary
	var reward_scale: int = get_reward_scale(scale)
	for _i: int in range(reward_scale):
		upgrades["light_bonus"] = int(upgrades.get("light_bonus", 0)) + light_bonus
		upgrades["heavy_bonus"] = int(upgrades.get("heavy_bonus", 0)) + heavy_bonus
	result["upgrades"] = upgrades
	return result

func build_pact_text(
	level3_enabled: bool,
	bet_id: String,
	chain_level: int,
	bet_data: Dictionary,
	bet_coward_id: String,
	bet_pure_blood_id: String,
	bet_double_or_die_id: String,
	bet_coward_coin_reward: int,
	bet_pure_hp_bonus: int
) -> String:
	if level3_enabled:
		var tier: int = get_reward_scale(chain_level)
		if not bet_data.is_empty():
			var pact_base: String = str(bet_data.get("pact", ""))
			if pact_base != "":
				return "%s x%d" % [pact_base, tier]
		return bet_id
	var reward_scale: int = get_reward_scale(chain_level)
	match bet_id:
		bet_coward_id:
			return "Ricompensa minore: +%d monete" % (bet_coward_coin_reward * reward_scale)
		bet_pure_blood_id:
			return "Upgrade forte: +%d HP max" % (bet_pure_hp_bonus * reward_scale)
		bet_double_or_die_id:
			return "Raddoppio danni per la run x%d" % reward_scale
		_:
			return bet_id

func build_doom_text(
	level3_enabled: bool,
	bet_id: String,
	chain_level: int,
	bet_data: Dictionary,
	bet_coward_id: String,
	bet_pure_blood_id: String,
	bet_double_or_die_id: String
) -> String:
	if level3_enabled:
		if not bet_data.is_empty():
			var doom_text: String = str(bet_data.get("doom", ""))
			if doom_text != "":
				return doom_text
		return ""
	match bet_id:
		bet_coward_id:
			return "Nessuna penalità extra"
		bet_pure_blood_id:
			var doom_scale: int = get_doom_scale(chain_level)
			return "HP massimo -%d permanente per la run" % (10 * doom_scale)
		bet_double_or_die_id:
			return "MORTE IMMEDIATA: run terminata"
		_:
			return ""
