extends "res://tools/visual_qa_capture.gd"

var audit_dir: String = "res://artifacts/screen_audit_2026-09-08"
var _audit_rows: Array[Dictionary] = []
var _phase_audio: Array[Dictionary] = []
var _linear: bool = false
var _music_record: AudioEffectRecord

func _run() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--audit-dir="):
			audit_dir = argument.trim_prefix("--audit-dir=")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(audit_dir + "/screenshots"))
	await _settle(30)
	if OS.get_cmdline_user_args().has("--prologue-only"):
		await _capture_prologue_matrix()
		return
	GameEvents.run_phase_changed.connect(_observe_phase)
	_linear = OS.get_cmdline_user_args().has("--linear")
	if _linear:
		_music_record = AudioEffectRecord.new()
		_music_record.format = AudioStreamWAV.FORMAT_16_BITS
		AudioServer.add_bus_effect(AudioServer.get_bus_index("Music"), _music_record)
		_music_record.set_recording_active(true)
		await _capture("00_menu_it_1280x720", VIEWPORT_SIZE)
		await super._run()
		return
	var menu: Node = get_node("MenuLayer/MainMenu")
	for locale: String in ["it", "en", "es"]:
		_select_settings_locale(menu, locale)
		for viewport_size: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
			DisplayServer.window_set_size(viewport_size)
			get_tree().root.content_scale_size = viewport_size
			get_tree().root.size = viewport_size
			menu.call("_show_menu")
			await _settle(30)
			var suffix: String = "%s_%dx%d" % [locale, viewport_size.x, viewport_size.y]
			await _capture("00_menu_" + suffix, viewport_size)
			menu.call("_on_achievements_pressed")
			await _capture("10_archive_condanne_" + suffix, viewport_size)
			menu.call("_on_condanna_mouse_entered", preload("res://data/condanne.gd").defaults()[0])
			await _settle(10)
			menu.call("_place_condanna_tooltip", Vector2(viewport_size) - Vector2(2, 2))
			await _capture("22_archive_tooltip_" + suffix, viewport_size)
			menu.call("_on_condanna_mouse_exited")
			menu.call("_on_museo_tab_pressed")
			await _capture("11_archive_museum_" + suffix, viewport_size)
			menu.call("_on_back_pressed")
			menu.call("_on_credits_pressed")
			await _capture("12_credits_" + suffix, viewport_size)
			menu.call("_on_credits_back_pressed")
			menu.call("_show_settings")
			await _capture("19_settings_" + suffix, viewport_size)
			for field: String in ["language_option", "resolution_option"]:
				var option: OptionButton = menu.get(field)
				option.show_popup()
				await _settle(12)
				await RenderingServer.frame_post_draw
				var popup: PopupMenu = option.get_popup()
				popup.get_texture().get_image().save_png(audit_dir + "/screenshots/20_popup_" + field + "_" + suffix + ".png")
				if popup.get_theme_stylebox("hover").resource_path != "res://assets/ui/official/styleboxes/sb_button_primary_hover.tres":
					_failures.append("Popup lost shared hover style")
				popup.hide()
			menu.call("_show_menu")
	_select_settings_locale(menu, "it")
	DisplayServer.window_set_size(VIEWPORT_SIZE)
	get_tree().root.content_scale_size = VIEWPORT_SIZE
	get_tree().root.size = VIEWPORT_SIZE
	await super._run()

func _observe_phase(phase: int) -> void:
	_phase_audio.append({"phase": phase, "ms": Time.get_ticks_msec(), "audio": _audio_snapshot()})

func _audio_snapshot() -> Dictionary:
	var director: Node = get_node("MusicDirector")
	var players: Array[Dictionary] = []
	for player: AudioStreamPlayer in director.get("_players"):
		players.append({"path": str(player.get_path()), "playing": player.playing, "stream": player.stream.resource_path if player.stream else "", "position": player.get_playback_position(), "db": player.volume_db})
	return {"key": director.get("_active_key"), "players": players}

