extends SceneTree

# Campaign simulator for tuning (not a CI gate). It drives the real UI like
# scripts/ci/campaign_runtime_contract.gd, with a player style chosen by args:
#   --style=bando|prudent|thin   how the percorso is played (see _push_or_cash)
#   --strike=never|thin|bando    when a held seal is struck again
#   --crowd=read|bow             how the stands are answered
#   --shop=selective|never       whether to buy useful banco services
#   --seat=defer|reserve|witness choose the seat case when it appears
#   --copy=defer|copy|keep       choose where to keep the annotation
#   --initial-denari=N           starting profile balance for a recovery scenario
#   --runs=N --seed=S            campaign length cap and seed base
# Prints one SIM_RUN json line per percorso and a SIM_SUMMARY at the end.
# Run: godot --headless --audio-driver Dummy --path . --script res://tools/campaign_sim.gd -- --style=bando
const Catalog = preload("res://scripts/content/bet_catalog.gd")
var scene: Node
var manager: Node
var save: Node
var closed: bool = false
var reason: String = ""
var opts: Dictionary = {"style": "bando", "strike": "bando", "crowd": "read", "shop": "selective", "seat": "defer", "copy": "defer", "initial-denari": "0", "runs": "80", "seed": "1782373819"}
var run_stats: Dictionary = {}
var dialogues: Dictionary = {}

func _initialize() -> void:
	call_deferred("_run")

func _press(name: String) -> bool:
	var button: Button = scene.find_child(name, true, false) as Button
	if button == null or not button.is_visible_in_tree() or button.disabled:
		return false
	button.pressed.emit()
	return true

func _available(name: String) -> bool:
	var button: Button = scene.find_child(name, true, false) as Button
	return button != null and button.is_visible_in_tree() and not button.disabled

func _boot() -> void:
	scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	manager = scene.get_node("RunManager")
	await create_timer(0.5).timeout

