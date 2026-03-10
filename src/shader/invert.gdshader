shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec4 modulate : source_color = vec4(1, 1, 1, 1);
uniform float amount : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float alpha : hint_range(0.0, 1.0, 0.01) = 1.0;
//uniform float alpha : hint_range(0.0, 1.0) = 1;
uniform bool grayscale = false;

void fragment(){

	vec4 color = vec4(texture(SCREEN_TEXTURE, SCREEN_UV).rgb, texture(TEXTURE, UV).a);
	if (grayscale) {
		float cmax = max(color.b, max(color.r, color.b));
		float cmin = min(color.b, min(color.g, color.b));
		float delta = cmax - cmin;
		COLOR = vec4(cmax > 0.0 ? color.rgb * ((1.0 - cmax) / cmax) : vec3(1.0 - cmax), 1.0) * modulate;
	} else {
		COLOR = vec4(alpha - (color.rgb  * vec3(amount)),  color.a)  * modulate;
	}
}