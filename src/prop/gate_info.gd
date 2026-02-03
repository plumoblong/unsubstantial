extends Node3D
class_name GateInfo

var queued_for_deletion : bool = false
var active : bool = false

func _process(_delta: float) -> void:
	if queued_for_deletion: return
	var remaining : int = get_parent().func_godot_properties["kills_required"] - _G.game.enemies_killed
	visible = _G.player.hud.visible and active
	if remaining >= 0: $Text.text = str(remaining)
	else: queued_for_deletion = true

func visible_on_screen_notifier_3d_screen_exited() -> void:
	if queued_for_deletion: queue_free()
