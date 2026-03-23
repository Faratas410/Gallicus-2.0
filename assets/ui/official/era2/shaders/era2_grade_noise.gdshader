shader_type canvas_item;

uniform float noise_strength : hint_range(0.0, 0.25) = 0.04;
uniform float contrast : hint_range(0.5, 1.5) = 1.10;
uniform float brightness : hint_range(0.5, 1.5) = 0.95;
uniform float vignette : hint_range(0.0, 0.5) = 0.08;
uniform float noise_scale : hint_range(10.0, 400.0) = 140.0;
uniform float noise_speed : hint_range(0.0, 4.0) = 0.65;

float hash(vec2 p) {
    // cheap stable hash
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

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

    // micro-noise (subtle)
    vec2 n_uv = UV * noise_scale + vec2(TIME * noise_speed, TIME * noise_speed * 0.7);
    float n = noise(n_uv) - 0.5;
    col.rgb += n * noise_strength;

    // contrast/brightness
    col.rgb = (col.rgb - 0.5) * contrast + 0.5;
    col.rgb *= brightness;

    // vignette
    vec2 p = UV - vec2(0.5);
    float v = smoothstep(0.5, 0.0, length(p));
    col.rgb *= mix(1.0 - vignette, 1.0, v);

    COLOR = col;
}
