extends Component
class_name EnemyComponent

@export var sprite : Sprite3D
@export var colored_sprite : Sprite3D

@onready var light    : OmniLight3D = get_parent().get_node("OmniLight3D")

@export var esc    : EssenceComponent
@export var chase      : ChaseComponent
@export var movement   : MovementComponent
@export var knock      : KnockbackComponent
@export var query      : Area3D

@export var hit_sfx   : AudioStreamPlayer3D
@export var nav_agent : NavigationAgent3D

@export var is_flying : bool = false
@export var use_difficulty_factor     : bool  = true
@export var essence                   : float = 100
@export var essence_death_threshold   : float = 10
@export var damage                    : float = 100.0
@export var on_hit_velocity_loss      : float = 0.5
@export var xp_payout                 : int   = 3
@export var xp_radius                 : float = 1.5
@export var randomize_scale           : float = 1.2
@export var pitch                     : float = 1.0

@export_category("entity death config")
@export var spawn_ent_on_death     : bool          = false
@export var ent_paths              : Array[String] = ["res://prefab/entity/enemy/enemy.tscn"]
@export var ent_spawn_radius       : float         = 3.0
@export var ent_spawn_y_offset     : float         = 0.02
@export var ent_max                : int           = 3
@export var ent_min                : int           = 0
@export var ent_count_as_enemy     : bool          = true
@export var ent_spawn_offset       : Vector3       = Vector3.ZERO

@export_category("ghost config")
@export var ghost_decay_time : float = 1.5
@export var ghost_texture_override : Texture

var color         : Color = Color.MAGENTA
var ent_amount    : int
var random_factor : float = 0.0
var time_spawned  : float
var light_color   : Color = Color.MAGENTA
var colored_color : Color = Color.MAGENTA


# Cached get_parent() — eliminates repeated scene-tree traversal every frame/hit
var _parent     : CharacterBody3D

# Cached per-frame values to avoid redundant lookups in update()
var _cached_y_boundary : float
var _boundary_dirty    : bool = true

# Precomputed pitch clamp bounds — avoids recalculating on every hit
var _pitch_min : float
var _pitch_max : float

func setup() -> void:
	_parent = get_parent()
	_parent.name = _parent.name + "_" + str(_G.game.enemy_count)

	# Precompute pitch bounds once rather than every hit
	_pitch_min = 0.9 * pitch
	_pitch_max = 1.2 * pitch

	esc.fractured.connect(_handle_fracture)
	esc.died.connect(_handle_death)
	query.area_entered.connect(_handle_query)
	esc.enabled = false

	if spawn_ent_on_death:
		ent_amount = randi_range(ent_min, ent_max)

	time_spawned = _G.time

	if randomize_scale != 1.0:
		var s : float = randf_range(1.0, randomize_scale) if randomize_scale > 1.0 \
			else randf_range(randomize_scale, 1.0)
		_parent.scale = Vector3.ONE * s

	random_factor  = randf_range(0.0, 1.0)
	colored_color          = _G.game.get_chapter_color(random_factor)
	color                  = Color.WHITE
	light_color    = Color.from_hsv(colored_color.h, colored_color.s, max(colored_color.v, 0.7), 1.0)

	pulse(Color(1.25, 1.25, 1.25, 0.0), chase.concious_gain_time * 0.75,
		chase.concious_gain_time * 0.5, Color(1.25, 1.25, 1.25, 1.0), Tween.TRANS_SINE, false, true)

	esc.max_essence   = essence
	esc.essence       = essence
	esc.die_threshold = essence_death_threshold
	esc.enabled       = true

	if nav_agent:
		_G.game.nav_scheduler.register(nav_agent, chase, movement)

	if use_difficulty_factor:
		var m : float = _G.game.enemy_multiplier
		damage          *= m
		esc.essence     *= m
		esc.max_essence *= m

	_T.say("\n" + _parent.name + " initialized.\nEssence: " + str(esc.essence)
		+ " / " + str(essence) + "\nDamage:" + str(damage), light_color, 0)


## Call at the top of every enemy's _physics_process.
## Returns false if the enemy fell out of bounds (it will die this frame).
func update(delta: float, movement: MovementComponent) -> bool:
	# Single chain dereference each, stored locally for this frame
	var player     := _G.player
	var can_control: bool  = player.can_control

	# y_boundary only changes when chapter changes — mark dirty externally if needed,
	# or recache lazily here (cheap branch vs repeated property chain)
	if _boundary_dirty:
		_cached_y_boundary = _G.game.chapter.current.y_boundary
		_boundary_dirty    = false

	if _parent.global_position.y <= _cached_y_boundary:
		esc.die()
		return false

	if is_flying: 
		movement.update_flying(delta)
	else: 
		movement.update(delta, _parent.is_on_ceiling_only())
	esc.update()
	movement.enabled  = can_control
	chase.enabled    = can_control
	_parent.velocity  = movement.vel
	_parent.move_and_slide()

	return true

