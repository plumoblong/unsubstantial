extends StaticBody3D

var on : bool = true

func area_3d_body_entered(_body : Player) -> void:
	disapear()

func disapear() -> void:
	
	#global.tween($Crate, "transparency", 1.0, 1.0)
	#global.tween($Outline, "transparency", 1.0, 1.0)
	if on:
		$AnimationPlayer.play_backwards("appear")
	on = false
	await get_tree().create_timer(0.75).timeout
	
	$CollisionShape3D.disabled = true
	await get_tree().create_timer(4.25).timeout
	appear()
	
func appear() -> void:
	
	#global.tween($Crate, "transparency", 0.0, 1.0)
	#global.tween($Outline, "transparency", 0.0, 1.0)
	if not on:
		$AnimationPlayer.play("appear")
	on = true
	await get_tree().create_timer(1.0).timeout
	$CollisionShape3D.disabled = false
