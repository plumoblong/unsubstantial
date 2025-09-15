@tool

extends Area3D

var entered : bool = false

@export var func_godot_properties : Dictionary = {
	"animation" = 1, "loop" = 0, "finish" = 0
}

func _process(delta : float) -> void:
	if not func_godot_properties["animation"]: return
	$MeshInstance3D3.rotation_degrees.y += delta
	$MeshInstance3D3.rotation_degrees.x += delta * 0.5
	$MeshInstance3D3.rotation_degrees.z += delta * 0.5
	$MeshInstance3D.material_override.uv1_offset.y += delta * 0.25
	$MeshInstance3D2.material_override.uv1_offset.y += delta * 0.125


func area_entered(area: Area3D) -> void:
	if area.get_parent() is Player:
		_G.game.end_level()
