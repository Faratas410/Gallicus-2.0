shader_type canvas_item;
render_mode unshaded;
uniform float wear : hint_range(0.0, 1.0) = 0.0;
// Pixel-art treatment: 0 keeps the painted source. A value N snaps the image
// to a grid N art pixels tall (360 = 640x360 cells, 2x2 pixels of the
// 1280x720 viewport) and maps every cell to the closed palette strip.
uniform float pixel_rows = 0.0;
uniform sampler2D palette : filter_nearest, repeat_disable;
uniform int palette_size = 32;
varying vec4 tint;

void vertex() {
	// In fragment(), COLOR already includes the texture; keep the bare tint.
	tint = COLOR;
}

vec3 nearest_colour(vec3 colour) {
	vec3 best = colour;
	float best_distance = 1e9;
	for (int i = 0; i < palette_size; i++) {
		vec3 candidate = texture(palette, vec2((float(i) + 0.5) / float(palette_size), 0.5)).rgb;
		vec3 delta = (colour - candidate) * vec3(1.41, 2.0, 1.73);
		float distance = dot(delta, delta);
		if (distance < best_distance) {
			best_distance = distance;
			best = candidate;
		}
	}
	return best;
}

void fragment() {
	vec2 uv = UV;
	vec4 original;
	float pixel_cell = pixel_rows > 0.0 ? 1.0 / (SCREEN_PIXEL_SIZE.y * pixel_rows) : 0.0;
	if (pixel_cell > 0.0) {
		// Move to the centre of this fragment's cell, then average the cell.
		vec2 step_uv = vec2(dFdx(UV.x), dFdy(UV.y));
		vec2 offset = (floor(FRAGCOORD.xy / pixel_cell) + 0.5) * pixel_cell - FRAGCOORD.xy;
		uv = UV + offset * step_uv;
		vec2 quarter = step_uv * pixel_cell * 0.25;
		original = (texture(TEXTURE, uv + vec2(-quarter.x, -quarter.y)) + texture(TEXTURE, uv + vec2(quarter.x, -quarter.y))
			+ texture(TEXTURE, uv + vec2(-quarter.x, quarter.y)) + texture(TEXTURE, uv + vec2(quarter.x, quarter.y))) * 0.25;
	} else {
		original = texture(TEXTURE, uv);
	}
	float value = dot(original.rgb, vec3(0.299, 0.587, 0.114));
	vec3 ash = vec3(value * 1.02, value, value * 0.94);
	vec3 pigment = mix(original.rgb, ash, wear * 0.55);
	float shadow = 1.0 - smoothstep(0.05, 0.42, value);
	pigment = mix(pigment, pigment * vec3(0.80, 0.88, 0.78), shadow * wear * 0.35);
	pigment *= 1.0 - wear * 0.21;
	if (pixel_cell > 0.0) {
		// Objects and glyphs keep their tint; cells are either inked or empty.
		pigment = nearest_colour(pigment * tint.rgb);
		COLOR = vec4(pigment, step(0.5, original.a) * tint.a);
	} else {
		COLOR = vec4(pigment, original.a * COLOR.a);
	}
}
