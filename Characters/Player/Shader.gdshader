shader_type canvas_item;

uniform sampler2D from;
uniform sampler2D to;
uniform float t : hint_range(0.0, 1.0);
uniform vec2 center = vec2(0.5, 0.5);
uniform bool grow = true;

void fragment() {
	vec4 from_color = texture(from, UV);
    vec4 to_color = texture(to, UV);

    float dist = distance(UV, center);
    dist = grow ? dist : (1.0 - dist);
    float mask = smoothstep(t - 0.1, t + 0.1, dist);

    COLOR = mix(to_color, from_color, mask);
}