extends Node3D
class_name PlayerDeathAnim

@onready var anim : AnimationPlayer = get_node("Animation")

@export var cam_offset : float = 0.0
var played : bool = false

func play() -> void:
	if played: return
	anim.play("main")
	played = true
