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
		material.set_shader_parameter("albedo", Color("291e36ff"))
