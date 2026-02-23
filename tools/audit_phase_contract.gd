extends SceneTree

# Audit-only script: parses source files to verify phase enum + UI references + Phase_* nodes exist.
# Run with:
#   Godot_v4.6-stable_* --headless --path <PROJECT_ROOT> --script res://tools/audit_phase_contract.gd
#
# Output uses AUDIT:* markers for easy log scanning.

const _RUN_MANAGER_PATH: String = "res://scripts/systems/run_manager.gd"
const _UI_ROOT_PATH: String = "res://scripts/ui/ui_root.gd"
const _UI_SCENE_PATH: String = "res://scenes/UI.tscn"

func _initialize() -> void:
	var ok: bool = true
	print("AUDIT:BEGIN PhaseContract")

	var rm_text: String = _read_text(_RUN_MANAGER_PATH)
	var ui_text: String = _read_text(_UI_ROOT_PATH)
	var scene_text: String = _read_text(_UI_SCENE_PATH)

	if rm_text.is_empty():
		_push_fail("RunManager file missing/empty: %s" % _RUN_MANAGER_PATH)
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

	var rm_enum: Dictionary = _parse_enum_block(rm_text, "RunPhase")
	if rm_enum.is_empty():
		_push_fail("Could not parse enum RunPhase from %s" % _RUN_MANAGER_PATH)
		_finish(false)
		return

	_print_enum("RunManager.RunPhase", rm_enum)

	var ui_phase_refs: Array[String] = _scan_ui_root_phase_refs(ui_text)
	_print_list("UIRoot phase refs (RunPhase.<NAME>)", ui_phase_refs)

	var ui_numeric_cases: Array[String] = _scan_ui_root_numeric_cases(ui_text)
	_print_list("UIRoot numeric match cases (N:)", ui_numeric_cases)

	var ui_scene_phase_nodes: Array[String] = _scan_ui_scene_phase_nodes(scene_text)
	_print_list("UI scene Phase_* nodes", ui_scene_phase_nodes)

	# Basic coherence checks (safe, non-invasive):
	# 1) Every UIRoot referenced RunPhase.<NAME> must exist in RunManager enum.
	var missing_in_rm: Array[String] = []
	for name in ui_phase_refs:
		if not rm_enum.has(name):
			missing_in_rm.append(name)
	if not missing_in_rm.is_empty():
		_push_fail("UIRoot references phases not found in RunManager enum: %s" % ", ".join(missing_in_rm))
		ok = false

	# 2) UI scene must contain at least one Phase_* node (sanity) and should contain canonical containers.
	# Canonical phase containers (UI contract doc): INTRO, FIRST_REACTION, MID_CHOICE, PUSH_YOUR_LUCK, RESOLUTION, END_RUN
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


func _parse_enum_block(text: String, enum_name: String) -> Dictionary:
	# Parses:
	# enum RunPhase { A = 0, B, C = 7, D }
	# or multiline form.
	var start_idx: int = text.find("enum %s" % enum_name)
	if start_idx == -1:
		return {}
	var brace_open: int = text.find("{", start_idx)
	if brace_open == -1:
		return {}
	var brace_close: int = text.find("}", brace_open)
	if brace_close == -1:
		return {}

	var body: String = text.substr(brace_open + 1, brace_close - brace_open - 1)
	# Strip comments (simple line-based)
	var cleaned_lines: Array[String] = []
	for raw_line in body.split("\n"):
		var line: String = raw_line
		var c: int = line.find("#")
		if c != -1:
			line = line.substr(0, c)
		c = line.find("//")
		if c != -1:
			line = line.substr(0, c)
		line = line.strip_edges()
		if not line.is_empty():
			cleaned_lines.append(line)
	var cleaned: String = " ".join(cleaned_lines)

	# Split by commas
	var parts: PackedStringArray = cleaned.split(",", false)
	var out: Dictionary = {}
	var next_value: int = 0
	for part_raw in parts:
		var part: String = String(part_raw).strip_edges()
		if part.is_empty():
			continue
		# Allow trailing semicolons etc.
		part = part.replace(";", "").strip_edges()
		var eq: int = part.find("=")
		if eq != -1:
			var name: String = part.substr(0, eq).strip_edges()
			var value_str: String = part.substr(eq + 1, part.length() - eq - 1).strip_edges()
			var value: int = int(value_str)
			out[name] = value
			next_value = value + 1
		else:
			var name2: String = part.strip_edges()
			out[name2] = next_value
			next_value += 1
	return out


func _scan_ui_root_phase_refs(text: String) -> Array[String]:
	# Collect RunPhase.<NAME> references
	var re: RegEx = RegEx.new()
	re.compile("RunPhase\\.([A-Z0-9_]+)")
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
