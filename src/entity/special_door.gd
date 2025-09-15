extends Area3D
class_name SpecialDoor

@export var free : bool = false

@onready var point : Node3D = get_node("Node3D")

#func _ready() -> void:
	#if free: return
	#if not _G.game.special_aviable: queue_free.call_deferred() 	
#
#func body_entered(_body : Player) -> void:
	#if _G.game.in_special:
		#_G.game.exit_special()
	#else:  
		#_G.game.enter_special()
