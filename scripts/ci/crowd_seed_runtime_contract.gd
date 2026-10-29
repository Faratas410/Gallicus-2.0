extends SceneTree

# Crowd choices must derive from the saved run, not the wall clock or the
# smoke-test environment. This also checks the previous intent exclusion.
func _initialize() -> void:
	var manager = load("res://scripts/systems/run_manager.gd").new()
	var run := RunState.new()
	manager.set("_run_state", run)
	var errors := 0
	for run_seed: int in [11, 250, 1782373819]:
		for arena: int in [1, 3, 7]:
			for exchange: int in [0, 1, 2]:
				for previous: String in ["", "blood", "sand", "bored", "breath"]:
					run.run_seed = run_seed
					run.arena_index = arena
					run.crowd_exchange_index = exchange
					run.crowd_intent = previous
					var candidates: Array[String] = []
					for intent: String in manager.CROWD_INTENT_ORDER:
						if intent != previous:
							candidates.append(intent)
					var rng := RandomNumberGenerator.new()
					rng.seed = run_seed + arena * 97 + exchange * 13 + 101
					var expected: String = candidates[rng.randi_range(0, candidates.size() - 1)]
					manager.call("_pick_crowd_intent")
					if run.crowd_intent != expected:
						errors += 1
					run.crowd_intent = previous
					var restored := RunState.new()
					restored.from_dict(run.to_dict())
					manager.set("_run_state", restored)
					manager.call("_pick_crowd_intent")
					if restored.crowd_intent != expected:
						errors += 1
					manager.set("_run_state", run)
	manager.free()
	if errors:
		push_error("CROWD_SEED_CONTRACT: %d mismatches" % errors)
		quit(1)
	else:
		print("CROWD_SEED_CONTRACT_OK")
		quit(0)
