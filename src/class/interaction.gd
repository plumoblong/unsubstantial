extends Area3D
class_name Interaction

@export var enabled : bool = true
@export var one_shot : bool = true

@export var interaction_tooltip : String = ""
@export var description_tooltip : String = ""

var can_interact : bool = false
signal interacted

func _process(_delta : float) -> void:
	if can_interact and enabled:
		if Input.is_action_pressed("interact"):
			interacted.emit()
			if one_shot:
				enabled = false
		
	monitoring = enabled

func area_entered(area : Area3D) -> void:
	if area.get_parent() == _G.player:
		_G.player.can_interact = true
		can_interact = true
		_G.player.hud.interact_tooltip = interaction_tooltip
		_G.player.hud.interact_description = description_tooltip

func area_exited(area : Area3D) -> void:
	if area.get_parent() == _G.player:
		_G.player.can_interact = false
		can_interact = false
		_G.player.hud.interact_tooltip = ""
		_G.player.hud.interact_description = ""
