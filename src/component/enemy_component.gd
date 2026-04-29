extends Component
class_name EnemyComponent

@onready var sprite : Sprite3D = get_parent().get_node("Sprite3D")
@onready var light : OmniLight3D = get_parent().get_node("OmniLight3D")

@export var hit_sfx : AudioStreamPlayer3D
@export var nav_agent : NavigationAgent3D


@export var use_difficulty_factor : bool = true

@export var essence : float = 100
@export var essence_death_threshold : float = 10
@export var damage : float = 100.0

@export var on_hit_velocity_loss : float = 0.5
@export var xp_payout : int = 3
@export var xp_radius : float = 1.5
@export var randomize_scale : float = 1.2
@export_category("entity death config")
@export var spawn_ent_on_death : bool = false
@export var ent_paths : Array[String] = ["res://prefab/entity/enemy/enemy.tscn"]
@export var ent_spawn_radius : float = 3.0
@export var ent_spawn_y_offset : float = 0.02
@export var ent_max : int = 3
@export var ent_min : int = 0
@export var ent_count_as_enemy : bool = true
@export var ent_spawn_offset : Vector3 = Vector3.ZERO
#@export var other_enemy_damage_taken_mult : float = 0.1
#@export var other_enemy_knockback_taken_mult : float = 0.75

@export_category("ghost config")
@export var ghost_decay_time : float = 1.5

var color : Color = Color.MAGENTA
var ent_amount : int

var random_factor : float = 0.0
var time_spawned : float 

var light_color : Color = Color.MAGENTA

func setup(esc : EssenceComponent, chase : ChaseComponent) -> void:
	esc.enabled = false
	if spawn_ent_on_death: 
		ent_amount = randi_range(ent_min, ent_max)
	
	time_spawned = _G.time
	if randomize_scale != 1.0:
		var rand_scale = randf_range(1.0, randomize_scale) if randomize_scale > 1.0 else randf_range(randomize_scale, 1.0)
		get_parent().scale = Vector3(rand_scale, rand_scale, rand_scale)
	random_factor = randf_range(0.00, 1.00)
	color = _G.game.get_chapter_color(random_factor)
	light_color = Color.from_hsv(color.h, color.s, 1.0, 1.0)
	pulse(Color(1.25, 1.25, 1.25, 0.0), chase.concious_gain_time * 0.75, chase.concious_gain_time * 0.5, Color(1.25, 1.25, 1.25, 1.0), Tween.TRANS_SINE)
	esc.max_essence = essence
	esc.essence = essence
	esc.die_threshold = essence_death_threshold
	esc.enabled = true
	_T.say(str(get_parent()) + " initialized enemy setup.", Color.YELLOW, true)
	if not use_difficulty_factor: return
	damage *= _G.game.enemy_multiplier
	esc.essence *= _G.game.enemy_multiplier
	esc.max_essence *= _G.game.enemy_multiplier
	
	#get_parent().scale *= clamp(get_difficulty_factor(0.05), 1.0, 1.5)
	
func handle_fracture(amount : int, i_time : float, combo : bool, mov : MovementComponent) -> void:
	if mov is MovementComponent:
		mov.vel *= on_hit_velocity_loss
	pulse(Color.WHITE, 0.25, i_time * 10.0)
	_G.game.create_popup_text(get_parent().global_position, "-" + str(amount), combo)
	hit_sfx.pitch_scale = randf_range(0.9, 1.15)
	hit_sfx.play()
	#_G.game.wait()

func handle_query(area : Area3D, esc : EssenceComponent, knock : KnockbackComponent) -> void:
	if area.get_parent() is not Player: return
	if not area is Hazard: return
	if area.damage < 1: return
	if sprite.modulate != Color.WHITE:
		esc.fracture(area.damage, area.crit, area.stun_time)
		var knock_pos : Vector3 = area.parent.global_position if area.knockback_from_parent_pos else area.global_position
		knock.knock(knock_pos, area.knockback_strength)
		if area is Bullet: 
			area.hit()
		_G.player.hud.hitmark()
		
func handle_spawn_ent() -> void:
	if not spawn_ent_on_death: return
	var ent_scene : PackedScene = load(ent_paths.pick_random()) 
	var s = ent_scene.instantiate()
	s.global_position = get_parent().global_position + Vector3(0.0, ent_spawn_y_offset, 0.0) \
	+ (Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)).normalized() * randf_range(0.0, ent_spawn_radius)) + ent_spawn_offset
	if ent_count_as_enemy:
		_G.game.enemies.add_child(s)
	else:
		_G.game.add_child(s)
		#if i <= ent_amount: continue 
		#else: break

func handle_death() -> void:
	for i : int in range(ent_amount): handle_spawn_ent()
	_G.game.create_ghost(sprite.global_position, sprite.texture, sprite.pixel_size * get_parent().scale.y, [sprite.frame, sprite.hframes, sprite.vframes], ghost_decay_time)
	_G.current_run.kills += 1
	_G.game.enemies_killed += 1
	_G.game.create_xporb(get_parent().global_position, xp_payout, xp_radius)
	get_parent().queue_free.call_deferred()

func shoot_to_player(shoot_component : ShootComponent, target_mult : float = 1.5, y_offset : float = 0.2) -> void:
	var spawn_pos : Vector3 = get_parent().global_position + Vector3(0.0, y_offset, 0.0) if not shoot_component.visual_bullet else shoot_component.visual_bullet.global_position
	shoot_component.shoot(spawn_pos.direction_to(_G.player.target.get_pos_multiplied(target_mult + random_factor) \
	+ Vector3(0.0, 0.15 + (random_factor * 0.2), 0.0)), spawn_pos)

func get_difficulty_factor(mult : float = 1.0) -> float:
	return 1.0 + ((_G.game.enemy_multiplier - 1.0) * mult)

func pulse(pulse_color : Color = Color.WHITE, sprite_time : float = 0.25, light_time : float = 0.2, mult_color : Color = Color.WHITE, trans : Tween.TransitionType = Tween.TRANS_CIRC) -> void:
	sprite.modulate = pulse_color * mult_color
	light.light_color = pulse_color * mult_color
	_G.tween(sprite, "modulate", color, sprite_time, Tween.TRANS_CIRC, Tween.EASE_IN)
	_G.tween(light, "light_color", light_color, light_time, Tween.TRANS_CIRC, Tween.EASE_IN)
