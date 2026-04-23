class_name RunSaveFlowStepContract
extends RefCounted

# Canonical live flow-step values used by active runtime.
const BET_SIGNED: StringName = &"BET_SIGNED"
const INTERMEDIATE_CHOICE: StringName = &"INTERMEDIATE_CHOICE"
const PUSH_LUCK: StringName = &"PUSH_LUCK"
const BET_OFFER: StringName = &"BET_OFFER"

const CANONICAL_LIVE_VALUES: Array[StringName] = [
	BET_SIGNED,
	INTERMEDIATE_CHOICE,
	PUSH_LUCK,
	BET_OFFER,
]

# Boundary-only legacy aliases. These must never propagate as live runtime values.
const LEGACY_BOUNDARY_TO_CANONICAL: Dictionary = {
	&"RESOLUTION": INTERMEDIATE_CHOICE,
	&"RUN_FLOW_RESOLUTION": INTERMEDIATE_CHOICE,
	&"PHASE_RESOLUTION": INTERMEDIATE_CHOICE,
	&"POST_BET_MESSAGES": INTERMEDIATE_CHOICE,
	&"RUN_FLOW_POST_BET_MESSAGES": INTERMEDIATE_CHOICE,
	&"PHASE_POST_BET_MESSAGES": INTERMEDIATE_CHOICE,
	&"14": INTERMEDIATE_CHOICE,
	&"18": INTERMEDIATE_CHOICE,
}

static func is_canonical_live_value(value: StringName) -> bool:
	return CANONICAL_LIVE_VALUES.has(value)


static func canonical_live_values() -> Array[StringName]:
	return CANONICAL_LIVE_VALUES.duplicate()


static func requires_bet_id(value: StringName) -> bool:
	return value == BET_SIGNED or value == INTERMEDIATE_CHOICE or value == PUSH_LUCK


static func normalize_boundary_value(raw_value: StringName, legacy_non_mainline_phase_seen: bool, has_bet_id: bool) -> StringName:
	var normalized: StringName = raw_value
	if normalized == &"":
		normalized = BET_OFFER
	elif LEGACY_BOUNDARY_TO_CANONICAL.has(normalized):
		normalized = LEGACY_BOUNDARY_TO_CANONICAL.get(normalized, &"") as StringName
	elif legacy_non_mainline_phase_seen:
		normalized = INTERMEDIATE_CHOICE

	if requires_bet_id(normalized) and not has_bet_id:
		return BET_OFFER
	if is_canonical_live_value(normalized):
		return normalized
	return &""
