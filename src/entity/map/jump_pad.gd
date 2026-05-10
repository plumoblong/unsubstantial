#@tool
extends Area3D
class_name JumpPad

@export var func_godot_properties : Dictionary[String, Variant] = {
	"power" = -4664.0
}

@export var speed : float = 20.0

func _func_godot_build_complete() -> void:
	if func_godot_properties["power"] != -4664.0:
		speed = func_godot_properties["power"]
		
func body_entered(body : Node3D) -> void:
	if body is not CharacterBody3D: return
	if body.has_node("DashComponent"):
		if not body.get_node("DashComponent").can_dash or not body.get_node("DashComponent").can_reset:
			body.get_node("DashComponent").allow_dash(false)
	if body is Player:
		$AudioStreamPlayer3D.play()
		body.velocity.y = 0.0
		body.velocity += transform.basis.y * speed
		body.movement_component.can_jump = false
	else:
		if body.has_node("MovementComponent"):
			body.movement_component.is_using_force = true
			body.movement_component.jump(speed)
			$AudioStreamPlayer3D.play()
			await get_tree().create_timer(0.1).timeout
			if body == null: return
			body.movement_component.is_using_force = false
		else:
			return
