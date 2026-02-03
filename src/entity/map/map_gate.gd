extends StaticBody3D

@export var func_godot_properties : Dictionary = {
	"kills_required" : 3
}

const OPEN_MSG : Array[String] = [
	"A door has opened.",
	"You opened a door.",
	"You unlocked a door.",
	"A door has been unlocked."
]

var hitbox : CollisionShape3D
var mesh : MeshInstance3D

const GATE_MAT : ShaderMaterial = preload("res://textures/world/gate.tres")
const GATE_INFO : PackedScene = preload("res://prefab/level/misc/gate_info.tscn")
var material : ShaderMaterial

var checked : bool = false

func _func_godot_build_complete() -> void:
	for i in get_children():
		if i is CollisionShape3D:
			hitbox = i
		if i is MeshInstance3D: 
			mesh = i
	material = GATE_MAT.duplicate()
	mesh.material_override = material
	var gate_info : GateInfo = GATE_INFO.instantiate()
	add_child(gate_info)
	gate_info.name = "GateInfo"
	gate_info.global_position = hitbox.global_position
	gate_info.active = false
	
func _process(_delta: float) -> void:
	if hitbox.disabled : return
	if _G.game.enemies_killed >= func_godot_properties["kills_required"]:
		hitbox.disabled = true
		material.set_shader_parameter("distance_fade_min", 1.0)
		material.set_shader_parameter("albedo", Color("291e36ff"))
		_G.game.chat.add_message(OPEN_MSG.pick_random())
	if checked: return
	if Vector3(global_position.x, _G.player.global_position.y, global_position.z).distance_to(_G.player.global_position) < 10.0:
		_G.game.chat.add_message("Kill " + str(func_godot_properties["kills_required"] - _G.game.enemies_killed) + " enemies to unlock this door.")
		get_node("GateInfo").active = true
		checked = true
	
