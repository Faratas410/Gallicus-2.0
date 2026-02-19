extends RefCounted
class_name RunArenaThemePolicy

const ArenaThemes = preload("res://data/arena_themes.gd")

const SPECIAL_ARENA_SILENCE: StringName = &"ARENA_OF_SILENCE"
const SPECIAL_ARENA_ASH: StringName = &"ARENA_OF_ASH"
const SPECIAL_ARENA_DISPREZZO: StringName = &"ARENA_DISPREZZO"
const SPECIAL_ARENA_VERGOGNA: StringName = &"ARENA_VERGOGNA"


# Helper stateless/state-light:
# - NO get_tree / scene traversal
# - NO GameEvents emission
# - NO phase mutation
# - Solo decisioni di policy + lookup stringhe


func get_available_arena_theme_ids(is_finita_unlocked: bool, is_so_come_finisce_unlocked: bool) -> Array[StringName]:
	var themes: Array[StringName] = [
		ArenaThemes.ARENA_WAX_SEAL,
		ArenaThemes.ARENA_DEBT,
	]
	if is_finita_unlocked:
		themes.append(ArenaThemes.ARENA_BLOOD)
	if is_so_come_finisce_unlocked:
		themes.append(ArenaThemes.ARENA_SILENCE)
	return themes


func pick_next_arena_theme(arena_index: int, themes: Array[StringName]) -> StringName:
	if themes.is_empty():
		return ArenaThemes.ARENA_WAX_SEAL
	var theme_index: int = (maxi(arena_index, 1) - 1) % themes.size()
	return themes[theme_index]


func pick_special_arena_index(target_arenas: int, run_seed: int, rng: RandomNumberGenerator) -> int:
	if target_arenas <= 0:
		return 0
	var min_index: int = 2
	var max_index: int = maxi(target_arenas, min_index)
	rng.seed = run_seed + 117
	return rng.randi_range(min_index, max_index)


func should_activate_special_arena(arena_index: int, special_candidate_index: int, current_special_id: StringName) -> bool:
	if special_candidate_index <= 0:
		return false
	if current_special_id != &"":
		return false
	return arena_index == special_candidate_index


func pick_special_arena_id(run_seed: int, arena_index: int, rng: RandomNumberGenerator) -> StringName:
	var options: Array[StringName] = [
		SPECIAL_ARENA_SILENCE,
		SPECIAL_ARENA_ASH,
		SPECIAL_ARENA_DISPREZZO,
		SPECIAL_ARENA_VERGOGNA,
	]
	rng.seed = run_seed + arena_index * 23
	var pick_idx: int = rng.randi_range(0, options.size() - 1)
	return options[pick_idx]


func get_special_arena_title(arena_id: StringName) -> String:
	match arena_id:
		SPECIAL_ARENA_SILENCE:
			return "Arena of Silence"
		SPECIAL_ARENA_ASH:
			return "Arena of Ash"
		SPECIAL_ARENA_DISPREZZO:
			return "Arena del Disprezzo"
		SPECIAL_ARENA_VERGOGNA:
			return "Arena della Vergogna"
		_:
			return "Arena"


func get_special_arena_description(arena_id: StringName) -> String:
	match arena_id:
		SPECIAL_ARENA_SILENCE:
			return "L'escalation sale subito. Il rischio cresce, le ricompense restano."
		SPECIAL_ARENA_ASH:
			return "Ricompensa extra, ma una cicatrice è garantita."
		SPECIAL_ARENA_DISPREZZO:
			return "Qui non si incassa. La folla pretende un altro sangue."
		SPECIAL_ARENA_VERGOGNA:
			return "La vergogna intacca il favore. Il pubblico cala più in fretta."
		_:
			return ""
