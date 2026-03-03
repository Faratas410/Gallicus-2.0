shader_type canvas_item;

uniform float noise_strength : hint_range(0.0, 0.35) = 0.07;
uniform float contrast : hint_range(0.5, 1.8) = 1.15;
uniform float brightness : hint_range(0.5, 1.5) = 0.92;
uniform float vignette : hint_range(0.0, 0.6) = 0.14;
uniform float noise_scale : hint_range(10.0, 500.0) = 120.0;
uniform float noise_speed : hint_range(0.0, 6.0) = 1.15;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123); }
float noise(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
    vec4 col = texture(TEXTURE, UV) * COLOR;
    float n = noise(UV * noise_scale + vec2(TIME * noise_speed, -TIME * noise_speed * 0.6)) - 0.5;
    col.rgb += n * noise_strength;
    col.rgb = (col.rgb - 0.5) * contrast + 0.5;
    col.rgb *= brightness;
    vec2 p = UV - vec2(0.5);
    float v = smoothstep(0.55, 0.0, length(p));
    col.rgb *= mix(1.0 - vignette, 1.0, v);
    COLOR = col;
}
