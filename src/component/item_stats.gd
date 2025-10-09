extends Component
class_name ItemStats

var luck : int = 0

var damage : int = 60
var damage_mult : float = 1.0
var dash_damage_mult : float = 1.25
var bullet_damage_mult : float = 1.0

var enemy_knockback : float = 1.0
var self_knockback : float = 0.5

var crit_chance : float = 2.0
var crit_mult : float = 1.0

var attack_speed : float = 1.0
var attack_speed_mult : float = 1.0
var bullet_atkspd : float = 0.9
var dash_atkspd : float = 1.4

var size : float = 1.0

var speed : float = 20.0
var acceleration : float = 0.3
var deceleration : float = 0.5

@export var bullet : BulletSettings

var dash_speed : float = 1.0

var esc_max : int = 500
var esc_mult : float = 1.0
var esc_decay : float = 5.0

var crosshair_width : float = 1.0

var defense : float = 1.0

var actual_damage : int
var actual_crit : float
var actual_atkspd : float

func update(mov : PlayerMoveComponent, atk : ShootComponent, dash : DashComponent, esc : EssenceComponent, knock : KnockbackComponent, dash_hit : Hazard, ui : PlayerHUD) -> void:
	
	actual_damage = int(damage * (damage_mult) * (1.0 + float(get_parent().level_component.level) / 25.0))
	actual_atkspd = clampf(attack_speed * attack_speed_mult, 0.25, 5.0)
	actual_crit = (crit_chance + (float(luck) / 5.0)) * crit_mult
	
	bullet.damage = actual_damage * bullet_damage_mult
	bullet.fire_rate = bullet_atkspd / actual_atkspd
	bullet.knockback = 24.0 * enemy_knockback
	
	atk.config = bullet
	atk.crit_chance = actual_crit

	#dash_hit.damage = int(float(actual_damage) * dash_damage_mult)
	dash.dash_speed = 96.0 * dash_speed * (speed / 20.0)
	dash.cooldown = maxf(dash_atkspd / actual_atkspd, 0.75)
	dash_hit.knockback_strength = 64.0 * enemy_knockback
	bullet.knockback = 24.0 * enemy_knockback
	
	mov.walk_speed = speed
	#mov.speed_up = speed * acceleration
	#mov.speed_down = speed * deceleration
	
	knock.multiplier = self_knockback
	
	esc.heal_multiplier = esc_mult
	esc.max_essence = esc_max
	esc.defense = defense

	var score_additive : int = (_G.current_run.kills * 100) + ((_G.player.level_component.level - 1) * 1000) + (_G.current_run.bosses_slained * 2000) + (_G.current_run.times_looped * 5000) + (_G.current_run.items_collected.times_bought * 200)
	var score_substract : int = (_G.current_run.hits_taken * 50)
	var score_item : int = (_G.current_run.items_collected.common * 50) + (_G.current_run.items_collected.uncommon * 100) + (_G.current_run.items_collected.rare * 250) + (_G.current_run.items_collected.legendary * 500) + (_G.current_run.items_collected.mythic * 1000)
	_G.current_run.score = score_additive + score_item - score_substract
	if _G.current_run.score > _G.save.high_score:
		_G.save.high_score = _G.current_run.score
