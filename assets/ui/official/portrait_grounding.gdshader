shader_type canvas_item;

// Soften the cropped bust into its owning stone surface, without a backdrop.
void fragment() {
	COLOR.a *= 1.0 - smoothstep(0.90, 1.0, UV.y);
}
