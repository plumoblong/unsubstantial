extends Interaction
class_name UnstableCrystal

@onready var anim : AnimationPlayer = get_node("Anim")

func _func_godot_build_complete() -> void:
	if not enabled: return
	anim.play("idle")

func on_interacted() -> void:
	anim.play("shatter")
