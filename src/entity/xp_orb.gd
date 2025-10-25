extends Area3D
class_name XPOrb

@export var xp_amount : int = 1
var speed : float

var random_mult : float

func _ready() -> void:
	speed = randf_range(3.0, 4.5)
	random_mult = randf_range(1.1, 1.2)

func _physics_process(delta : float) -> void:
	var direction : Vector3 = global_position.direction_to(_G.player.global_position + Vector3(0.0, 1.0, 0.0))
	speed *= random_mult
	speed = clamp(speed, 0.0, 64.0)
	if _G.player.can_control:
		global_position += direction * speed * delta

func body_entered(body : Node3D) -> void:
	if body is not Player: return
	body.level_component.gain_xp(xp_amount)
	queue_free.call_deferred()