func _handle_fracture(amount: int, _i_time: float, combo: bool) -> void:
	movement.vel         *= 0.35
	pulse(Color.WHITE, 0.25, 0.2, Color.WHITE, Tween.TRANS_CIRC, false, true)
	_G.player.combo += 1
	#_G.game.create_popup_text(_parent.global_position, "-" + str(amount), combo)
	# pitch_min/max precomputed in setup — no per-hit recalc
	hit_sfx.pitch_scale    = randf_range(_pitch_min, _pitch_max)
	hit_sfx.play()

func _handle_query(area: Area3D) -> void:
	# Cheapest checks first — avoids casting until necessary
	if area is not Hazard:                 return
	if area.damage < 1:                    return
	if area.get_parent() is not Player:    return
	if sprite.modulate == Color.WHITE:     return

	esc.fracture(area.damage, area.crit, area.stun_time)

	var knock_pos: Vector3 = area.parent.global_position \
		if area.knockback_from_parent_pos else area.global_position
	knock.knock(knock_pos, area.knockback_strength)

	if area is Bullet: area.hit()
	_G.player.hud.hitmark()


func _handle_spawn_ent() -> void:
	if not spawn_ent_on_death: return
	var s = (load(ent_paths.pick_random()) as PackedScene).instantiate()
	s.global_position = _parent.global_position \
		+ Vector3(0.0, ent_spawn_y_offset, 0.0) \
		+ Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)).normalized() \
			* randf_range(0.0, ent_spawn_radius) \
		+ ent_spawn_offset
	if ent_count_as_enemy: _G.game.enemies.add_child(s)
	else:                  _G.game.add_child(s)


func _handle_death(_combo: bool) -> void:
	for i in range(ent_amount): _handle_spawn_ent()
	_G.game.create_ghost(
		sprite.global_position,
		_get_texture_for_ghost(),
		sprite.pixel_size * _parent.scale.y,
		[sprite.frame, sprite.hframes, sprite.vframes],
		ghost_decay_time)
	_G.current_run.kills   += 1
	_G.game.enemies_killed += 1
	_G.game.create_xporb(_parent.global_position, xp_payout + _G.game.bosses_killed, xp_radius)
	_parent.queue_free.call_deferred()


func shoot_to_player(shoot_component: ShootComponent,
		target_mult: float = 1.5, y_offset: float = 0.2) -> void:
	# Cache visual_bullet lookup — avoids repeated property access in one call
	var vb    := shoot_component.visual_bullet
	var spawn : Vector3 = (vb.global_position if vb else
		_parent.global_position + Vector3(0.0, y_offset, 0.0))
	shoot_component.shoot(
		spawn.direction_to(
			_G.player.target.get_pos_multiplied(target_mult + random_factor)
			+ Vector3(0.0, 0.15 + random_factor * 0.2, 0.0)),
		spawn)


func get_difficulty_factor(mult: float = 1.0) -> float:
	return 1.0 + ((_G.game.enemy_multiplier - 1.0) * mult)


func pulse(pulse_color: Color = Color.WHITE, sprite_time: float = 0.25,
		light_time: float = 0.2, mult_color: Color = Color.WHITE,
		trans: Tween.TransitionType = Tween.TRANS_CIRC, pulse_colored_sprite : bool = false, pulse_all : bool = true) -> void:
	var c : Color = pulse_color * mult_color
	sprite.modulate    = c
	#if pulse_colored_sprite or pulse_all: _get_colored_sprite().modulate = c
	light.light_color  = c
	_G.tween(light,"light_color", light_color, light_time,  Tween.TRANS_CIRC, Tween.EASE_IN)
	_G.tween(sprite, "modulate", colored_color, sprite_time, Tween.TRANS_CIRC, Tween.EASE_IN)
	#if pulse_all:
		#_G.tween(sprite, "modulate", color,sprite_time, Tween.TRANS_CIRC, Tween.EASE_IN)
		#_G.tween(_get_colored_sprite(), "modulate", colored_color, sprite_time, Tween.TRANS_CIRC, Tween.EASE_IN)
		#return
		#
	#if not pulse_colored_sprite:
		#_G.tween(sprite, "modulate", color, sprite_time, Tween.TRANS_CIRC, Tween.EASE_IN)
	#else:
		#_G.tween(_get_colored_sprite(), "modulate", colored_color, sprite_time, Tween.TRANS_CIRC, Tween.EASE_IN)

## Call when the active chapter changes so y_boundary is refetched next frame.
func mark_boundary_dirty() -> void:
	_boundary_dirty = true

func cleanup() -> void:
	if nav_agent:
		_G.game.nav_scheduler.unregister(nav_agent)

func _get_texture_for_ghost() -> Texture:
	if ghost_texture_override == null: return sprite.texture
	return ghost_texture_override

func _get_colored_sprite() -> Sprite3D:
	if colored_sprite == null: return sprite
	return colored_sprite
