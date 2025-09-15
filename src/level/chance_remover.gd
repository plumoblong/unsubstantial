extends Node
class_name ChanceRemover

@export var chance_percentage : float = 50.0
@export var chance_progression : float = 0.0

@export var is_child : bool = false
@export var delay : float = 0.0

func _enter_tree() -> void:
	await get_tree().create_timer(delay).timeout
	var i : float = randf_range(0.0, 100.0)
	var chance : float = clampf(chance_percentage + (chance_progression * float(_G.player.level_component.level - 1)), 0.0, 100.0)
	if chance <= i:
		if not is_child: queue_free()
		else: get_parent().queue_free()
