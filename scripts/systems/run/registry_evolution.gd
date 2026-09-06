extends RefCounted

# Pure campaign calculation. RunManager alone commits this result and ends runs.
const AXES: Array[String] = ["risk_bias", "repetition_bias", "scar_tolerance", "volatility"]

static func defaults() -> Dictionary:
	return {"signature": {"risk_bias": 0.0, "repetition_bias": 0.0, "scar_tolerance": 0.0, "volatility": 0.0}, "fixed": false, "entry_streak": 0, "stable_streak": 0, "samples": 0, "era_runs": 0, "ramp_runs": 3, "paths_seen": [], "observations": [], "last_class": "", "convergence": 0}

static func sanitize(source: Dictionary) -> Dictionary:
	var state: Dictionary = defaults()
	var signature: Dictionary = source.get("signature", {}) if source.get("signature", {}) is Dictionary else {}
	for axis: String in AXES:
		var value: float = _number(signature.get(axis, 0.0))
		state.signature[axis] = clampf(value, -1.0 if axis == "risk_bias" else 0.0, 1.0) if is_finite(value) else 0.0
	state.fixed = source.get("fixed", false) is bool and bool(source.get("fixed", false))
	for key: String in ["entry_streak", "stable_streak", "samples", "era_runs", "ramp_runs", "convergence"]:
		state[key] = int(clampf(_number(source.get(key, state[key])), 0.0, 100000.0))
	state.ramp_runs = mini(int(state.ramp_runs), 3)
	state.last_class = str(source.get("last_class", "")).left(64)
	for key: String in ["paths_seen", "observations"]:
		if source.get(key, []) is Array:
			for item: Variant in source.get(key, []):
				var value: String = str(item).left(128)
				if value != "" and not state[key].has(value) and state[key].size() < 16:
					state[key].append(value)
	return state

static func _number(value: Variant) -> float:
	if value is int or value is float:
		return float(value) if is_finite(float(value)) else 0.0
	return 0.0

static func coherence(signature: Dictionary) -> float:
	return clampf(absf(float(signature.risk_bias)) * 0.4 + float(signature.repetition_bias) * 0.35 + float(signature.scar_tolerance) * 0.25 - float(signature.volatility) * 0.2, 0.0, 1.0)

static func advance(previous: Dictionary, era: int, sample: Dictionary) -> Dictionary:
	var state: Dictionary = sanitize(previous)
	var result: Dictionary = {"state": state, "era": clampi(era, 0, 4), "silence": false}
	if era >= 4 or int(sample.get("choices", 0)) <= 0:
		return result
	var observed: Dictionary = sanitize({"signature": sample.get("signature", {})}).signature
	var smoothing: float = 0.08 if bool(state.fixed) else 0.3
	if int(state.samples) == 0:
		smoothing = 1.0
	var distance: float = 0.0
	for axis: String in AXES:
		var value: float = clampf(float(observed.get(axis, 0.0)), -1.0 if axis == "risk_bias" else 0.0, 1.0)
		distance += absf(value - float(state.signature[axis])) / float(AXES.size())
		state.signature[axis] = lerpf(float(state.signature[axis]), value, smoothing)
	var consistency: float = coherence(state.signature)
	state.entry_streak = int(state.entry_streak) + 1 if consistency > 0.72 else 0
	if not bool(state.fixed) and int(state.entry_streak) >= 2:
		state.fixed = true
	elif bool(state.fixed) and consistency < 0.40:
		state.fixed = false
		state.entry_streak = 0
	state.stable_streak = int(state.stable_streak) + 1 if distance < 0.16 + float(era) * 0.02 else 0
	state.samples = int(state.samples) + 1
	state.era_runs = int(state.era_runs) + 1
	state.ramp_runs = mini(int(state.ramp_runs) + 1, 3)
	for path: Variant in sample.get("paths", []) as Array:
		if not state.paths_seen.has(str(path)):
			state.paths_seen.append(str(path))
	var observation: String = str(sample.get("observation", ""))
	if observation != "" and not state.observations.has(observation) and state.observations.size() < 16:
		state.observations.append(observation)
	var classification: String = str(sample.get("classification", ""))
	state.convergence = int(state.convergence) + 1 if classification != "" and classification == str(state.last_class) else 1
	state.last_class = classification
	# A stable strategy alone is insufficient: different observed histories must
	# converge to the same interpretation after the transition ramp has completed.
	var saturated: bool = state.observations.size() >= 3 and state.paths_seen.size() >= 3 and int(state.convergence) >= 3
	if bool(state.fixed) and int(state.stable_streak) >= 3 and int(state.era_runs) >= 8 - mini(era, 3) and saturated:
		result.silence = true
		result.era = mini(era + 1, 4)
		state.era_runs = 0
		state.ramp_runs = 0
		state.observations = []
		state.paths_seen = []
		state.convergence = 0
	return result
