shader_type canvas_item;

//uniform sampler2D offset_image : hint_white;

uniform float strength = 1.0;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec4 output = texture(screen_texture, SCREEN_UV);
	//float shift = strength * texture(offset_image, SCREEN_UV).r / 100.0;
	output.r = texture(screen_texture, vec2(SCREEN_UV.x + (strength / 1000.0), SCREEN_UV.y)).r;
	output.g = texture(screen_texture, SCREEN_UV).g;
	output.b = texture(screen_texture, vec2(SCREEN_UV.x - (strength / 1000.0), SCREEN_UV.y)).b;

	COLOR = output;
}