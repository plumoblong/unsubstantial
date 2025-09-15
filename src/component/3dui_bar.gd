extends Sprite3D
class_name UIBar

@export var color_gradient : Gradient
@export var smoothing : float = 0.1
@export var hide_if_full : bool = true

@export var from_value : float = 1.0
@export var scale_with_fov : bool = true

var to_value : float = 1.0

var saved_modulate : Color

func _ready() -> void:
	saved_modulate = modulate

func _process(_delta: float) -> void:
	to_value = lerpf(from_value, to_value, smoothing)
	if scale_with_fov:
		pixel_size = (_G.player.camera.fov / 130.0) * 0.0075
	if color_gradient != null:
		modulate = color_gradient.sample(to_value) * saved_modulate
	else:
		modulate = saved_modulate
	if hide_if_full:
		visible = frame != 0
	frame = int((1.0 - to_value) * 32.0)
