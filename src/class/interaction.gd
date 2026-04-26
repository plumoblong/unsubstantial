extends Area3D
class_name Interaction

@export var enabled : bool = true
@export var one_shot : bool = true

@export var interaction_tooltip : String = ""
@export var description_tooltip : String = ""

var can_interact : bool = false
signal interacted
signal hooked
signal unhooked

func _process(_delta : float) -> void:
	if not enabled: 
		return
	if Input.is_action_pressed("interact") and can_interact:
		interacted.emit()
		if one_shot:
			_G.player.hud.interact_tooltip = ""
			_G.player.hud.interact_description = ""
			enabled = false
			
func area_entered(area : Area3D) -> void:
	if area.name != "InteractionQuery" or not enabled: return
	_G.player.can_interact = true
	can_interact = true
	_G.player.hud.interact_tooltip = interaction_tooltip
	_G.player.hud.interact_description = description_tooltip
	hooked.emit()
	print(name, can_interact, enabled)
	
func area_exited(area : Area3D) -> void:
	if area.name != "InteractionQuery" or not enabled: return
	_G.player.can_interact = false
	can_interact = false
	_G.player.hud.interact_tooltip = ""
	_G.player.hud.interact_description = ""
	unhooked.emit()
	print(name, can_interact, enabled)
