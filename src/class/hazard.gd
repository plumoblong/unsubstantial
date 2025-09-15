extends Area3D
class_name Hazard

var parent : Node

@export var damage : int = 100
@export var crit : bool = false

@export var knockback_strength : float = 10.0
@export var knockback_y_strength : float = 1.0
@export var stun_time : float = 0.2
@export var parry : bool = false

@export var die_reason : String = "You Died!"

func _enter_tree() -> void:
	parent = get_parent()
	if _G.debug_mode:
		_T.say("DEBUG: Hazard (" + name + ") | NAME: " + str(parent.name) +" ID: " + str(parent), Color.YELLOW)
