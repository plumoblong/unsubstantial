extends Label
class_name ChatText

const LIFE_TIME : float = 8.0
const FADE_TIME : float = 1.0
const FADE_DELAY : float = LIFE_TIME - FADE_TIME

var color : Color = Color.WHITE
var alpha : float = 1.0

var shader_mat : ShaderMaterial

func _ready() -> void:
	shader_mat = material.duplicate(false)
	shader_mat.set_shader_parameter("modulate", color)
	material = shader_mat
	
	await get_tree().create_timer(FADE_DELAY, true, false, true).timeout
	_G.tween(self, "alpha", 0.0, FADE_TIME)

func _process(_delta : float) -> void:
	shader_mat.set_shader_parameter("alpha", alpha)
	
	if alpha <= 0.0:
		queue_free()
