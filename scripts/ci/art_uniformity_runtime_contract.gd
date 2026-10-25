extends SceneTree
## Regression cases discovered in the art audit. Use a disposable user profile.
const EnvironmentPresentation = preload("res://scripts/ui/ritual_environment.gd")
var failures: Array[String] = []
var checks := 0

func _initialize() -> void:
	call_deferred("_run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures.append(message)
		push_error(message)

func settle(seconds: float = 0.15) -> void:
	await create_timer(seconds).timeout
	await process_frame
	await process_frame

func _run() -> void:
	var scene: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await settle(0.4)
	var ui: Node = scene.get_node("UI")
	var menu: Node = scene.get_node("MenuLayer/MainMenu")
	var manager: Node = scene.get_node("RunManager")
	var save: Node = root.get_node("SaveManager")
	menu.get("new_game_button").pressed.emit()
	await settle(0.6)
	scene.get_node("OpeningPrologue").call("_finish")
	var circle: Node = ui.get_node("UI_RunRoot/BettingCircle")
	var bet: StringName = circle.get("selected_bet_id")
	circle.close()
	ui.call("_on_resolve_ritual_opened", {})
	check(ui.get("resolve_ritual_panel").scale == Vector2.ONE, "interactive entry scaled its target")
	await settle(0.6)
	menu.call("_on_reduced_motion_toggled", false)
	var strike: Control = ui.get("resolve_ritual_strike_button")
	var origin := strike.get_global_transform_with_canvas().origin
	ui.call("_play_seal_impact", false, false)
	for i in range(12):
		await settle(0.025)
		check(strike.get_global_transform_with_canvas().origin.is_equal_approx(origin), "impact moved canvas target")
		check(ui.offset == Vector2.ZERO, "impact moved the UI layer")
	var impact: Node = ui.get("_impact")
	for i in range(3):
		await settle(0.55)
		impact.call("burst", origin, Color.WHITE, 12, 90.0)
	check(impact.get("_particles").size() <= 2, "expired effect references accumulated")
	impact.call("slide", ui.get("crowd_favor_bar"), "value", 4.0, 0.5)
	ui.call("_play_seal_impact", false, false)
	await settle(0.04)
	menu.call("_on_reduced_motion_toggled", true)
	await process_frame
	check(is_equal_approx(ui.get("crowd_favor_bar").value, 4.0), "reduced motion did not settle gauge")
	check(ui.offset == Vector2.ZERO, "reduced motion left offset")
	for item: Node in ui.get_children():
		check(not item is CPUParticles2D or not item.is_visible_in_tree(), "particles survived reduced-motion switch")
	await settle(0.12)
	ui.call("_play_seal_impact", false, false)
	await settle(0.1)
	for item: Node in ui.get_children():
		check(not item is CPUParticles2D, "reduced impact emitted particles")
	check(is_zero_approx(impact.get("_flash").color.a), "reduced flash exceeded 80 ms")
	ui.call("_on_resolve_ritual_closed")
	var payload: Dictionary = manager.call("_build_push_luck_payload", bet)
	payload["stake_glory"] = 123456
	menu.call("_on_reduced_motion_toggled", false)
	ui.call("_on_push_luck_opened", payload)
	await settle(0.04)
	menu.call("_on_reduced_motion_toggled", true)
	check(ui.get("push_luck_details").text == "123456", "reduced motion did not settle count synchronously")
	var atmosphere: Node = ui.get("push_luck_panel").get("atmosphere")
	var clock: float = atmosphere.get("clock")
	await settle(0.15)
	check(atmosphere.get("clock") == clock, "atmosphere advanced with reduced motion")
	var header: Control = ui.get_node("HUD/RitualStatusHeader")
	check(header.is_visible_in_tree(), "common header missing in risk phase")
	var header_origin := header.get_global_rect()
	ui.call("_on_push_luck_closed")
	ui.call("_on_intermediate_choice_opened")
	await settle(0.2)
	check(header.get_global_rect() == header_origin and header.is_visible_in_tree(), "header moved or disappeared between phases")
	for locale: String in ["it", "en", "es"]:
		TranslationServer.set_locale(locale)
		await settle(0.05)
		for key: String in ["context", "pressure", "chain", "account", "bando", "crowd", "scars"]:
			var label: Control = header.get(key)
			check(root.get_visible_rect().encloses(label.get_global_rect()), "header text outside viewport " + locale + "/" + key)
	# Exercise the real presentation query during each three-run ramp.
	for era in [0, 1, 2, 3]:
		manager.set("_registry_era", era)
		for ramp in [0, 1, 2]:
			save.commit_registry_evolution(0.0, era, {"ramp_runs":ramp})
			ui.call("_apply_campaign_environment")
			var expected: float = clampf(float(manager.get_registry_presentation().material_fade) / 0.21, 0, 1)
			for item: Node in scene.find_children("*", "TextureRect", true, false):
				var texture: TextureRect = item
				if texture.texture != null and texture.texture.resource_path in EnvironmentPresentation.BACKGROUNDS:
					var material := texture.material as ShaderMaterial
					check(material != null and is_equal_approx(float(material.get_shader_parameter("wear")), expected), "environment missed ramp: " + str(texture.get_path()))
	check(strike.material == null, "environment shader leaked onto command")
	ui.call("_apply_visual_tier", ui._VISUAL_TIER_ERA3)
	check(ui.get("hud_root").material == null and ui.get("hud_root").modulate == Color.WHITE, "late tier distorted the HUD")
	check(ui.get("modals_root").material == null and ui.get("modals_root").modulate == Color.WHITE, "late tier distorted reading surfaces")
	var portrait := Image.load_from_file(ProjectSettings.globalize_path("res://assets/ui/generated/dialogue_lauro_cutout.png"))
	check(portrait != null and portrait.get_pixel(0, 0).a == 0, "Lauro lacks transparent background")
	check(portrait.get_height() > portrait.get_width(), "Lauro portrait aspect changed")
	scene.get_node("MusicDirector").call("_on_registry_run_ended", "REGISTRY_ABSENCE", {})
	root.get_node("SfxBus").call("_on_run_ended", "REGISTRY_ABSENCE", {})
	await settle(1.5)
	scene.queue_free()
	await settle(0.3)
	print("ART_UNIFORMITY_CONTRACT ", checks, " checks; ", failures.size(), " failures")
	quit(0 if failures.is_empty() else 1)
