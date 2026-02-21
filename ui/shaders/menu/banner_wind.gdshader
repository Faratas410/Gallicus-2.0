shader_type canvas_item;

uniform float amplitude = 0.012;
uniform float speed = 1.8;
uniform float frequency = 8.0;

void fragment() {
	vec2 uv = UV;
	float wave = sin((uv.y * frequency) + (TIME * speed)) * amplitude;
	uv.x += wave;
	COLOR = texture(TEXTURE, uv);
}
