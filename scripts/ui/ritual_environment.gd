extends RefCounted
## Environmental treatment driven only by RunManager's presentation query.
const AGING = preload("res://assets/ui/official/ritual_aging.gdshader")
const BACKGROUNDS: Array[String] = [
	"res://assets/ui/generated/arena_unified.png",
	"res://assets/ui/generated/crowd_unified.png",
	"res://assets/ui/generated/registry_counter_unified.png",
	"res://assets/ui/generated/portico_unified.png",
]
static func apply(background: TextureRect, fade: float) -> void:
	var material := background.material as ShaderMaterial
	if material == null or material.shader != AGING:
		material = ShaderMaterial.new()
		material.shader = AGING
		background.material = material
	background.self_modulate = Color.WHITE
	material.set_shader_parameter("wear", clampf(fade / 0.21, 0.0, 1.0))
static func apply_scene(scene: Node, fade: float) -> void:
	for item: Node in scene.find_children("*", "TextureRect", true, false):
		var background := item as TextureRect
		if background.texture != null and background.texture.resource_path in BACKGROUNDS:
			apply(background, fade)
