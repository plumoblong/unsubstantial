extends Label3D
class_name TextSign

@export var func_godot_properties : Dictionary[String, Variant] = {
	"text": "Lorem Ipsum", "scale" : 1.0
}

const PIXEL_SIZE : float = 0.025

func _func_godot_build_complete() -> void:
	text = _G.input_text_to_event(func_godot_properties["text"]).replace("\\n", "\n")
	pixel_size = PIXEL_SIZE * func_godot_properties["scale"]
