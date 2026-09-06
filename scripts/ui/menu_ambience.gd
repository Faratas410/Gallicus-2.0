extends Control

# A single original chamber; motion never moves interactive controls.
@onready var _base: TextureRect = $Base
var _time: float = 0.0
var _reduced_motion: bool = false

func _ready() -> void:
	_reduced_motion = SaveManager.get_reduced_motion()
	GameEvents.settings_changed.connect(_on_settings_changed)
	_apply_motion_mode()

func _process(delta: float) -> void:
	if _reduced_motion or not is_visible_in_tree():
		return
	_time += delta
	_base.position = Vector2(sin(_time * 0.18) * -1.2, 0.0)
	_base.scale = Vector2(1.004, 1.004)

func _on_settings_changed(payload: Dictionary) -> void:
	if payload.has("reduced_motion"):
		_reduced_motion = bool(payload.reduced_motion)
		_apply_motion_mode()

func _apply_motion_mode() -> void:
	set_process(not _reduced_motion)
	_base.position = Vector2.ZERO
	_base.scale = Vector2.ONE if _reduced_motion else Vector2(1.004, 1.004)
