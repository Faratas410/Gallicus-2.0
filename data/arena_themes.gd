const ARENA_WAX_SEAL: StringName = &"ARENA_WAX_SEAL"
const ARENA_DEBT: StringName = &"ARENA_DEBT"
const ARENA_SILENCE: StringName = &"ARENA_SILENCE"
const ARENA_BLOOD: StringName = &"ARENA_BLOOD"

const THEMES: Dictionary = {
	ARENA_WAX_SEAL: {
		"title": "Arena del Sigillo",
		"subtitle": "Qui ogni firma pesa.",
		"bg_texture_path": "",
		"overlay_texture_path": "",
	},
	ARENA_DEBT: {
		"title": "Arena del Debito",
		"subtitle": "Il debito non muore con te.",
		"bg_texture_path": "",
		"overlay_texture_path": "",
	},
	ARENA_SILENCE: {
		"title": "Arena del Silenzio",
		"subtitle": "Nessuno ti applaude. Nessuno ti salva.",
		"bg_texture_path": "",
		"overlay_texture_path": "",
	},
	ARENA_BLOOD: {
		"title": "Arena del Sangue",
		"subtitle": "Il sangue è l’unica valuta accettata.",
		"bg_texture_path": "",
		"overlay_texture_path": "",
	},
}

func get_theme(theme_id: StringName) -> Dictionary:
	if THEMES.has(theme_id):
		return THEMES[theme_id] as Dictionary
	return THEMES.get(ARENA_WAX_SEAL, {}) as Dictionary
