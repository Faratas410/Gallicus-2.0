extends RefCounted
class_name EndingRules

const CORRUPTION_THRESHOLDS: Dictionary = {
	"PURE": 2,
	"TAINTED": 5,
	"CORRUPT": 8,
}

const GLORY_THRESHOLDS: Dictionary = {
	"LOW": 2,
	"MID": 5,
	"HIGH": 8,
}

static func dominant_rules() -> Array[Dictionary]:
	return [
		{"id": "PATH_MARTYR_01", "ending_key": &"THE_MARTYR", "priority": 120, "requires": {"min_double": 4, "min_condanna": 2}},
		{"id": "PATH_HUBRIS_01", "ending_key": &"THE_FOOL", "priority": 110, "requires": {"min_double": 3, "min_corruption": 7}},
		{"id": "PATH_FALL_01", "ending_key": &"THE_FALL", "priority": 108, "requires": {"min_corruption": 5}},
		{"id": "PATH_DEBT_01", "ending_key": &"THE_DEBTOR", "priority": 100, "requires": {"min_path_prudence": 3}},
		{"id": "PATH_GLORY_01", "ending_key": &"THE_LIBERTY", "priority": 95, "requires": {"min_glory": 8, "max_corruption": 3, "min_path_hubris": 2}},
		{"id": "PATH_PET_01", "ending_key": &"THE_CROWD_PET", "priority": 90, "requires": {"min_cashout": 3, "max_double": 1}},
		{"id": "PATH_MARKED_01", "ending_key": &"THE_MARKED", "priority": 85, "requires": {"min_condanna": 1, "max_condanna": 1}},
		{"id": "PATH_BROKEN_01", "ending_key": &"THE_BROKEN", "priority": 80, "requires": {"min_condanna": 2, "min_corruption": 5}},
		{"id": "PATH_SURVIVOR_01", "ending_key": &"THE_SURVIVOR", "priority": 70, "requires": {"max_condanna": 0, "max_corruption": 4}},
		{"id": "PATH_PROVOKE_01", "ending_key": &"THE_DEBTOR", "priority": 65, "requires": {"requires_provoke_armed": true, "min_double": 2}},
	]

static func morale_fallback_rules() -> Array[Dictionary]:
	return [
		{"id": "MORALE_PURE_HIGH", "ending_key": &"THE_LIBERTY", "priority": 40, "requires": {"corruption_tier": "PURE", "glory_tier": "HIGH"}},
		{"id": "MORALE_DAMNED_ANY", "ending_key": &"THE_FALL", "priority": 35, "requires": {"corruption_tier": "DAMNED"}},
		{"id": "MORALE_CORRUPT_LOW", "ending_key": &"THE_BROKEN", "priority": 30, "requires": {"corruption_tier": "CORRUPT", "glory_tier": "LOW"}},
		{"id": "MORALE_TAINTED_MID", "ending_key": &"THE_MARKED", "priority": 20, "requires": {"corruption_tier": "TAINTED", "glory_tier": "MID"}},
	]


# Deprecated key support for one sprint: finale_builder still reads "min_path_debt" as alias of "min_path_prudence".
