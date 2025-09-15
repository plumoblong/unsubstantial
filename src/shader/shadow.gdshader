shader_type canvas_item;

uniform vec2 direction = vec2(-1, -1);
uniform vec4 modulate : source_color;
uniform vec4 self_modulate : source_color = vec4(1, 1, 1, 1);

void fragment() {
	vec2 ps = TEXTURE_PIXEL_SIZE;

	vec4 shadow = texture(TEXTURE, UV + vec2(direction.x, direction.y) * ps);
	shadow *= modulate;

	vec4 col = texture(TEXTURE, UV);
	COLOR = mix(shadow, col * self_modulate, col.a * self_modulate.a);
}