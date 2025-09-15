extends Component
class_name EnemyComponent

@onready var sprite : Sprite3D = get_parent().get_node("Sprite3D")

@export var hit_sfx : AudioStreamPlayer3D

@export var color : Color = Color.MAGENTA

@export var essence : float = 100

@export var damage : float = 100.0

@export var on_hit_velocity_loss : float = 0.5
@export var xp_payout : int = 3
@export var xp_radius : float = 3.0
@export var randomize_scale : float = 1.1

var random_factor : float = 0.0
var time_spawned : float 

func setup(esc : EssenceComponent) -> void:
	_T.say(str(get_parent()) + " initialized enemy setup.", Color.YELLOW, true)
	time_spawned = _G.time
	var rand_scale = randf_range(1.0, randomize_scale)
	get_parent().scale = Vector3(rand_scale, rand_scale, rand_scale)
	random_factor = randf_range(0.00, 1.00)
	color = _G.hsv_to_rgb(randf_range(0.00, 1.00), randf_range(0.5, 1.0), randf_range(0.6, 1.0))
	damage *= _G.game.enemy_multiplier
	esc.max_essence = int(float(essence) * _G.game.enemy_multiplier)
	esc.essence = int(float(essence) * _G.game.enemy_multiplier)
	sprite.modulate = color

func handle_fracture(amount : int, i_time : float, mov : MovementComponent, light : Light3D) -> void:
	if mov is MovementComponent:
		mov.vel *= on_hit_velocity_loss
	sprite.modulate = Color.WHITE
	#_G.game.create_popup_text(global_position, str(amount), _G.player.stats.bullet.color, crit)
	_G.tween(sprite, "modulate", color, 0.25)
	_G.tween(light, "light_color", color, i_time)
	#_G.tween(essence_component, "defense", 1.0, i_time)
	hit_sfx.pitch_scale = randf_range(0.9, 1.15)
	hit_sfx.play()

func handle_query(area : Area3D, esc : EssenceComponent, knock : KnockbackComponent) -> void:
	if area.get_parent() == get_parent(): return
	if area is Hazard:
		if area.damage < 1: return
		if not area.parent is Player: return
		if sprite.modulate != Color.WHITE: 
			esc.fracture(area.damage, area.crit, area.stun_time)
			if area.get_parent() is Player: area.get_parent().hud.hitmark()
			knock.knock(area.get_parent().global_position, area.knockback_strength, area.knockback_y_strength)
			if area is Bullet: area.hit()

func handle_death() -> void:
	_G.game.create_ghost(get_parent().global_position, sprite.texture, sprite.pixel_size)
	_G.current_run.kills += 1
	_G.game.create_xporb(get_parent().global_position, xp_payout, xp_radius)
	get_parent().queue_free.call_deferred()
