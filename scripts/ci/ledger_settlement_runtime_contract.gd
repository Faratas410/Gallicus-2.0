extends SceneTree

# Exercise the zero-crossing case through RunManager's real settlement path.
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var manager = load("res://scripts/systems/run_manager.gd").new()
	var save = root.get_node("SaveManager")
	var run := RunState.new()
	manager.set("_run_state", run)
	run.arena_index = 1
	run.bando_quota = 10
	run.bando_deadline = 4
	run.glory = 30
	var results: Array[int] = []
	for closed: bool in [false, true]:
		save.set_ledger_denari(-3)
		save.set_bando_step(0)
		save.set_bando_acclaim(false)
		run.bando_status = "open" if closed else "missed"
		manager.call("_settle_ledger_at_run_end", "CASH_OUT")
		results.append(save.get_ledger_denari())
	save.set_ledger_denari(3)
	save.set_bando_step(0)
	run.bando_status = "open"
	manager.call("_settle_ledger_at_run_end", "CASH_OUT")
	results.append(save.get_ledger_denari())
	save.set_ledger_denari(-3)
	run.bando_status = "open"
	manager.call("_settle_ledger_at_run_end", "DOUBLE_OR_DIE")
	results.append(save.get_ledger_denari())
	manager.free()
	await preload("res://scripts/ci/audio_test_teardown.gd").finish(self)
	if results != [17, 22, 18, -8]:
		push_error("LEDGER_SETTLEMENT_CONTRACT: expected [17, 22, 18, -8], got %s" % str(results))
		quit(1)
	else:
		print("LEDGER_SETTLEMENT_CONTRACT_OK")
		quit(0)
