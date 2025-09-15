extends Area3D

@export var time : float = 0.75

func body_entered(_body : Player) -> void:
	_G.game.mute_music(time)

func body_exited(_body : Player) -> void:
	_G.game.unmute_music(time)
