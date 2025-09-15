extends Sprite3D

var seen : bool = false


func screen_enter() -> void:
	if global_position.distance_to(_G.player.global_position) < 20.0:
		seen = true

func screen_exit() -> void:
	if seen:
		queue_free()
