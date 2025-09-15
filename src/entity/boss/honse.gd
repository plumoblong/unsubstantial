extends CharacterBody3D
class_name BossHonse

func _physics_process(delta : float) -> void:
	velocity = global_position.direction_to(_G.player.global_position) * 196.0 * delta
	$ShootComponent.shoot(global_position.direction_to(_G.player.global_position))
	move_and_slide()
