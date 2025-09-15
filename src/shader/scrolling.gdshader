shader_type canvas_item;
render_mode blend_add;

// --- Uniforms --- //
uniform vec2 speed = vec2(1.0, 0.0);
uniform vec4 modulate : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// --- Functions --- //
void fragment() {
	COLOR = texture(TEXTURE, mod(UV + TIME * speed, 1.0)) * modulate.rgba;
}