func _capture(name: String, expected_size: Vector2i = Vector2i.ZERO) -> void:
	if _linear:
		name = "live_" + name
		await get_tree().create_timer(0.4).timeout
	await _settle(10)
	await RenderingServer.frame_post_draw
	var frame: Image = get_tree().root.get_texture().get_image()
	if frame == null or frame.is_empty() or (expected_size != Vector2i.ZERO and frame.get_size() != expected_size):
		_failures.append("Invalid audit capture: " + name)
		return
	frame.save_png(audit_dir + "/screenshots/" + name + ".png")
	var controls: Array[Dictionary] = []
	_collect_controls(self, controls)
	_audit_rows.append({"name":name, "size":str(frame.get_size()), "locale":TranslationServer.get_locale(), "controls":controls, "audio":_audio_snapshot()})
	print("SCREEN_AUDIT_CAPTURE ", name)
	if _linear:
		var expected_score: Dictionary = {"live_02_register_closed":"safe", "live_03_register_open":"safe", "live_04_pact_signed":"tense", "live_05_intermediate_choice":"tense", "live_06_resolve_ritual":"tense", "live_07_push_your_luck":"climax", "live_08_end_run":"ending"}
		if expected_score.has(name):
			var music: Node = get_node("MusicDirector")
			var player: AudioStreamPlayer = music.get("_players")[int(music.get("_active"))]
			if _audio_snapshot().key != expected_score[name] or not player.playing or player.stream.resource_path != music.TRACKS[expected_score[name]]:
				_failures.append("Incorrect runtime score at " + name + ": " + str(_audio_snapshot().key))
	if name == "live_07_push_your_luck":
		# Presentation sample only; do not modify a save, scar or outcome.
		var ui: Node = get_node("UI")
		var previous: String = ui.get("_scars_detail_text")
		ui.set("_scars_detail_text", "MARCHIO DEL DEBITO\nOgni futura scommessa pesa di piu'.")
		ui.call("_show_scars_detail")
		if not ui.get("scars_detail_panel").is_visible_in_tree():
			_failures.append("Scar detail did not open")
		await _capture("15_scars_detail_sample")
		ui.call("_hide_scars_detail")
		ui.set("_scars_detail_text", previous)
		ui.call("_show_scar_popup", {"name":"MARCHIO DEL DEBITO", "narrative_text":"Il Registro conserva il segno.", "effect_text":"Ogni futura scommessa pesa di piu'."})
		if not ui.get("scar_popup_panel").is_visible_in_tree():
			_failures.append("Scar notice did not open")
		await _capture("16_scar_notice_sample")
		ui.call("_hide_scar_popup")

func _style_info(style: StyleBox) -> Dictionary:
	var result: Dictionary = {"class":style.get_class(), "resource":style.resource_path}
	if style is StyleBoxTexture:
		result["texture"] = style.texture.resource_path if style.texture else ""
		result["modulate"] = str(style.modulate_color)
	elif style is StyleBoxFlat:
		result["color"] = str(style.bg_color)
		result["border"] = str(style.border_color)
	return result

func _collect_controls(node: Node, output: Array[Dictionary]) -> void:
	if node is Control and node.is_visible_in_tree():
		var control: Control = node as Control
		var row: Dictionary = {"path":str(control.get_path()), "class":control.get_class(), "rect":str(control.get_global_rect()), "theme":control.theme.resource_path if control.theme else "inherited"}
		if node is Button:
			row["text"] = node.text
			row["disabled"] = node.disabled
			row["styles"] = {}
			for state: String in ["normal", "hover", "pressed", "focus", "disabled"]:
				row.styles[state] = _style_info(control.get_theme_stylebox(state))
		elif node is Panel or node is PanelContainer or node is PopupPanel:
			row["styles"] = {"panel":_style_info(control.get_theme_stylebox("panel"))}
		elif node is TextureRect:
			row["texture"] = node.texture.resource_path if node.texture else ""
		elif node is Label:
			row["text"] = node.text
			row["font_size"] = node.get_theme_font_size("font_size")
			row["font_color"] = str(node.get_theme_color("font_color"))
		output.append(row)
	for child: Node in node.get_children():
		_collect_controls(child, output)

