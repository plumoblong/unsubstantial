extends OmniLight3D
class_name Light

@export var func_godot_properties : Dictionary = {
	"range" = 18.0, "energy" = 0.75, "mesh_visible" = 1
}

func _func_godot_build_complete() -> void:
	omni_range = func_godot_properties["range"]
	light_energy = func_godot_properties["energy"]
	light_color = _G.game.get_chapter_color(randf_range(0.0, 0.25))
	$Light.modulate = light_color
	$Light.visible = bool(func_godot_properties["mesh_visible"])
	#$Light.modulate = func_godot_properties.color
