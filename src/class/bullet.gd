extends Hazard
class_name Bullet

@onready var sprite: Sprite3D = $Sprite3D
@onready var light: OmniLight3D = $OmniLight3D
@onready var raycast: RayCast3D = $RayCast3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var impact_particles: GPUParticles3D = $Impact
@onready var static_sfx: AudioStreamPlayer3D = $StaticSFX
@onready var impact_sfx: AudioStreamPlayer3D = $ImpactSFX

@export var config: BulletSettings

var direction : Vector3
var velocity : Vector3
var world_velocity : Vector3
var speed : float
var pierces_left : int

var active : bool = true
var disable_seek : bool = true
var can_attack_parent : bool = false

var target : Node3D
var target_blacklist : Array[Node3D]
const BLACKLIST_LIMIT : int = 5

# Cached base speed after _setup_speed(), used as the anchor for acceleration math.
var _base_speed : float
const BASE_SIZE : float = 0.5
const SIZE_CLAMP_MIN : float = 34.0
const SIZE_CLAMP_MAX : float = 1000.0
const SIZE_DIVISOR : float = 400.0
const PIERCE_HITBOX_ACTIVATE_TIME : float = 0.06
const HOMING_ACTIVATE_TIME : float = 0.1
const HOMING_REACH_DISTANCE : float = 0.2
const HOMING_INTERPOLATION : float = 0.35

func _ready() -> void:
	pierces_left = config.pierces
	_setup_damage()
	_setup_speed()
	_setup_visuals()
	_setup_homing()
	_setup_audio()
	_setup_scale()
	_start_lifetime()
	await get_tree().create_timer(stun_time).timeout
	disable_seek = false

func _physics_process(delta: float) -> void:
	static_sfx.volume_linear = float(_G.player.can_control)
	if not active or not _G.player.can_control:
		return
	_update_speed_from_lifetime()
	_update_movement(delta)
	
func _setup_damage() -> void:
	damage = config.damage * (2.0 if crit else 1.0)
	knockback_strength = config.knockback
	stun_time = config.stun

func _setup_speed() -> void:
	speed = config.init_speed
	if parent is Player:
		speed += parent.velocity.length() * 0.75
	_base_speed = speed

func _setup_visuals() -> void:
	if get_parent() is Player:
		light.hide()
	if config.sprite_override:
		sprite.texture = config.sprite_override
	
	light.light_color = config.color
	sprite.modulate = config.color
	
	if config.color != Color.WHITE:
		var material: ParticleProcessMaterial = particles.process_material.duplicate(true)
		material.color = config.color
		particles.process_material = material

func _setup_homing() -> void:
	if config.homing > 0.0:
		$Seeker/Hitbox.shape.radius = config.homing * 2.5
	elif config.homing_on_player:
		target = _G.player.target
	else:
		$Seeker/Hitbox.disabled = true

func _setup_audio() -> void:
	static_sfx.play()
	static_sfx.pitch_scale = clampf(randf_range(1.40, 1.75) * config.init_speed / 48.0, randf_range(1.14, 1.25), 2.4)

func _setup_scale() -> void:
	sprite.pixel_size = 0.02
	var clamped_damage: float = clampf(damage, SIZE_CLAMP_MIN, SIZE_CLAMP_MAX)
	var size: float = BASE_SIZE + clampf(clamped_damage / SIZE_DIVISOR, 0.0, 3.0)
	
	collision_shape.shape.radius = clampf(size * 0.5, 0.1, 2.0)
	scale = Vector3.ONE * size * config.size_mult
	config.bounciness = clampf(config.bounciness, 0.0, 1.75)

func _start_lifetime() -> void:
	$Timer.start(config.life_time)
	collision_shape.disabled = false

# Recalculates speed each frame based on how far through the bullet's lifetime we are.
# At t=0 (just spawned): speed = _base_speed
# At t=1 (about to expire): speed = _base_speed * config.acceleration
# acceleration == 0.0 means constant speed (lerp target is also _base_speed * 1.0,
# but we special-case it to skip the math entirely).
func _update_speed_from_lifetime() -> void:
	if config.acceleration == 0.0:
		return
	var timer: Timer = $Timer
	var lifetime_progress: float = 1.0 - (timer.time_left / config.life_time)
	speed = maxf(2.0, lerp(_base_speed, _base_speed * config.acceleration, lifetime_progress))

func _update_movement(delta: float) -> void:
	world_velocity.y -= config.fall_speed
	velocity = world_velocity + _calculate_steering() * speed
	position += velocity * delta
	raycast.target_position = velocity
	#_G.create_3d_placeholder(position, Color.WHITE, 0.1)

func _calculate_steering() -> Vector3:
	if config.homing_on_player: return _seek_player()
	if target and not disable_seek: 
		return _seek_target()
	return direction if direction != Vector3.ZERO else -transform.basis.z

func _seek_target() -> Vector3:
	if global_position.distance_to(target.global_position) < HOMING_REACH_DISTANCE:
		target = null
		return direction if direction != Vector3.ZERO else -transform.basis.z
	var desired: Vector3 = (target.global_position - global_position).normalized() * speed
	return lerp(velocity, desired, HOMING_INTERPOLATION).normalized()

