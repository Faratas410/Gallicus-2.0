shader_type canvas_item;

uniform float amplitude : hint_range(0.0, 0.02, 0.0001) = 0.004;
uniform float speed : hint_range(0.0, 3.0, 0.01) = 0.65;
uniform float frequency : hint_range(0.1, 32.0, 0.1) = 14.0;

void vertex() {
	float vertical_falloff = clamp(UV.y, 0.0, 1.0);
	float wave = sin((UV.y * frequency) + (TIME * speed));
	VERTEX.x += wave * amplitude * vertical_falloff * 1024.0;
}