func _finish_capture_run() -> void:
	var terminal: Node = get_node("UI/RegistryTerminalView")
	get_node("MusicDirector").call("_on_registry_run_ended", "REGISTRY_SILENCE", {})
	terminal.call("_on_run_ended", "REGISTRY_SILENCE", {})
	await get_tree().create_timer(2.2).timeout
	await _capture("13_silence_it_1280x720")
	terminal.call("_on_run_ended", "REGISTRY_ABSENCE", {})
	await _capture("14_absence_it_1280x720")
	var file: FileAccess = FileAccess.open(audit_dir + ("/runtime_inventory_linear.json" if _linear else "/runtime_inventory.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"screens":_audit_rows, "phase_audio":_phase_audio, "failures":_failures}, "\t"))
	file.close()
	if _music_record != null:
		_music_record.set_recording_active(false)
		_music_record.get_recording().save_to_wav(ProjectSettings.globalize_path(audit_dir + "/runtime_music.wav"))
	terminal.get("_heartbeat").stop()
	get_node("MusicDirector").call("_on_registry_run_ended", "REGISTRY_ABSENCE", {})
	get_node("/root/SfxBus").call("_on_run_ended", "REGISTRY_ABSENCE", {})
	await get_tree().create_timer(0.2).timeout
	await super._finish_capture_run()

func _capture_arena_threshold_matrix() -> void:
	if not _linear: await super._capture_arena_threshold_matrix()

func _capture_accessibility_settings_matrix() -> void:
	if not _linear: await super._capture_accessibility_settings_matrix()

func _capture_registry_table_matrix() -> void:
	if not _linear: await super._capture_registry_table_matrix()

func _capture_promise_signature_matrix() -> void:
	if not _linear: await super._capture_promise_signature_matrix()

func _capture_pact_tablet_matrix() -> void:
	if not _linear: await super._capture_pact_tablet_matrix()

func _capture_gesture_choice_matrix() -> void:
	if not _linear: await super._capture_gesture_choice_matrix()

func _capture_judgment_seal_matrix() -> void:
	if not _linear: await super._capture_judgment_seal_matrix()

func _capture_final_dossier_matrix() -> void:
	if not _linear: await super._capture_final_dossier_matrix()

func _capture_receipt_matrix() -> void:
	if not _linear: await super._capture_receipt_matrix()

func _capture_condemnation_mark_matrix() -> void:
	if not _linear: await super._capture_condemnation_mark_matrix()

func _capture_second_incision_matrix() -> void:
	if not _linear: await super._capture_second_incision_matrix()

func _press_when_ready(path: String, timeout_seconds: float) -> void:
	await super._press_when_ready(path, timeout_seconds)
	if path.ends_with("/NewGameButton"):
		var prologue: Node = get_node("OpeningPrologue")
		if prologue.get("_active"):
			await get_tree().create_timer(0.7).timeout
			await _capture("17_prologue_threshold")
			await get_tree().create_timer(3.0).timeout
			await _capture("18_prologue_registry")
			while prologue.get("_active"):
				await get_tree().process_frame

func _capture_prologue_matrix() -> void:
	var menu: Node = get_node("MenuLayer/MainMenu")
	var prologue: Node = get_node("OpeningPrologue")
	# Layout fixtures, separate from real first-entry/skip integration checks.
	for locale: String in ["it", "en", "es"]:
		_select_settings_locale(menu, locale)
		for dimensions: Vector2i in [Vector2i(1280,720), Vector2i(1920,1080)]:
			DisplayServer.window_set_size(dimensions)
			get_tree().root.content_scale_size = dimensions
			get_tree().root.size = dimensions
			for reduced: bool in [false, true]:
				menu.call("_on_reduced_motion_toggled", reduced)
				prologue.set("_armed", true)
				prologue.call("_on_run_started")
				prologue.set_process(false)
				for beat: int in [0, 1]:
					prologue.set("_elapsed", 1.0 if beat == 0 else 4.0)
					prologue.get("_skip").disabled = false
					prologue.call("_update_presentation")
					await _capture("21_prologue_%s_%dx%d_%s_%d" % [locale, dimensions.x, dimensions.y, "reduced" if reduced else "standard", beat], dimensions)
					var caption: Label = prologue.get("_caption")
					if caption.get_line_count() > 2 or not get_tree().root.get_visible_rect().encloses(caption.get_global_rect()):
						_failures.append("Prologue caption does not fit: " + locale)
				prologue.call("_cancel")
	var file: FileAccess = FileAccess.open(audit_dir + "/runtime_inventory_prologue.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"screens":_audit_rows, "failures":_failures}, "\t"))
	file.close()
	get_node("MusicDirector").call("_on_registry_run_ended", "REGISTRY_ABSENCE", {})
	get_node("/root/SfxBus").call("_on_run_ended", "REGISTRY_ABSENCE", {})
	await get_tree().create_timer(0.2).timeout
	for failure: String in _failures:
		push_error(failure)
	print("PROLOGUE_QA_OK" if _failures.is_empty() else "PROLOGUE_QA_FAILED")
	get_tree().quit(0 if _failures.is_empty() else 1)
