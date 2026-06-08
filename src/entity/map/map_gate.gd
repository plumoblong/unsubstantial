extends StaticBody3D

@export var func_godot_properties : Dictionary[String, Variant] = {
	"kills_required" : 3, "boss_kills_required" : 0, "info" : true
}

const OPEN_MSG : Array[String] = [
	"A door has opened.",
	"You opened a door.",
	"You unlocked a door.",
	"A door has been unlocked.",
]

var hitbox : CollisionShape3D
var mesh : MeshInstance3D

const GATE_MAT : ShaderMaterial = preload("res://textures/world/gate.tres")
const GATE_INFO : PackedScene = preload("res://prefab/level/misc/gate_info.tscn")
var material : ShaderMaterial

#var checked : bool = false

func _func_godot_build_complete() -> void:
	for i in get_children():
		if i is CollisionShape3D:
			hitbox = i
		if i is MeshInstance3D: 
			mesh = i
	material = GATE_MAT.duplicate()
	mesh.material_override = material
	if not func_godot_properties["info"]: return
	var gate_info : GateInfo = GATE_INFO.instantiate()
	hitbox.add_child(gate_info)
	gate_info.name = "GateInfo"
	#gate_info.active = false
	
func _process(_delta: float) -> void:
	if _G.game.enemies_killed >= func_godot_properties["kills_required"] and _G.game.bosses_killed >= func_godot_properties["boss_kills_required"]:
		#if Vector3(global_position.x, _G.player.global_position.y, global_position.z).distance_to(_G.player.global_position) < 10.0:
		if hitbox.disabled: return
		hitbox.disabled = true
		material.set_shader_parameter("distance_fade_min", 1.0)
		material.set_shader_parameter("albedo", Color("291e36ff"))
		if not func_godot_properties["info"]: return
		_G.game.chat.add_message(OPEN_MSG.pick_random())
		
