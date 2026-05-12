extends StaticBody3D

var hitbox : CollisionShape3D

@export var func_godot_properties : Dictionary[String, Variant] = {
	"check_x" : false, "check_y" : true, "check_z" : false, "negative" : true, "margin" : 2.0
}

func _func_godot_build_complete() -> void:
	for i in get_children():
		if i is CollisionShape3D:
			hitbox = i
			break
	
func _process(_delta: float) -> void:
	if hitbox == null or func_godot_properties == null: return
	hitbox.disabled = _check_x() or _check_y() or _check_z()
	print(hitbox.disabled, _check_x(),_check_y(),_check_z())
		
func _check_x() -> bool:
	if not func_godot_properties["check_x"]: return false
	if func_godot_properties["negative"]:return _G.player.global_position.x > global_position.x + _get_margin()
	return _G.player.global_position.x < global_position.x + _get_margin()

func _check_z() -> bool:
	if not func_godot_properties["check_z"]: return false
	if func_godot_properties["negative"]:return _G.player.global_position.z > global_position.z + _get_margin()
	return _G.player.global_position.z < global_position.z + _get_margin()

func _check_y() -> bool:
	if not func_godot_properties["check_y"]: return false
	if func_godot_properties["negative"]:return _G.player.global_position.y > global_position.y  + _get_margin()
	return _G.player.global_position.y < global_position.y + _get_margin()

func _get_margin() -> float:
	return func_godot_properties["margin"] * -1.0 if func_godot_properties["negative"] else 1.0