func _run() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--") and argument.contains("="):
			var parts: PackedStringArray = argument.trim_prefix("--").split("=", true, 1)
			opts[parts[0]] = parts[1]
	Engine.time_scale = 12.0
	root.get_node("GameEvents").run_ended.connect(func(value: String, _summary: Dictionary) -> void:
		closed = true
		reason = value)
	root.get_node("GameEvents").seal_strike_resolved.connect(func(payload: Dictionary) -> void:
		if int(payload.get("strike", 0)) >= 2 and bool(payload.get("held", false)) and not bool(payload.get("scar_shown", false)):
			run_stats.strikes_held += 1)
	await _boot()
	save = root.get_node("SaveManager")
	var initial_balance: int = int(opts["initial-denari"])
	if initial_balance < -20 or initial_balance > 9999 or str(opts.seat) not in ["defer", "reserve", "witness"] or str(opts.copy) not in ["defer", "copy", "keep"]:
		push_error("SIM: invalid initial balance or seat policy")
		quit(1)
		return
	save.set_ledger_denari(initial_balance)
	var rows: Array[Dictionary] = []
	for index: int in range(int(opts.runs)):
		closed = false
		var balance_before: int = save.get_ledger_denari()
		run_stats = {"strike_offers": 0, "strikes": 0, "strikes_held": 0, "bando_strikes": 0, "exchanges": 0, "challenges": 0, "scar_shown": 0, "hubris": 0, "pacts": 0, "insured": 0, "discounted_policies": 0, "favor_bought": 0, "pressure_bought": 0, "bought": 0}
		OS.set_environment("GALLICUS_SMOKE", "1")
		OS.set_environment("GALLICUS_SMOKE_SEED", str(int(opts.seed) + index * 7919))
		if not _press("NewGameButton"):
			push_error("SIM: new game unavailable")
			break
		OS.unset_environment("GALLICUS_SMOKE")
		OS.unset_environment("GALLICUS_SMOKE_SEED")
		Engine.time_scale = 12.0
		var era_before: int = save.get_registry_era()
		var step_before: int = save.get_bando_step()
		var quota: int = 0
		var deadline: int = 0
		var deadline_left: int = 15000
		var limit: int = Time.get_ticks_msec() + deadline_left
		while not closed and Time.get_ticks_msec() < limit:
			await create_timer(0.6).timeout
			var run: RunState = manager.get("_run_state")
			quota = run.bando_quota
			deadline = run.bando_deadline
			var conversation: Node = scene.get_node("OpeningPrologue")
			if conversation.get("_active"):
				var id: String = str(conversation.get("_payload").id)
				if not dialogues.has(id):
					dialogues[id] = index + 1
				_press("AdvanceDialogue")
				continue
			if _seat_action():
				continue
			if _press("SkipPrologue") or _press("Btn_Open_Book"):
				continue
			if _available("Btn_Sign_Left") or _available("Btn_Sign_Right"):
				_shop(run)
				_sign(run)
				continue
			if _available("Btn_RESOLUTION_NEXT"):
				if _strike_again(run):
					continue
				_press("Btn_RESOLUTION_NEXT")
				continue
			if _available("Btn_MID_CHOICE_SELECT_0"):
				_answer_crowd(run)
				continue
			if _press("Btn_FIRST_REACTION_NEXT") or _press("Btn_RESOLUTION_STRIKE"):
				continue
			if _available("Btn_PUSH_YOUR_LUCK_CASHOUT") or _available("Btn_PUSH_YOUR_LUCK_DOUBLE"):
				if _push_or_cash(run):
					continue
				if _press("Btn_PUSH_YOUR_LUCK_CASHOUT"):
					continue
				if not _press("Btn_PUSH_YOUR_LUCK_DOUBLE"):
					_press("Btn_PUSH_YOUR_LUCK_CONDANNA")
				continue
			_press("Btn_PUSH_YOUR_LUCK_CONDANNA")
		if not closed:
			push_error("SIM: stalled at " + str(manager.get("_phase")))
			break
		var row: Dictionary = run_stats.duplicate()
		var settlement_reason: String = manager.get("_run_state").run_end_reason
		row.merge({"run": index + 1, "reason": reason, "settlement_reason": settlement_reason,
			"glory": int(manager.get("_run_state").glory) if settlement_reason == "CASH_OUT" else 0,
			"arenas": manager.get("_run_state").arena_index, "quota": quota, "deadline": deadline,
			"bando": save.get_bando_step() > step_before, "step": save.get_bando_step(),
			"denari_before": balance_before, "denari": save.get_ledger_denari(), "earned": manager.get("_run_state").ledger_earned,
			"lost": manager.get("_run_state").ledger_lost, "era": save.get_registry_era(),
			"corruption": int(manager.get("_run_state").corruption), "favor": int(manager.get("_run_state").audience_score),
			"pressure_max": int(manager.get("_run_state").max_escalation), "scars": manager.get("_run_state").scars.size(),
			"chain_peak": int(manager.get("_run_state").seal_chain_peak), "register": str(manager.call("_get_register_final_ending_key")),
			"samples": int(save.get_registry_evolution().get("samples", 0)), "choices": manager.get("_run_state").bets_history.size()}, true)
		rows.append(row)
		print("SIM_RUN ", JSON.stringify(row))
		if save.get_registry_era() == 4:
			break
		if save.get_registry_era() != era_before:
			await create_timer(2.2).timeout
			_press("ReturnToMenu")
		else:
			_press("Btn_END_RUN_QUIT")
		await create_timer(0.5).timeout
	print("SIM_DIALOGUES ", JSON.stringify(dialogues))
	var summary: Dictionary = _summary(rows)
	summary["seat_case"] = save.get_seat_case()
	summary["seat_inquiry"] = save.get_seat_inquiry()
	summary["seat_copy"] = save.get_seat_copy()
	summary["final_era"] = save.get_final_era()
	print("SIM_SUMMARY ", JSON.stringify(summary))
	# At 12x a SceneTree timer leaves the audio driver almost no real time to
	# release its playbacks: close like the contracts do.
	Engine.time_scale = 1.0
	scene.queue_free()
	await create_timer(0.5).timeout
	await preload("res://scripts/ci/audio_test_teardown.gd").finish(self)
	quit(0)

