extends Area3D

@export var time : float = 0.75

func body_entered(body : Node3D) -> void:
	if body is not Player: return
	_G.game.mute_music(time)

func body_exited(body : Node3D) -> void:
	if body is not Player: return
	_G.game.unmute_music(time)
