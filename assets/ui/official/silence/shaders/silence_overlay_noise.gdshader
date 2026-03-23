shader_type canvas_item;

uniform float alpha : hint_range(0.0, 1.0) = 0.55;
uniform float noise_strength : hint_range(0.0, 0.6) = 0.18;
uniform float vignette : hint_range(0.0, 0.8) = 0.35;
uniform float noise_scale : hint_range(10.0, 600.0) = 180.0;
uniform float noise_speed : hint_range(0.0, 10.0) = 2.0;

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
    // Overlay is a ColorRect: base is COLOR; we add noise + vignette and set alpha.
    vec4 col = COLOR;
    float n = noise(UV * noise_scale + vec2(TIME * noise_speed, TIME * noise_speed * 0.4)) - 0.5;
    col.rgb += n * noise_strength;
    vec2 p = UV - vec2(0.5);
    float v = smoothstep(0.6, 0.0, length(p));
    col.rgb *= mix(1.0 - vignette, 1.0, v);
    col.a *= alpha;
    COLOR = col;
}
