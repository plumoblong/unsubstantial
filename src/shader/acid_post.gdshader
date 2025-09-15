shader_type canvas_item;

uniform vec2 motion = vec2(0.0);
uniform float scale : hint_range(-1000.0, 1000.0, 0.1) = 1.0;
uniform float gamma : hint_range(0.0, 2.0, 0.05) = 1.0;
uniform vec2 offset = vec2(0.0);
uniform bool inverted = false;

uniform sampler2D noise_offset : filter_nearest, repeat_enable;
uniform bool use_sample_texture = false;
uniform bool enable_filter = true;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float speed : hint_range(0.0, 256.0, 4.0) = 32;
//uniform float alpha : hint_range(1.0, 100.0, 0.5) = 2.0;
uniform float power : hint_range(0.0, 1.0, 0.025) = 1.0;

uniform float bit_depth : hint_range(1.0, 32.0, 0.25);
uniform float dither : hint_range(0.0, 0.5, 0.0025);


varying vec2 base_uv;

vec3 gamma_correct (vec3 val) {
	vec3 color;
    color.rgb = pow(val.rgb, vec3(1.0 / gamma));
    return color;
}

vec4 rgb_to_hsv(vec4 rgba) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(rgba.bg, K.wz), vec4(rgba.gb, K.xy), step(rgba.b, rgba.g));
	vec4 q = mix(vec4(p.xyw, rgba.r), vec4(rgba.r, p.yzx), step(p.x, rgba.r));

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec4(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x, 1.0);
}

vec3 hsv_to_rgb(vec4 hsva) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(hsva.xxx + K.xyz) * 6.0 - K.www);
	return hsva.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), hsva.y);
}

void vertex() {
	base_uv = (VERTEX + TIME * (motion * vec2(speed * 2.0))) * TEXTURE_PIXEL_SIZE * (1.0/scale);
}

void fragment(){
	
	vec2 uvs = SCREEN_UV * scale;
	vec4 init_tex = texture(screen_texture, uvs);
	vec3 final_color;

	// vec3 final_tex;
	if (enable_filter == true) {
		
		//vec2 pixel_size = 1.0 / vec2(320.0 / 2.0 , 180.0 / 2.0);
		
		vec4 noise = texture(noise_offset, base_uv);
		//noise.r = clamp(noise.r, 0.0, alpha);
		vec4 tex = rgb_to_hsv(init_tex);
		float time_offset = TIME * (speed / 64.0);
		vec3 final_hsv;

		if(use_sample_texture) {
			final_hsv = hsv_to_rgb(vec4(tex.x + (mod(init_tex.r, 1) + time_offset), tex.y, tex.z, 1.0));
		} else {
			final_hsv = hsv_to_rgb(vec4(tex.x + (mod(noise.r, 1) + time_offset), tex.y, tex.z, 1.0));
		};

		float a = floor(mod(SCREEN_UV.x / SCREEN_PIXEL_SIZE.x, 2.0));
		float b = floor(mod(SCREEN_UV.y / SCREEN_PIXEL_SIZE.y, 2.0));
		float c = mod(a + b, 2.0);
		final_color.r = (round(mix(init_tex.r, final_hsv.r, power) * bit_depth + dither) / bit_depth) * c;
		final_color.g = (round(mix(init_tex.g, final_hsv.g, power) * bit_depth + dither) / bit_depth) * c;
		final_color.b = (round(mix(init_tex.b, final_hsv.b, power) * bit_depth + dither) / bit_depth) * c;
		c = 1.0 - c;
		final_color.r += (round(mix(init_tex.r, final_hsv.r, power) * bit_depth - dither) / bit_depth) * c;
		final_color.g += (round(mix(init_tex.g, final_hsv.g, power) * bit_depth - dither) / bit_depth) * c;
		final_color.b += (round(mix(init_tex.b, final_hsv.b, power) * bit_depth - dither) / bit_depth) * c;
	} else {
		final_color.rgb = init_tex.rgb;
	};
	
	if (inverted == true) {
		COLOR.rgb = gamma_correct(mix(final_color.rgb, 1.0 - final_color.rrr, 1.0));
	} else {
		COLOR.rgb = gamma_correct(final_color.rgb);
	};
	
	COLOR.a = 1.0;

}