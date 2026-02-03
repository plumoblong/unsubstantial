extends Sprite2D
class_name SineMovement2D

@export var amplitude : float = 10.0
@export var frequency : float = 1.0
@export var anim_offset : float = 0.0

@onready var start_position : Vector2 = global_position

func _physics_process(delta: float) -> void:
	offset.y = _G.sine_movement(frequency, amplitude, anim_offset, delta)
