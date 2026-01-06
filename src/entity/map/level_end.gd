extends Area3D
class_name LevelEnd

var opened : bool = false

@export var func_godot_properties : Dictionary = {
	"enabled" = 1
}

func opener_body_entered(body : Node3D) -> void:
	if body is not Player: return
	if opened or not func_godot_properties["enabled"]: return
	opened = true
	$Animation.play("open")

func body_entered(body : Node3D) -> void:
	if body is Player and func_godot_properties["enabled"]:
		_G.game.end_level()
	
