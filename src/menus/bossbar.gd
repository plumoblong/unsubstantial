extends Node2D
class_name BossBar

@export var boss_name : String = "Boss"
@export var description : String = "Enemy but special."
@export var color : Color = Color.RED
@export var esc : EssenceComponent

func _physics_process(delta : float) -> void:
	$Name.text = boss_name
	$Bar.size.x = lerp($Bar.size.x, esc.ratio * 196.0, 0.2)
	$Bar.position.x = 212.0 - $Bar.size.x / 2.0
	$Health.text = str(esc.essence)
