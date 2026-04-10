extends Node2D
class_name BossBar

@export var boss_name : String = "Boss"
@export var description : String = "Enemy but special."
@export var color : Color = Color.RED

var esc : EssenceComponent

@onready var name_label : Label = $Bossbar/Name
@onready var bar : NinePatchRect = $Bossbar/Bar
@onready var bossbar : Node2D = $Bossbar

func update(color : Color) -> void:
	if not esc: return
	if bossbar == null: return
	if bar == null: return
	if name_label == null: return
	bossbar.position = _R.get_center()
	name_label.text = boss_name
	bar.size.x = lerp(bar.size.x, esc.ratio * 196.0, 0.2)
	if bar.material == null: return
	bar.material.set_shader_parameter("modulate", color)
	if esc.ratio <= 0.0 or not _G.player.essence_component.alive:
		hide()
 
