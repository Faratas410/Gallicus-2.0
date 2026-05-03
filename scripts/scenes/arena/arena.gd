extends Node2D

# Level 3 canonical runtime keeps Arena as passive visual container.
const ARENA_BG_VARIANT_PATHS: Array[String] = [
	"res://assets/backgrounds/sfondo_arena_principale.png",
	"res://assets/backgrounds/arena/variants/arena_bg_variant_01.png",
	"res://assets/backgrounds/arena/variants/arena_bg_variant_02.png",
]

var _arena_bg_variants: Array[Texture2D] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _background_sprite: Sprite2D = null
var _visual_only: bool = true
var _difficulty_tier: int = 0
var _difficulty_multiplier: float = 1.0

func _ready() -> void:
	add_to_group("arena")
	_rng.randomize()
	_ensure_background_variants_loaded()
	_apply_background_variant()
	set_visual_only(true)
	var run_started_callable: Callable = Callable(self, "_on_run_started")
	if not GameEvents.run_started.is_connected(run_started_callable):
		GameEvents.run_started.connect(run_started_callable)
	var run_failed_callable: Callable = Callable(self, "_on_run_failed")
	if not GameEvents.run_failed.is_connected(run_failed_callable):
		GameEvents.run_failed.connect(run_failed_callable)

func _ensure_background_variants_loaded() -> void:
	if not _arena_bg_variants.is_empty():
		return
	for path: String in ARENA_BG_VARIANT_PATHS:
		var texture: Texture2D = load(path) as Texture2D
		if texture != null:
			_arena_bg_variants.append(texture)

func _apply_background_variant() -> void:
	if _background_sprite == null:
		_background_sprite = get_node_or_null("Background") as Sprite2D
	if _background_sprite == null or _arena_bg_variants.is_empty():
		return
	var index: int = _rng.randi_range(0, _arena_bg_variants.size() - 1)
	_background_sprite.texture = _arena_bg_variants[index]

func set_visual_only(visual_only: bool) -> void:
	_visual_only = visual_only
	set_process(not visual_only)
	set_physics_process(not visual_only)

func set_difficulty_tier(tier: int, mult: float = 1.0) -> void:
	_difficulty_tier = tier
	_difficulty_multiplier = mult

func soft_reset() -> void:
	_apply_background_variant()

func _on_run_started() -> void:
	soft_reset()

func _on_run_failed() -> void:
	set_visual_only(true)
