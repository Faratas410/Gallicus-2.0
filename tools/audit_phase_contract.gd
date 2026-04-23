extends SceneTree

# Audit-only script: parses source files to verify RunPhaseContract identity + UI references + Phase_* nodes.
# Run with:
#   Godot_v4.6-stable_* --headless --path <PROJECT_ROOT> --script res://tools/audit_phase_contract.gd
#
# Output uses AUDIT:* markers for easy log scanning.

const _RUN_PHASE_CONTRACT_PATH: String = "res://scripts/contracts/run_phase_contract.gd"
const _UI_ROOT_PATH: String = "res://scripts/ui/ui_root.gd"
const _UI_SCENE_PATH: String = "res://scenes/UI.tscn"

func _initialize() -> void:
	var ok: bool = true
	print("AUDIT:BEGIN PhaseContract")

	var phase_contract_text: String = _read_text(_RUN_PHASE_CONTRACT_PATH)
	var ui_text: String = _read_text(_UI_ROOT_PATH)
	var scene_text: String = _read_text(_UI_SCENE_PATH)

	if phase_contract_text.is_empty():
		_push_fail("RunPhaseContract file missing/empty: %s" % _RUN_PHASE_CONTRACT_PATH)
		ok = false
	if ui_text.is_empty():
		_push_fail("UIRoot file missing/empty: %s" % _UI_ROOT_PATH)
		ok = false
	if scene_text.is_empty():
		_push_fail("UI scene missing/empty: %s" % _UI_SCENE_PATH)
		ok = false

	if not ok:
		_finish(false)
		return

	var phase_contract: Dictionary = _parse_phase_contract_constants(phase_contract_text)
	if phase_contract.is_empty():
		_push_fail("Could not parse phase constants from %s" % _RUN_PHASE_CONTRACT_PATH)
		_finish(false)
		return

	_print_enum("RunPhaseContract", phase_contract)

	var ui_phase_refs: Array[String] = _scan_ui_root_phase_refs(ui_text)
	_print_list("UIRoot phase refs (RunPhaseContract.<NAME>)", ui_phase_refs)

	var ui_numeric_cases: Array[String] = _scan_ui_root_numeric_cases(ui_text)
	_print_list("UIRoot numeric match cases (N:)", ui_numeric_cases)

	var ui_scene_phase_nodes: Array[String] = _scan_ui_scene_phase_nodes(scene_text)
	_print_list("UI scene Phase_* nodes", ui_scene_phase_nodes)

	# Basic coherence checks (safe, non-invasive):
	# 1) Every UIRoot referenced RunPhaseContract.<NAME> must exist in RunPhaseContract.
	var missing_in_contract: Array[String] = []
	for name in ui_phase_refs:
		if not phase_contract.has(name):
			missing_in_contract.append(name)
	if not missing_in_contract.is_empty():
		_push_fail("UIRoot references phases not found in RunPhaseContract: %s" % ", ".join(missing_in_contract))
		ok = false

	# 2) UI scene must contain at least one Phase_* node (sanity) and should contain canonical containers.
	# Canonical containers (UI contract doc): INTRO, FIRST_REACTION, MID_CHOICE, PUSH_YOUR_LUCK, RESOLUTION overlay container, END_RUN
	var required_phase_nodes: Array[String] = [
		"Phase_INTRO",
		"Phase_FIRST_REACTION",
		"Phase_MID_CHOICE",
		"Phase_PUSH_YOUR_LUCK",
		"Phase_RESOLUTION",
		"Phase_END_RUN",
	]
	if ui_scene_phase_nodes.is_empty():
		_push_fail("UI scene contains no Phase_* nodes. Expected nodes like Phase_INTRO etc.")
		ok = false
	else:
		var missing_nodes: Array[String] = []
		for n in required_phase_nodes:
			if not ui_scene_phase_nodes.has(n):
				missing_nodes.append(n)
		if not missing_nodes.is_empty():
			_push_fail("UI scene missing canonical phase containers: %s" % ", ".join(missing_nodes))
			ok = false

	# 3) If UIRoot uses numeric match cases, warn loudly (fragile mapping risk).
	if not ui_numeric_cases.is_empty():
		_push_warn("UIRoot appears to use numeric phase cases (e.g., '14:'). This is fragile vs enum drift.")

	_finish(ok)


func _finish(ok: bool) -> void:
	if ok:
		print("AUDIT:RESULT OK")
	else:
		print("AUDIT:RESULT FAIL")
	print("AUDIT:END PhaseContract")
	quit(0 if ok else 1)


func _read_text(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	return f.get_as_text()


func _parse_phase_contract_constants(text: String) -> Dictionary:
	var out: Dictionary = {}
	var re: RegEx = RegEx.new()
	re.compile("(?m)^\\s*const\\s+([A-Z0-9_]+)\\s*:\\s*int\\s*=\\s*(-?\\d+)\\b")
	for match in re.search_all(text):
		var name: String = String(match.get_string(1))
		var value: int = int(match.get_string(2))
		out[name] = value
	return out


func _scan_ui_root_phase_refs(text: String) -> Array[String]:
	# Collect RunPhaseContract.<NAME> (and RunPhaseContractScript.<NAME>) references.
	var re: RegEx = RegEx.new()
	re.compile("RunPhaseContract(?:Script)?\\.([A-Z0-9_]+)")
	var found: Array[String] = []
	for m in re.search_all(text):
		var name: String = String(m.get_string(1))
		if not found.has(name):
			found.append(name)
	found.sort()
	return found


func _scan_ui_root_numeric_cases(text: String) -> Array[String]:
	# Collect lines like "14:" (match/case), used as a risk signal.
	var re: RegEx = RegEx.new()
	re.compile("(?m)^\\s*(\\d+)\\s*:")
	var found: Array[String] = []
	for m in re.search_all(text):
		var n: String = String(m.get_string(1))
		if not found.has(n):
			found.append(n)
	found.sort_custom(func(a: String, b: String) -> bool: return int(a) < int(b))
	return found


func _scan_ui_scene_phase_nodes(text: String) -> Array[String]:
	# Parse .tscn for nodes named Phase_*
	var re: RegEx = RegEx.new()
	re.compile("(?m)^\\[node\\s+name=\\\"(Phase_[A-Z0-9_]+)\\\"")
	var found: Array[String] = []
	for m in re.search_all(text):
		var n: String = String(m.get_string(1))
		if not found.has(n):
			found.append(n)
	found.sort()
	return found


func _print_enum(title: String, d: Dictionary) -> void:
	print("AUDIT:SECTION %s" % title)
	var keys: Array = d.keys()
	keys.sort_custom(func(a: Variant, b: Variant) -> bool:
		return int(d[a]) < int(d[b])
	)
	for k in keys:
		print("AUDIT:ENUM %s = %d" % [String(k), int(d[k])])


func _print_list(title: String, items: Array[String]) -> void:
	print("AUDIT:SECTION %s" % title)
	if items.is_empty():
		print("AUDIT:EMPTY")
		return
	for it in items:
		print("AUDIT:ITEM %s" % it)


func _push_fail(msg: String) -> void:
	push_error("AUDIT:FAIL " + msg)


func _push_warn(msg: String) -> void:
	push_warning("AUDIT:WARN " + msg)
