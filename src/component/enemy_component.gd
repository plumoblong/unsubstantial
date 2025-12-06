extends Component
class_name EnemyComponent

@onready var sprite : Sprite3D = get_parent().get_node("Sprite3D")

@export var hit_sfx : AudioStreamPlayer3D

@export var color : Color = Color.MAGENTA

@export var essence : float = 100

@export var damage : float = 100.0

@export var on_hit_velocity_loss : float = 0.5
@export var xp_payout : int = 3
@export var xp_radius : float = 1.5
@export var randomize_scale : float = 1.2

@export var spawn_ent_on_death : bool = false
@export_file("*.tscn") var ent_path : String = "res://prefab/entity/enemy/enemy.tscn"
@export var ent_spawn_radius : float = 3.0
@export var ent_spawn_y_offset : float = 0.02
@export var ent_max : int = 3
@export var ent_min : int = 0
@export var ent_count_as_enemy : bool = true

var ent_amount : int
var ent_scene : PackedScene

var random_factor : float = 0.0
var time_spawned : float 

func setup(esc : EssenceComponent) -> void:
	esc.enabled = false
	if spawn_ent_on_death: 
		ent_scene = load(ent_path)
		ent_amount = randi_range(ent_min, ent_max)
	_T.say(str(get_parent()) + " initialized enemy setup.", Color.YELLOW, true)
	time_spawned = _G.time
	if randomize_scale != 1.0:
		var rand_scale = randf_range(1.0, randomize_scale) if randomize_scale > 1.0 else randf_range(randomize_scale, 1.0)
		get_parent().scale = Vector3(rand_scale, rand_scale, rand_scale)
	random_factor = randf_range(0.00, 1.00)
	color = _G.hsv_to_rgb(randf_range(0.00, 1.00), randf_range(0.5, 1.0), randf_range(0.6, 1.0))
	damage *= _G.game.enemy_multiplier
	esc.max_essence = int(float(essence) * _G.game.enemy_multiplier)
	esc.essence = int(float(essence) * _G.game.enemy_multiplier)
	sprite.modulate = color
	esc.enabled = true
	
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
			_G.game.wait()
			if area.get_parent() is Player: area.get_parent().hud.hitmark()
			knock.knock(area.get_parent().global_position, area.knockback_strength, area.knockback_y_strength)
			if area is Bullet: area.hit()

func handle_spawn_ent() -> void:
	if not spawn_ent_on_death: return
	var s = ent_scene.instantiate()
	s.global_position = get_parent().global_position + Vector3(0.0, ent_spawn_y_offset, 0.0) \
	+ (Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)).normalized() * randf_range(0.0, ent_spawn_radius))
	if ent_count_as_enemy:
		_G.game.enemies.add_child(s)
	else:
		_G.game.add_child(s)
		#if i <= ent_amount: continue 
		#else: break

func handle_death() -> void:
	for i : int in range(ent_amount): handle_spawn_ent()
	_G.game.create_ghost(get_parent().global_position, sprite.texture, sprite.pixel_size * get_parent().scale.y)
	_G.current_run.kills += 1
	_G.game.enemies_killed += 1
	_G.game.create_xporb(get_parent().global_position, int(ceil(float(xp_payout * _G.game.enemy_multiplier))), xp_radius)
	get_parent().queue_free.call_deferred()
