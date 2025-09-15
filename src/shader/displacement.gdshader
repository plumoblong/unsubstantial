shader_type spatial;
render_mode unshaded;

uniform float height_scale = 0.5;
uniform sampler2D displacement : filter_linear_mipmap;
uniform sampler2D albedo_texture : filter_nearest_mipmap;
uniform sampler2D normal_texture : filter_nearest;
varying vec2 tex_position;

uniform float scroll_speed = 2.0;
uniform float texture_scale = 50;
uniform float noise_texture_scale = 50;

uniform sampler2D emission_texture : filter_nearest_mipmap;
uniform vec3 albedo : source_color = vec3(0,0,0);

void vertex() {
	tex_position = VERTEX.xz;
	float height = texture(displacement, tex_position + (scroll_speed * vec2(0.5, 0.5) * (TIME) * 0.003)).x;
	float height2 = texture(displacement, tex_position + (scroll_speed * vec2(0.5, 0.5) * (TIME) * 0.003)).z;
	VERTEX.y += height + height2 * height_scale;
}

void fragment() {
	ROUGHNESS = 0.0;
	vec2 base_uv = UV / (1.0 / texture_scale) + (scroll_speed * vec2(-1.0, 1.0) * TIME * 0.1);
	vec2 base_uv2 = UV / (1.0 / texture_scale) + (scroll_speed * vec2(1.0, -1.0) * TIME * 0.1);
	ALBEDO = texture(albedo_texture, base_uv).rgb *albedo.rgb;
}