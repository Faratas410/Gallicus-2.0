extends SceneTree

# Campaign simulator for tuning (not a CI gate). It drives the real UI like
# scripts/ci/campaign_runtime_contract.gd, with a player style chosen by args:
#   --style=bando|prudent|thin   how the percorso is played (see _push_or_cash)
#   --strike=never|thin|bando    when a held seal is struck again
#   --crowd=read|bow             how the stands are answered
#   --runs=N --seed=S            campaign length cap and seed base
# Prints one SIM_RUN json line per percorso and a SIM_SUMMARY at the end.
# Run: godot --headless --audio-driver Dummy --path . --script res://tools/campaign_sim.gd -- --style=bando
const Catalog = preload("res://scripts/content/bet_catalog.gd")
var scene: Node
var manager: Node
var save: Node
var closed: bool = false
var reason: String = ""
var opts: Dictionary = {"style": "bando", "strike": "bando", "crowd": "read", "runs": "80", "seed": "1782373819"}
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
	var rows: Array[Dictionary] = []
	for index: int in range(int(opts.runs)):
		closed = false
		run_stats = {"strike_offers": 0, "strikes": 0, "strikes_held": 0, "bando_strikes": 0, "exchanges": 0, "challenges": 0, "scar_shown": 0, "hubris": 0, "pacts": 0, "insured": 0, "bought": 0}
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
		row.merge({"run": index + 1, "reason": reason, "glory": int(manager.get("_run_state").glory) if reason == "CASH_OUT" else 0,
			"arenas": manager.get("_run_state").arena_index, "quota": quota, "deadline": deadline,
			"bando": save.get_bando_step() > step_before, "step": save.get_bando_step(),
			"denari": save.get_ledger_denari(), "era": save.get_registry_era()}, true)
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
	print("SIM_SUMMARY ", JSON.stringify(_summary(rows)))
	scene.queue_free()
	await create_timer(1.0).timeout
	quit(0)

func _summary(rows: Array[Dictionary]) -> Dictionary:
	var glories: Array[int] = []
	var zero: int = 0
	var bandi: int = 0
	var min_denari: int = 0
	var max_denari: int = 0
	var debt_runs: int = 0
	var debt_spells: Array[int] = []
	var spell: int = 0
	var totals: Dictionary = {}
	var step8: int = -1
	var step12: int = -1
	for row: Dictionary in rows:
		if row.reason == "CASH_OUT":
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
		for key: String in ["strike_offers", "strikes", "strikes_held", "bando_strikes", "exchanges", "challenges", "scar_shown", "hubris", "pacts", "insured", "bought"]:
			totals[key] = int(totals.get(key, 0)) + int(row[key])
	if spell > 0:
		debt_spells.append(-spell)
	glories.sort()
	return {"opts": opts, "runs": rows.size(), "absence": rows.size() > 0 and int(rows.back().era) == 4,
		"zero_glory_pct": roundi(100.0 * zero / maxf(rows.size(), 1)), "median_cashout": glories[glories.size() / 2] if not glories.is_empty() else 0,
		"bandi": bandi, "step_final": int(rows.back().step) if not rows.is_empty() else 0, "step8_run": step8, "step12_run": step12,
		"denari_min": min_denari, "denari_max": max_denari, "denari_final": int(rows.back().denari) if not rows.is_empty() else 0,
		"debt_runs": debt_runs, "debt_spells": debt_spells, "totals": totals, "tales": dialogues.size()}

func _need(run: RunState) -> int:
	return run.bando_quota - maxi(run.stake_glory, 0)

func _bando_live(run: RunState) -> bool:
	return run.bando_status == "open" and run.arena_index <= run.bando_deadline

func _shop(run: RunState) -> void:
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
			root.get_node("GameEvents").request_banco_purchase.emit(str(item.id))
			run_stats.bought += 1
			if str(item.id) == "insure": run_stats.insured += 1
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