func _summary(rows: Array[Dictionary]) -> Dictionary:
	var glories: Array[int] = []
	var zero: int = 0
	var bandi: int = 0
	var min_denari: int = int(opts["initial-denari"])
	var max_denari: int = int(opts["initial-denari"])
	var debt_runs: int = 0
	var debt_start_runs: int = 0
	var first_recovery_run: int = -1
	var earned: int = 0
	var lost: int = 0
	var debt_spells: Array[int] = []
	var spell: int = 0
	var totals: Dictionary = {}
	var step8: int = -1
	var step12: int = -1
	for row: Dictionary in rows:
		if int(row.denari_before) < 0:
			debt_start_runs += 1
			if int(row.denari) >= 0 and first_recovery_run < 0:
				first_recovery_run = int(row.run)
		earned += int(row.earned)
		lost += int(row.lost)
		if row.settlement_reason == "CASH_OUT":
			glories.append(int(row.glory))
		if int(row.glory) == 0:
			zero += 1
		if row.bando:
			bandi += 1
		if int(row.step) >= 8 and step8 < 0: step8 = int(row.run)
		if int(row.step) >= 12 and step12 < 0: step12 = int(row.run)
		min_denari = mini(min_denari, int(row.denari))
		max_denari = maxi(max_denari, int(row.denari))
		if int(row.denari) < 0:
			debt_runs += 1
			spell += 1
		elif spell > 0:
			debt_spells.append(spell)
			spell = 0
		for key: String in ["strike_offers", "strikes", "strikes_held", "bando_strikes", "exchanges", "challenges", "scar_shown", "hubris", "pacts", "insured", "discounted_policies", "favor_bought", "pressure_bought", "bought"]:
			totals[key] = int(totals.get(key, 0)) + int(row[key])
	if spell > 0:
		debt_spells.append(-spell)
	glories.sort()
	return {"opts": opts, "runs": rows.size(), "absence": rows.size() > 0 and int(rows.back().era) == 4,
		"zero_glory_pct": roundi(100.0 * zero / maxf(rows.size(), 1)), "median_cashout": glories[glories.size() / 2] if not glories.is_empty() else 0,
		"bandi": bandi, "step_final": int(rows.back().step) if not rows.is_empty() else 0, "step8_run": step8, "step12_run": step12,
		"denari_min": min_denari, "denari_max": max_denari, "denari_final": int(rows.back().denari) if not rows.is_empty() else 0,
		"debt_runs": debt_runs, "debt_start_runs": debt_start_runs, "first_recovery_run": first_recovery_run,
		"debt_spells": debt_spells, "earned": earned, "lost": lost,
		"totals": totals, "tales": dialogues.size()}

func _need(run: RunState) -> int:
	return run.bando_quota - maxi(run.stake_glory, 0)

func _seat_action() -> bool:
	var case_ui: Node = scene.get_node("OpeningPrologue/SeatCase")
	if not case_ui.visible:
		return false
	match str(case_ui.get("mode")):
		"case":
			if str(opts.seat) == "witness":
				return _press("Btn_Seat_Witness")
			if str(opts.seat) == "reserve" and _available("Btn_Seat_Reserve"):
				return _press("Btn_Seat_Reserve")
			return _press("Btn_Seat_Defer")
		"inquiry":
			if str(opts.seat) == "defer":
				return _press("Btn_Seat_Defer")
			var seen: int = int(case_ui.get("inquiry").get("seen", 0))
			if (seen & 1) == 0:
				return _press("Btn_Seat_Reserve")
			if (seen & 2) == 0:
				return _press("Btn_Seat_Witness")
			return _press("Btn_Seat_Continue")
		"question":
			return _press("Btn_Seat_Reserve")
		"copy":
			if str(opts.copy) == "keep":
				return _press("Btn_Seat_Witness")
			if str(opts.copy) == "copy" and _available("Btn_Seat_Reserve"):
				return _press("Btn_Seat_Reserve")
			return _press("Btn_Seat_Defer")
		"ledger", "final_copy":
			# The last Era's sheets have no deferral: take the first offered choice.
			return _press("Btn_Seat_Witness") or _press("Btn_Seat_Reserve") or _press("Btn_Seat_Defer")
		"case_result", "inquiry_result", "copy_result", "final_result":
			return _press("Btn_Seat_Continue")
	return false

func _bando_live(run: RunState) -> bool:
	return run.bando_status == "open" and run.arena_index <= run.bando_deadline

func _shop(run: RunState) -> void:
	if str(opts.shop) == "never":
		return
	var view: Dictionary = manager.get_banco_view()
	if not bool(view.get("open", false)):
		return
	var denari: int = int(view.get("denari", 0))
	for item: Dictionary in view.get("items", []):
		if not bool(item.get("available", false)) or int(item.price) > denari - 3:
			continue
		var want: bool = false
		match str(item.id):
			"insure": want = run.stake_glory >= 6
			"favor": want = run.audience_score < 0
			"pressure": want = run.escalation_level >= 4
		if want:
			var discounted: bool = str(item.id) == "insure" and bool(manager.call("_seat_copy_insurance_discount"))
			root.get_node("GameEvents").request_banco_purchase.emit(str(item.id))
			run_stats.bought += 1
			if str(item.id) == "insure":
				run_stats.insured += 1
				if discounted: run_stats.discounted_policies += 1
			elif str(item.id) == "favor": run_stats.favor_bought += 1
			elif str(item.id) == "pressure": run_stats.pressure_bought += 1
			denari = int(manager.get_banco_view().get("denari", 0))

