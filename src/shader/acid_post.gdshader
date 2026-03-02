shader_type canvas_item;

uniform vec2 motion = vec2(0.0);
uniform float gamma : hint_range(0.0, 2.0, 0.05) = 1.0;
// uniform bool use_sample_texture = false;
uniform bool enable_filter = true;
uniform sampler2D screen_texture : hint_screen_texture, repeat_enable, filter_nearest;
uniform float speed : hint_range(0.0, 256.0, 4.0) = 32;
//uniform float alpha : hint_range(1.0, 100.0, 0.5) = 2.0;
//uniform float dither_mod : hint_range(0, 1.0, 0.05) = 0.25;
uniform float dither_size : hint_range(-8.00, 7.99, 0.01) = 1.0;
uniform float power : hint_range(0.0, 1.0, 0.01) = 1.0;

uniform float bit_depth : hint_range(1.0, 32.0, 0.25);

// FUN

//float fun_get_pixel_brightness(vec3 col) {
	//return (col.r + col.g + col.b) / 3.0;
//}

vec3 gamma_correct (vec3 val) {
	vec3 color;
    color.rgb = pow(val.rgb, vec3(1.0 / gamma));
    return color;
}

vec3 rgb_to_hsv(vec3 rgb) {
    float cmax = max(max(rgb.r, rgb.g), rgb.b);
    float cmin = min(min(rgb.r, rgb.g), rgb.b);
    float delta = cmax - cmin;

    // Hue calculation
    float h = 0.0;
    if (delta > 0.0) {
        if (cmax == rgb.r) {
            h = mod((rgb.g - rgb.b) / delta, 6.0);
        } else if (cmax == rgb.g) {
            h = (rgb.b - rgb.r) / delta + 2.0;
        } else {
            h = (rgb.r - rgb.g) / delta + 4.0;
        }
        h /= 6.0;
    }

    // Saturation
    float s = (cmax > 0.0) ? delta / cmax : 0.0;

    // Value
    float v = cmax;

    return vec3(h, s, v);
}

vec3 hsv_to_rgb(vec3 hsv) {
    float h = hsv.x * 6.0;
    float s = hsv.y;
    float v = hsv.z;

    float c = v * s;
    float x = c * (1.0 - abs(mod(h, 2.0) - 1.0));
    float m = v - c;

    vec3 rgb;
    if (h < 1.0) {
        rgb = vec3(c, x, 0.0);
    } else if (h < 2.0) {
        rgb = vec3(x, c, 0.0);
    } else if (h < 3.0) {
        rgb = vec3(0.0, c, x);
    } else if (h < 4.0) {
        rgb = vec3(0.0, x, c);
    } else if (h < 5.0) {
        rgb = vec3(x, 0.0, c);
    } else {
        rgb = vec3(c, 0.0, x);
    }

    return rgb + m;
}

float dither_pattern(vec2 pos) {
	int x = int(mod(pos.x, 2.0));
	int y = int(mod(pos.y, 2.0));

	const int bayer2[4] = int[4](
		0, 2,
		3, 1
	);

	int index = x + y * 2;
	return float(bayer2[index]) / 3.0;
}

void fragment(){
	vec4 init_tex = texture(screen_texture, SCREEN_UV);
	vec3 final_color;

	if (enable_filter) {
		vec2 screen_pos = SCREEN_UV / SCREEN_PIXEL_SIZE;
		float dither = dither_pattern(screen_pos);
		// Posterize in one operation per channel
		vec3 scaled = init_tex.rgb * bit_depth;
		vec3 posterized = clamp(floor(scaled + (dither) * (dither_size / bit_depth)), 0.0, bit_depth) / bit_depth;
		float time_offset = TIME * speed * 0.015625; // 1/64 precomputed
		vec3 tex = rgb_to_hsv(posterized);
		tex.x += mod(posterized.b, 1.0) + time_offset;
		final_color = mix(posterized, hsv_to_rgb(tex), power);
	} else {
		final_color = init_tex.rgb;
	}

	COLOR.rgb = gamma_correct(final_color);
	COLOR.a = init_tex.a;
}

