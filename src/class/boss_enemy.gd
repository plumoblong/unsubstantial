extends CharacterBody3D
class_name BossEnemy

@onready var essence_component : EssenceComponent = $EssenceComponent
@onready var timer : Timer = $BossTimer

@export var healthbar_enabled : bool = true
@export var healthbar_name : String = "Boss"
@export var healthbar_description : String = "yes"

var healthbar : BossBar

@export var phases : Dictionary[String, int]
@export var phase_times : Dictionary[String, float]
@export var phase_time_mult : float = 1.0
var current_phase : String

const HB_FILE = preload("res://prefab/menus/bossbar.tscn")

signal boss_defeated
signal phase_changed(current : String)

func boss_setup() -> void:
	
	timer.timeout.connect(_change_phase)
	essence_component.died.connect(_boss_defeated)
	
	_change_phase()
	
	if healthbar_enabled:
		var hb : BossBar = HB_FILE.instantiate()
		healthbar = hb
		add_child(hb)
		healthbar.esc = essence_component
		healthbar.boss_name = healthbar_name

func _change_phase() -> void:
	current_phase = _G.choose_from_chance(phases)
	timer.start(phase_times[current_phase] * phase_time_mult)
	_T.say(name + " has changed phase to " + current_phase)
	phase_changed.emit(current_phase)

func _boss_defeated(_combo : bool) -> void:
	_G.game.bosses_killed += 1
	boss_defeated.emit()
	
