shader_type canvas_item;
render_mode unshaded;

// Static, uneven pigment. Native glyphs retain accents and localization.
void fragment() {
	vec2 cell = floor(FRAGCOORD.xy / 1.5);
	float grain = fract(sin(dot(cell, vec2(12.9898, 78.233))) * 43758.5453);
	COLOR.rgb *= 0.79 + 0.21 * grain;
	COLOR.a *= grain < 0.045 ? 0.65 : 0.87 + 0.13 * grain;
}
