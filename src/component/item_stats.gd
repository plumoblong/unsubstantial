extends Component
class_name ItemStats

const PLAYER_BULLET_DEFAULT : BulletSettings = preload("res://res/bullet_cfg/player_default.tres")

@onready var p : Player = get_parent()

# These are the default stats for the player. They will be modified by items and shrines.

var added_stats : Array[Array]

#only affects items
var luck : float = 1.0
var luck_mult : float = 1.0
var luck_bonus : float = 1.0
var choices : int = 2

var damage : int = 50
var damage_mult : float = 1.0
var dash_damage_mult : float = 1.5
var bullet_damage_mult : float = 1.0

var knockback : float = 1.0

var crit_chance : float = 0.0
var crit_mult : float = 1.0

var attack_speed : float = 1.0
var dash_attack_speed : float = 1.0

const BULLET_ATKSPD : float = 0.9
const DASH_ATKSPD : float = 1.25

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
var actual_luck : float

func _ready() -> void:
	bullet = PLAYER_BULLET_DEFAULT.duplicate()

func add_stat(modulate : Modulate, stat_texture : Texture) -> void:
	modulate.append()
	added_stats.push_back([modulate, stat_texture])

func update() -> void:
	
	actual_damage = int(damage * (damage_mult))
	actual_atkspd = clampf(attack_speed, 0.25, 6.0)
	actual_crit = crit_chance * crit_mult
	actual_luck = minf(luck * luck_mult * luck_bonus, 100.0)
	
	bullet.damage = (actual_damage * bullet_damage_mult) / maxf(actual_atkspd * 0.75, 1.0) 
	bullet.fire_rate = BULLET_ATKSPD / actual_atkspd
	bullet.knockback = knockback
	bullet.spread_angle = bullet.shots * 4.0
	bullet.inaccuracy = (actual_atkspd - 1.0) * 0.025
	
	p.shoot_component.config = bullet
	p.shoot_component.crit_chance = actual_crit
	
	#dash_hit.damage = int(float(actual_damage) * dash_damage_mult)
	p.dash_component.dash_speed = 80.0 * dash_speed
	p.dash_component.cooldown = maxf(DASH_ATKSPD / dash_attack_speed, 0.6)
	p.get_node("DashQuery").knockback_strength = 3.0 * knockback
	
	p.movement_component.walk_speed = speed
	
	p.essence_component.heal_multiplier = esc_mult
	p.essence_component.max_essence = esc_max
	p.essence_component.defense = defense * (1 + (float(p.god_mode) * 999999.0))
	
	p.knock_component.multiplier = 2.0 / (defense / 10.0)

	var score_additive : int = (_G.current_run.kills * 100) + (_G.current_run.boss_kills * 2000) + (_G.current_run.times_looped * 5000) + (_G.current_run.items_collected.times_bought * 200)
	var score_substract : int = (_G.current_run.hits_taken * 50)
	_G.current_run.score = score_additive - score_substract
	if _G.current_run.score > _G.save.high_score:
		_G.save.high_score = _G.current_run.score

func get_dash_damage() -> int:
	return actual_damage
