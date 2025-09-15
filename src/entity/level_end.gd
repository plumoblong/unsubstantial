extends Area3D
class_name LevelEnd

#func _process(_delta : float) -> void:
	#$Opener/Hitbox.disabled = get_child_count() - 7 != 0
	##print(get_child_count()- 7)
	#$MeshInstance3D2.mesh.text = str(get_child_count()- 7)
	#
func opener_body_entered(_body : Player) -> void:
	$AnimationPlayer.play("open")
	

func body_entered(_body : Player) -> void:
	_G.game.end_level()
	
