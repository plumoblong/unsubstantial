shader_type canvas_item;

uniform lowp sampler2D screen_texture : hint_screen_texture, filter_nearest;

uniform float alpha = 0.7;

void fragment() {
	vec4 screen  = texture(screen_texture, SCREEN_UV);
	if (COLOR.rgb == screen.rgb) {
		COLOR.a = 0.0;
	} else {
		COLOR.r = 1.0;
	};
}
