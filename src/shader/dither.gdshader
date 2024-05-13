shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float colors : hint_range(1.0, 32.0);
uniform float dither : hint_range(0.0, 0.5);

void fragment()
{
	vec4 color = texture(screen_texture, SCREEN_UV);
	
	float a = floor(mod(SCREEN_UV.x / SCREEN_PIXEL_SIZE.x, 2.0));
	float b = floor(mod(SCREEN_UV.y / SCREEN_PIXEL_SIZE.y, 2.0));	
	float c = mod(a + b, 2.0);
	
	COLOR.r = (round(color.r * colors + dither) / colors) * c;
	COLOR.g = (round(color.g * colors + dither) / colors) * c;
	COLOR.b = (round(color.b * colors + dither) / colors) * c;
	c = 1.0 - c;
	COLOR.r += (round(color.r * colors - dither) / colors) * c;
	COLOR.g += (round(color.g * colors - dither) / colors) * c;
	COLOR.b += (round(color.b * colors - dither) / colors) * c;
}