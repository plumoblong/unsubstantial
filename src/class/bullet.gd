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
var disable_seek : bool = false
var can_attack_parent : bool = false

var target : Node3D

const BASE_SIZE : float = 0.5
const SIZE_CLAMP_MIN : float = 34.0
const SIZE_CLAMP_MAX : float = 1000.0
const SIZE_DIVISOR : float = 400.0
const PIERCE_HITBOX_ACTIVATE_TIME : float = 32.0

func _ready() -> void:
	pierces_left = config.pierces
	
	_setup_damage()
	_setup_speed()
	_setup_visuals()
	_setup_homing()
	_setup_audio()
	_setup_scale()
	_start_lifetime()
	
	

func _physics_process(delta: float) -> void:
	static_sfx.volume_linear = float(_G.player.can_control)
	if not active or not _G.player.can_control:
		return
	_update_movement(delta)
	
func _setup_damage() -> void:
	damage = config.damage * (2.0 if crit else 1.0)
	knockback_strength = config.knockback
	stun_time = config.stun

func _setup_speed() -> void:
	speed = config.init_speed
	if parent is Player:
		speed += parent.velocity.length() * 0.75
func _setup_visuals() -> void:
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

func _update_movement(delta: float) -> void:
	world_velocity.y -= config.fall_speed
	velocity = world_velocity + _calculate_steering() * speed
	position += velocity * delta * config.acceleration
	raycast.target_position = velocity
	_G.create_3d_placeholder(position, Color.WHITE, 0.1)

func _calculate_steering() -> Vector3:
	if config.homing_on_player: return _seek_player()
	if target and not disable_seek: return _seek_target()
	return direction if direction != Vector3.ZERO else -transform.basis.z

func _seek_target() -> Vector3:
	var desired: Vector3 = (target.global_position - global_position).normalized() * speed
	return lerp(velocity, desired, config.homing_interlpolation).normalized()

func _seek_player() -> Vector3:
	var player_head: Vector3 = _G.player.global_position + Vector3(0.0, 1.1, 0.0)
	var desired: Vector3 = (player_head - global_position).normalized() * speed
	return lerp(velocity, desired, config.homing_interlpolation).normalized()

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
	if config.pierces > 0 or config.bounciness > 0.0:
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
	#await get_tree().create_timer(PIERCE_HITBOX_ACTIVATE_TIME / 1000.0).timeout
	#collision_shape.disabled = false

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
	if body is not CharacterBody3D or config.homing_on_player:
		return
	
	if body != target and body != get_parent():
		target = body

func seeker_body_exited(_body: Node3D) -> void:
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

func seek() -> Vector3:
	return _calculate_steering()
