extends Label
class_name UiPopUp

@export var color : Color = Color.GREEN
@export var invert_amount : float = 0.6
@export var velocity : Vector2 = Vector2.UP
@export var length : float = 1.0

var alpha : float = 0.0
var progress : float = 0.0

func _ready() -> void:
	var new_mat : Material = material.duplicate()
	material = new_mat
	material.set_shader_parameter("modulate", color)
	material.set_shader_parameter("amount", invert_amount)
	

func _process(delta: float) -> void:
	progress += delta
	global_position += (velocity * (length - progress) * 0.2)
	alpha = clampf(1.0 - ((progress / length)), -0.01, 1.0)
	material.set_shader_parameter("alpha", alpha)
	if alpha <= 0.0:
		queue_free.call_deferred()
