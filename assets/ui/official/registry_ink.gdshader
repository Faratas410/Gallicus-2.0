shader_type canvas_item;
render_mode unshaded;

// Stationary ink density. No vertex displacement, time, blur or legibility loss.
void fragment() {
	vec2 cell = floor(FRAGCOORD.xy);
	float grain = fract(sin(dot(cell, vec2(12.9898, 78.233))) * 43758.5453);
	COLOR.rgb *= 0.94 + 0.06 * grain;
	COLOR.a *= 0.96 + 0.04 * grain;
}
