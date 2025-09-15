@tool

extends OmniLight3D
class_name Light

@export var func_godot_properties : Dictionary = {
	"range" = 18.0, "energy" = 0.75, "mesh_visible" = 1
}

func _process(delta: float) -> void:
	omni_range = func_godot_properties["range"]
	light_energy = func_godot_properties["energy"]
	light_color = func_godot_properties["color"]
	$Light.visible = bool(func_godot_properties["mesh_visible"])
	#$Light.modulate = func_godot_properties.color
