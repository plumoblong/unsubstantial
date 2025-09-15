shader_type canvas_item;
render_mode blend_add;

const int VU_COUNT = 30;
const float segment_count = 40.0;

uniform float[VU_COUNT] freq_data;

void fragment() {
	vec2 uv = UV;
	uv.y = 1.0 - uv.y;
	float vu_count = float(VU_COUNT);
	vec2 pos = vec2(floor(uv.x * vu_count) / vu_count, floor(uv.y * segment_count) / segment_count);
	float fft = freq_data[int(uv.x * vu_count)];
	vec3 color = mix(vec3(0.5, 0.5, 0.5), vec3(1.0, 1.0, 1.0), sqrt(uv.y));
	float mask = pos.y < fft ? 1.0 : 0.0;
	vec2 dist = fract((uv - pos) * vec2(vu_count, segment_count)) - 0.5;
	float led = smoothstep(0.5, 0.35, abs(dist.x)) * smoothstep(0.5, 0.35, abs(dist.y));
	COLOR = vec4(color * mask, 1.0);
}
