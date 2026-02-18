extends CharacterBody3D
class_name BossEnemy

@export var healthbar_enabled : bool = true
@export var healthbar_name : String = "Boss"
@export var healthbar_color : Color = Color.RED
@export var healthbar_description : String = "yes"

@export var phases : int = 2
var phase : int = 0

const HB_FILE = preload("res://prefab/menus/bossbar.tscn")

signal phase_changed
signal boss_defeated

func _ready() -> void:
	if healthbar_enabled:
		var hb = HB_FILE.instantiate()
		
		add_child(hb)
		hb.name = healthbar_name
		hb.color = healthbar_color
