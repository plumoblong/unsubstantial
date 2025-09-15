shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec4 modulate : source_color = vec4(1, 1, 1, 1);
uniform float amount : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float alpha : hint_range(0.0, 1.0, 0.01) = 1.0;
//uniform float alpha : hint_range(0.0, 1.0) = 1;

void fragment(){

	vec4 color = vec4(texture(SCREEN_TEXTURE, SCREEN_UV).rgb, texture(TEXTURE, UV).a) ;

	COLOR = vec4(1.0 - (color.rgb  * vec3(amount)),  color.a * alpha) * texture(TEXTURE, UV).rgba * modulate;
}