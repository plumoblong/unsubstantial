extends Node
class_name EnemyHandler

#used to 

var cleared : bool = false
var children_amt : int = 0

func _process(delta : float) -> void:
	cleared = get_child_count() == 0
