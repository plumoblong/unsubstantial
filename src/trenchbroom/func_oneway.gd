extends StaticBody3D

var hitbox : CollisionShape3D

func _func_godot_build_complete() -> void:
	for i in get_children():
		if i is CollisionShape3D:
			hitbox = i
			break
	
func _process(_delta: float) -> void:
	if hitbox == null: return
	hitbox.disabled = _G.player.global_position.y < global_position.y
		
