shader_type spatial;
render_mode blend_mix,depth_draw_opaque,ambient_light_disabled,ensure_correct_normals,unshaded;
uniform vec2 scroll_speed = vec2(3.0, 3.0);
//uniform float static_intensity : hint_range(0.0, 1.0, 0.05) = 0.25;
uniform vec3 color : source_color = vec3(1.0);
uniform float tex_scale: hint_range(0.25, 10.0, 0.01) = 1.0;
uniform sampler2D albedo_tex : hint_default_white, filter_nearest;
uniform bool use_depth = false;

uniform float emission_energy : hint_range(0.0, 1, 0.01) = 0.0;
uniform vec4 emission_color : source_color;



//float rand(vec2 co){
	//return fract(sin(dot(co ,vec2(12.9898,78.233))) * 43758.5453);
//}

void fragment() {
	vec2 base_uv = vec2(SCREEN_UV.x - 0.5, SCREEN_UV.y - 0.5) * (1.0 / (tex_scale));
	base_uv.x *= VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;
	vec4 tex;
	float depth = length(NODE_POSITION_WORLD - CAMERA_POSITION_WORLD) + 0.5;
	if (use_depth) {
		tex = texture(albedo_tex, (base_uv * depth) + (scroll_speed * vec2(-1.0, 1.0) * TIME * 0.1));
	} else {
		tex = texture(albedo_tex, base_uv + (scroll_speed * vec2(-1.0, 1.0) * TIME * 0.1));
	}
	//tex.rgb = mix(vec3(0.0), tex.rbg, tex.a);

	//float noise = pow(rand(UV * TIME * 0.1), 3) * static_intensity;
	//vec3 cnoise = mix(color, vec3(1.0) - color, noise);

	//vec3 final = mix(cnoise * tex.rgb, cnoise, noise * 0.5);

	ALBEDO = tex.rgb * color.rgb;
	EMISSION = emission_color.rgb * vec3(emission_energy, emission_energy, emission_energy);
}