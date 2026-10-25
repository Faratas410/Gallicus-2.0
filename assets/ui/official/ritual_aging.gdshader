shader_type canvas_item;
render_mode unshaded;
uniform float wear : hint_range(0.0, 1.0) = 0.0;
void fragment() {
	vec4 original = texture(TEXTURE, UV);
	float value = dot(original.rgb, vec3(0.299, 0.587, 0.114));
	vec3 ash = vec3(value * 1.02, value, value * 0.94);
	vec3 pigment = mix(original.rgb, ash, wear * 0.55);
	float shadow = 1.0 - smoothstep(0.05, 0.42, value);
	pigment = mix(pigment, pigment * vec3(0.80, 0.88, 0.78), shadow * wear * 0.35);
	COLOR = vec4(pigment * (1.0 - wear * 0.21), original.a * COLOR.a);
}
