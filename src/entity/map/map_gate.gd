extends StaticBody3D

@export var func_godot_properties : Dictionary = {
	"kills_required" : 3
}

var hitbox : CollisionShape3D
var mesh : MeshInstance3D
var checked : bool = false

const GATE_MAT : ShaderMaterial = preload("res://textures/world/gate.tres")

var material : ShaderMaterial

func _func_godot_build_complete() -> void:
	for i in get_children():
		if i is CollisionShape3D:
			hitbox = i
		if i is MeshInstance3D: 
			mesh = i
	material = GATE_MAT.duplicate()
	mesh.material_override = material
	
func _process(_delta: float) -> void:
	
	if hitbox.disabled : return
	if _G.game.enemies_killed >= func_godot_properties["kills_required"]:
		hitbox.disabled = true
		material.set_shader_parameter("distance_fade_min", 1.0)
		material.set_shader_parameter("albedo", Color("9c88b3"))
		_G.game.chat.add_message("A gate has opened.")
	if not checked:
		if (global_position * Vector3(1.0, 0.0, 1.0)).distance_to(_G.player.global_position  * Vector3(1.0, 0.0, 1.0)) < 7.0:
			_G.game.chat.add_message("You need to kill " + str(func_godot_properties["kills_required"] - _G.game.enemies_killed) + " enemies to unlock this gate.")
			checked = true
	else:
		if (global_position * Vector3(1.0, 0.0, 1.0)).distance_to(_G.player.global_position * Vector3(1.0, 0.0, 1.0)) > 14.0:
			checked = false
