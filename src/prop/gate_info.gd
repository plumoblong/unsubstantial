extends WorldTo2D
class_name GateInfo

func _physics_process(_delta: float) -> void:
	var remaining : int = get_parent().get_parent().func_godot_properties["kills_required"] - _G.game.enemies_killed
	if remaining > 0: 
		$Text.text = str(remaining)
		$Text.visible = true
		$Door.frame = 0
	else: 
		$Text.text = "Open!"
		$Text.visible = false
		$Door.frame = 1
