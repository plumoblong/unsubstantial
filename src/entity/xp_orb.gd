extends Area3D
class_name XPOrb

@export var xp_amount : int = 1
var speed : float = 0.0

func _ready() -> void:
	_G.tween(self, "speed", 48, 0.5, 0, 2)

func _physics_process(delta : float) -> void:
	var direction : Vector3 = global_position.direction_to(_G.player.global_position)
	global_position += direction * speed * delta

func body_entered(body : Node3D) -> void:
	if body is not Player: return
	body.level_component.gain_xp(xp_amount)
	queue_free.call_deferred()
