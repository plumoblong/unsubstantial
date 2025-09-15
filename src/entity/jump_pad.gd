@tool
extends Area3D
class_name JumpPad

@export var func_godot_properties : Dictionary = {
	"power" = -4664.0
}

@export var speed : float = 20.0

func _ready() -> void:
	if func_godot_properties["power"] != -4664.0:
		speed = func_godot_properties["power"]

func body_entered(body : CharacterBody3D) -> void:
	if body is Player:
		$AudioStreamPlayer3D.play()
		body.velocity.y = 0.0
		body.velocity += transform.basis.y * speed
	else:
		if body.has_node("MovementComponent"):
			body.movement_component.is_using_force = true
			body.movement_component.jump(speed)
			$AudioStreamPlayer3D.play()
			await get_tree().create_timer(0.1).timeout
			body.movement_component.is_using_force = false
		else:
			return
