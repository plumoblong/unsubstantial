extends Component
class_name ItemStats

const PLAYER_BULLET_DEFAULT : BulletSettings = preload("res://res/bullet_cfg/player_default.tres")

@onready var p : Player = get_parent()

# These are the default stats for the player. They will be modified by items and shrines.

var added_stats : Array[Array]

var luck : int = 0
#only affects choosing the crystal shards
var choices : int = 2

var damage : int = 50
var damage_mult : float = 1.0
var dash_damage_mult : float = 1.5
var bullet_damage_mult : float = 1.0

var knockback : float = 1.0

var crit_chance : float = 0.0
var crit_mult : float = 1.0

var attack_speed : float = 1.0
var attack_speed_mult : float = 1.0
var bullet_atkspd : float = 0.9
var dash_atkspd : float = 1.25

var size : float = 1.0

var speed : float = 18.0
var acceleration : float = 0.3
var deceleration : float = 0.5

@export var bullet : BulletSettings

var dash_speed : float = 1.0

var esc_max : int = 300
var esc_mult : float = 1.0
var esc_decay : float = 5.0

var money_mult : float = 1.0

var defense : float = 10.0

var actual_damage : int
var actual_crit : float
var actual_atkspd : float



func _ready() -> void:
	bullet = PLAYER_BULLET_DEFAULT.duplicate()
	

func add_stat(modulate : Modulate, stat_texture : Texture) -> void:
	modulate.append()
	added_stats.push_back([modulate, stat_texture])

func update() -> void:
	
	actual_damage = int(damage * (damage_mult))
	actual_atkspd = clampf(attack_speed * attack_speed_mult, 0.25, 6.0)
	actual_crit = (crit_chance + (float(luck) / 5.0)) * crit_mult
	
	bullet.damage = (actual_damage * bullet_damage_mult) / (1 if bullet.shots <= 1 else int(float(bullet.shots) * 0.5))
	bullet.fire_rate = bullet_atkspd / actual_atkspd
	bullet.knockback = 2.0 * knockback
	bullet.spread_angle = bullet.shots * 5
	bullet.inaccuracy = (actual_atkspd - 1.0) * 0.1
	
	p.shoot_component.config = bullet
	p.shoot_component.crit_chance = actual_crit
	
	#dash_hit.damage = int(float(actual_damage) * dash_damage_mult)
	p.dash_component.dash_speed = 96.0 * dash_speed
	p.dash_component.cooldown = maxf(dash_atkspd / actual_atkspd, 0.67)
	p.get_node("DashQuery").knockback_strength = 6.0 * knockback
	
	p.movement_component.walk_speed = speed
	
	p.essence_component.heal_multiplier = esc_mult
	p.essence_component.max_essence = esc_max
	p.essence_component.defense = defense * (1 + (float(p.god_mode) * 999999.0))
	
	p.knock_component.multiplier = 2.0 / (defense / 10.0)

	var score_additive : int = (_G.current_run.kills * 100) + (_G.current_run.bosses_slained * 2000) + (_G.current_run.times_looped * 5000) + (_G.current_run.items_collected.times_bought * 200)
	var score_substract : int = (_G.current_run.hits_taken * 50)
	_G.current_run.score = score_additive - score_substract
	if _G.current_run.score > _G.save.high_score:
		_G.save.high_score = _G.current_run.score