func _sign(run: RunState) -> void:
	var circle: Node = scene.get_node("UI/UI_RunRoot/BettingCircle")
	var best: int = 0
	var score: int = -999
	for side: int in range(2):
		var id: String = circle.call("_offer_id_at", side)
		if id == "":
			continue
		var profile: Dictionary = Catalog.get_pact_family_profile(StringName(id))
		var rank: int = int(profile.get("rank", 0))
		var weight: int = 0
		match str(opts.style):
			"prudent":
				weight = -rank
			"thin":
				weight = 10 if rank >= 2 else 0
			_:
				# Chase the bando: the doubling only when it closes the quota now.
				weight = rank
				if rank == 3:
					var doubled: int = maxi(run.stake_glory * 2, int(profile.get("stake_gain", 6)))
					weight = 10 if _bando_live(run) and run.stake_glory > 0 and doubled >= run.bando_quota else -10
		if weight > score:
			score = weight
			best = side
	var chosen: String = circle.call("_offer_id_at", best)
	run_stats.pacts += 1
	if int(Catalog.get_pact_family_profile(StringName(chosen)).get("rank", 0)) == 3:
		run_stats.hubris += 1
	_press("Btn_Sign_Left" if best == 0 else "Btn_Sign_Right")

func _answer_crowd(run: RunState) -> void:
	var index: int = 0
	if str(opts.crowd) == "read":
		match run.crowd_intent:
			"blood": index = 1 if run.escalation_level < 5 else 0
			"bored": index = 1 if run.escalation_level < 5 else 0
			"sand": index = 0
			"breath": index = 0
	run_stats.exchanges += 1
	run_stats.challenges += index
	_press("Btn_MID_CHOICE_SELECT_%d" % index)

func _strike_again(run: RunState) -> bool:
	if bool(manager.get("_seal_awaiting_scar_choice")):
		run_stats.scar_shown += 1
		return false
	run_stats.strike_offers += 1
	var count: int = int(manager.get("_seal_strike_count"))
	var preview: Dictionary = manager.call("_build_seal_strike_payload", run.active_bet_id, true, true)
	var held: int = int(preview.get("held_gain", 0))
	var next: int = int(preview.get("next_gain", 0))
	var strike: bool = false
	match str(opts.strike):
		"thin":
			strike = run.stake_glory < 6 and count < 2
		"bando":
			# Strike only when this seal alone falls short of the bando and one more closes it.
			var short: int = run.bando_quota - run.stake_glory
			strike = _bando_live(run) and run.arena_index == run.bando_deadline and held < short and held + next >= short
			if strike: run_stats.bando_strikes += 1
		"bando2":
			# The bando pays the extra strikes double: strike while it is open and
			# not yet reached; the third strike only at the last useful arena.
			var short2: int = run.bando_quota - run.stake_glory
			strike = _bando_live(run) and held < short2 and (count < 2 or run.arena_index == run.bando_deadline)
			if strike: run_stats.bando_strikes += 1
	if strike and _press("Btn_RESOLUTION_STRIKE"):
		run_stats.strikes += 1
		return true
	return false

func _push_or_cash(run: RunState) -> bool:
	# Returns true when it pushed on.
	var stake: int = maxi(run.stake_glory, 0)
	match str(opts.style):
		"prudent":
			if run.arena_index < 3:
				return _press("Btn_PUSH_YOUR_LUCK_DOUBLE")
			return false
		"thin":
			if run.arena_index < 3:
				return _press("Btn_PUSH_YOUR_LUCK_DOUBLE")
			return false
		_:
			if _bando_live(run):
				if stake >= run.bando_quota:
					return false
				if run.arena_index < run.bando_deadline:
					return _press("Btn_PUSH_YOUR_LUCK_DOUBLE")
				return false
			if stake < 4 and run.arena_index < 6:
				return _press("Btn_PUSH_YOUR_LUCK_DOUBLE")
			return false
