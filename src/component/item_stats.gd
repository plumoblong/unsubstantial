extends Component
class_name ItemStats

@onready var p : Player = get_parent()

# These are the default stats for the player. They will be modified by items and shrines.

var added_stats : Array[Dictionary]

var luck : int = 0

var damage : int = 42
var damage_mult : float = 1.0
var dash_damage_mult : float = 1.25
var bullet_damage_mult : float = 1.0

var knockback : float = 1.0

var crit_chance : float = 1.0
var crit_mult : float = 1.0

var attack_speed : float = 1.0
var attack_speed_mult : float = 1.0
var bullet_atkspd : float = 0.75
var dash_atkspd : float = 1.25

var size : float = 1.0

var speed : float = 20.0
var acceleration : float = 0.3
var deceleration : float = 0.5

@export var bullet : BulletSettings

var dash_speed : float = 1.0

var esc_max : int = 300
var esc_mult : float = 1.0
var esc_decay : float = 5.0

var crosshair_width : float = 1.0

var defense : float = 10.0

var actual_damage : int
var actual_crit : float
var actual_atkspd : float

func add_stat(stat : String, to_add : float = 0.0, to_mult : float = 1.0) -> void:
	match stat:
		"Damage":
			damage += int(to_add)
			damage = int(damage * to_mult)
		"Attack Speed":
			attack_speed += to_add
			attack_speed_mult *= to_mult
		"Move Speed":
			speed += to_add
			speed *= to_mult
		"Knockback":
			knockback += to_add
			knockback *= to_mult
		"Max Essence":
			esc_max += to_add
			esc_max *= to_mult
			p.essence_component.gain(int(to_add + (p.essence_component.essence * to_mult)))
		"Healing":
			esc_mult += to_add
			esc_mult *= to_mult
		"Defense":
			defense += to_add
			defense *= to_mult
		"Bullet Count":
			bullet.shots += int(to_add)
			bullet.shots = int(bullet.shots * to_mult)
		"Luck":
			luck += int(to_add)
			luck *= to_mult
		"Bullet Range":
			bullet.life_time += to_add
			bullet.life_time *= to_mult
		"Bullet Speed":
			bullet.init_speed += to_add
			bullet.life_time *= to_mult
	_T.say("added " + stat)
	added_stats.append({"Statistic" : stat, "Add Bonus" : to_add, "Mult Bonus" : to_mult})

func update() -> void:
	
	actual_damage = int(damage * (damage_mult))
	actual_atkspd = clampf(attack_speed * attack_speed_mult, 0.25, 5.0)
	actual_crit = (crit_chance + (float(luck) / 5.0)) * crit_mult
	
	bullet.damage = (actual_damage * bullet_damage_mult) / (1 if bullet.shots <= 1 else int(float(bullet.shots) * 0.5))
	bullet.fire_rate = bullet_atkspd / actual_atkspd
	bullet.knockback = 24.0 * knockback
	bullet.spread_angle = bullet.shots * 5.0
	
	p.shoot_component.config = bullet
	p.shoot_component.crit_chance = actual_crit
	
	#dash_hit.damage = int(float(actual_damage) * dash_damage_mult)
	p.dash_component.dash_speed = 96.0 * dash_speed * (speed / 20.0)
	p.dash_component.cooldown = maxf(dash_atkspd / actual_atkspd, 0.75)
	p.get_node("DashQuery").knockback_strength = 64.0 * knockback
	bullet.knockback = 24.0 * knockback
	
	p.movement_component.walk_speed = speed
	
	p.essence_component.heal_multiplier = esc_mult
	p.essence_component.max_essence = esc_max
	p.essence_component.defense = defense

	var score_additive : int = (_G.current_run.kills * 100) + (_G.current_run.bosses_slained * 2000) + (_G.current_run.times_looped * 5000) + (_G.current_run.items_collected.times_bought * 200)
	var score_substract : int = (_G.current_run.hits_taken * 50)
	_G.current_run.score = score_additive - score_substract
	if _G.current_run.score > _G.save.high_score:
		_G.save.high_score = _G.current_run.score
