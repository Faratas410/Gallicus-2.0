extends RefCounted
class_name RunScarSystem

func compute_modifiers(
	scars: Array[Dictionary],
	scar_open_wound: StringName,
	scar_cracked_bones: StringName
) -> Dictionary:
	var heal_multiplier: float = 1.0
	var dodge_cooldown_multiplier: float = 1.0
	var dodge_speed_multiplier: float = 1.0
	for scar: Dictionary in scars:
		var scar_id: StringName = StringName(str(scar.get("id", "")))
		match scar_id:
			scar_open_wound:
				heal_multiplier = minf(heal_multiplier, 0.6)
			scar_cracked_bones:
				dodge_cooldown_multiplier = maxf(dodge_cooldown_multiplier, 1.4)
				dodge_speed_multiplier = minf(dodge_speed_multiplier, 0.85)
			_:
				pass
	return {
		"heal_multiplier": heal_multiplier,
		"dodge_cooldown_multiplier": dodge_cooldown_multiplier,
		"dodge_speed_multiplier": dodge_speed_multiplier,
	}

func build_scar_payload(
	scar_id: StringName,
	origin_text: String,
	scar_def: Dictionary,
	default_name: String,
	default_story: String,
	default_effect: String
) -> Dictionary:
	var narrative_text: String = str(scar_def.get("narrative_text", scar_def.get("story", default_story)))
	var effect_text: String = str(scar_def.get("effect_text", scar_def.get("effect", default_effect)))
	return {
		"id": scar_id,
		"name": str(scar_def.get("name", default_name)),
		"origin": origin_text,
		"effect": str(scar_def.get("effect", default_effect)),
		"effect_text": effect_text,
		"story": str(scar_def.get("story", default_story)),
		"narrative_text": narrative_text,
		"short_desc": str(scar_def.get("short_desc", "")),
		"visual_tag": str(scar_def.get("visual_tag", "")),
		"tags": scar_def.get("tags", []) as Array,
	}

func project_modifiers_debug(mods: Dictionary) -> Dictionary:
	return {
		"mitigation_mod": float(mods.get("heal_multiplier", 1.0)),
		"avoidance_cooldown_mod": float(mods.get("dodge_cooldown_multiplier", 1.0)),
		"avoidance_speed_mod": float(mods.get("dodge_speed_multiplier", 1.0)),
	}
