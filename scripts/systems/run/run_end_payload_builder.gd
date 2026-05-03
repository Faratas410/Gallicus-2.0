extends RefCounted
class_name RunEndPayloadBuilder

func build_run_summary(run_state: RunState, finale: Dictionary, now_msec: int) -> Dictionary:
	var duration_seconds: int = 0
	if run_state.run_start_time_msec > 0:
		duration_seconds = int(float(now_msec - run_state.run_start_time_msec) / 1000.0)
	var bets_history: Array[String] = []
	for bet_id: StringName in run_state.bets_history:
		bets_history.append(String(bet_id))
	var pacts_log: Array[Dictionary] = []
	for entry_value in run_state.pacts_log:
		if entry_value != null and entry_value.has_method("to_dict"):
			pacts_log.append(entry_value.to_dict())
	var scars_history: Array[String] = []
	for scar_id: StringName in run_state.scars_history:
		scars_history.append(String(scar_id))
	var risk_profiles: Array[String] = []
	for profile_id: StringName in run_state.risk_profiles:
		risk_profiles.append(String(profile_id))
	var ending_id: String = str(finale.get("ending_id", ""))
	return {
		"seed": run_state.run_seed,
		"duration_seconds": duration_seconds,
		"arenas_cleared": run_state.arenas_cleared,
		"bets_history": bets_history,
		"pacts_log": pacts_log,
		"max_escalation": run_state.max_escalation,
		"scars_history": scars_history,
		"scars_count": run_state.scars_history.size(),
		"is_hunted_by_crowd": run_state.is_hunted_by_crowd,
		"ending_id": ending_id,
		"cashouts": run_state.cashouts,
		"doubles": run_state.doubles,
		"risk_profiles": risk_profiles,
	}
