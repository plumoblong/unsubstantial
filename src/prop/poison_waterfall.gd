extends Hazard

func _process(_delta: float) -> void:
	$Mesh.look_at(_G.player.global_position)
	$Mesh.rotation_degrees.x = 0.0
