extends Label
class_name ChatText

const LIFE_TIME : float = 8.0

var color : Color = Color.WHITE
var alpha : float = 1.0

var new_material : ShaderMaterial = material.duplicate(false)

func _ready() -> void:
	new_material.set_shader_parameter("modulate", color)
	material = new_material
	await get_tree().create_timer(LIFE_TIME - 1.0, true, false, true).timeout
	_G.tween(self, "alpha", 0.0, 1.0)

func _process(_delta : float) -> void:
	material.set_shader_parameter("alpha", alpha)