func _seek_player() -> Vector3:
	var player_head: Vector3 = _G.player.global_position + Vector3(0.0, 1.1, 0.0)
	if global_position.distance_to(player_head) < HOMING_REACH_DISTANCE:
		config.homing_on_player = false
		return direction if direction != Vector3.ZERO else -transform.basis.z
	var desired: Vector3 = (player_head - global_position).normalized() * speed
	return lerp(velocity, desired, HOMING_INTERPOLATION).normalized()


func imma_bounce() -> void:
	if not raycast.is_colliding():
		direction = -direction
		speed *= config.bounciness
		world_velocity.y *= 0.5
	else:
		var normal: Vector3 = raycast.get_collision_normal()
		direction = _reflect_vector(direction, normal)
		world_velocity = _reflect_vector(world_velocity, normal)
		speed *= config.bounciness
	
	impact_particles.emitting = true

func _reflect_vector(vector: Vector3, normal: Vector3) -> Vector3:
	return (vector - 2.0 * vector.dot(normal) * normal).normalized()

func hit() -> void:
	if not active: return
	impact_sfx.play()
	if config.pierces > 0:
		_handle_pierce()
		if config.bounciness > 0.0:
			imma_bounce()
	else:
		
		despawn()

func _handle_pierce() -> void:
	destroy_object_init(config.destroy_object, config.destroy_object_properties)
	disable_seek = true
	pierces_left -= 1
	#collision_shape.disabled = true
	target = null
	await get_tree().create_timer(PIERCE_HITBOX_ACTIVATE_TIME).timeout
	disable_seek = false

func handle_destroy() -> void:
	if config.spectral: return
	if config.bounciness > 0.0:
		imma_bounce()
	else:
		despawn()
	
	impact_sfx.play()

func despawn(destroy: bool = true) -> void:
	if not active: return
	active = false
	collision_shape.disabled = true
	static_sfx.stop()
	particles.emitting = false
	impact_particles.emitting = true
	$AnimationPlayer.play("despawn")
	
	if destroy:
		destroy_object_init(config.destroy_object, config.destroy_object_properties)
	
	_spawn_split_bullets()

func _spawn_split_bullets() -> void:
	if config.split_count <= 0:
		return
	
	var split_config: BulletSettings = config.duplicate(true)
	split_config.split_count = 0
	split_config.size_mult *= config.split_size_mult
	# Set speed ONCE before the loop — it's constant for all children
	split_config.init_speed = speed * config.split_speed_mult
	
	var base_dir: Vector3 = direction if direction != Vector3.ZERO else -transform.basis.z
	var half_spread: float = deg_to_rad(config.split_spread_angle * 0.5)
	var count: int = config.split_count
	var spawn_pos: Vector3 = global_position
	var game_node: Node = _G.game
	
	# Pre-instantiate all bullets before touching the scene tree
	var bullets: Array = []
	for i in count:
		var bullet: Bullet = game_node.BULLET_SCENE.instantiate()
		
		var t: float = 0.5 if count == 1 else float(i) / float(count - 1)
		var angle_offset: float = lerp(-half_spread, half_spread, t)
		
		bullet.config = split_config
		bullet.direction = base_dir.rotated(Vector3.UP, angle_offset).normalized()
		bullet.crit = crit
		bullet.parent = parent
		bullet.global_position = spawn_pos
		
		bullets.append(bullet)
	
	# Add all children in one batch
	for bullet in bullets:
		game_node.add_child(bullet)


func destroy_object_init(scene: PackedScene, properties: Dictionary) -> void:
	if not config.destroy_object_enabled or scene == null:
		return
	
	var instance = scene.instantiate()
	for property in properties:
		instance.set(property, properties[property])
	add_child.call_deferred(instance)

func body_entered(body: Node3D) -> void:
	if body is StaticBody3D:
		handle_destroy()

func seeker_body_entered(body: Node3D) -> void:
	if body is not CharacterBody3D or config.homing_on_player: return
	if body in target_blacklist: return
	if target == null and body != get_parent():
		target = body
		
		target_blacklist.append(target)
		_T.say( "[ " + name + " ]: " + str(body) + " added to target_blacklist.", Color.WHITE, false)
		_T.say("[ " + name + " ].target_blacklist: " + str(target_blacklist), Color.WHITE, false)
	

func seeker_body_exited(body: Node3D) -> void:
	if body in target_blacklist and target == body:
		target_blacklist.pop_back()
		target = null
		_T.say( "[ " + name + " ]: " + str(body) + " removed from target_blacklist.", Color.WHITE, false)
	speed *= 1.1

func parry_seeker_area_entered(area: Area3D) -> void:
	if area is not Hazard or not area.parry:
		return
	
	imma_bounce()
	impact_sfx.play()
	parent = area.get_parent()
	speed *= config.parried_speed_multiplier
	config.homing_on_player = false
	target = null

func animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "despawn":
		queue_free.call_deferred()

func timer_timeout() -> void:
	despawn(false)
