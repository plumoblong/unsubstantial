extends Hazard
class_name Bullet

@onready var sprite : Sprite3D = get_node("Sprite3D")
@onready var light : OmniLight3D = get_node("OmniLight3D")

@export var config : BulletSettings

var parried : bool = false

var direction : Vector3
var velocity : Vector3
var active : bool = true

var target : CharacterBody3D
var speed : float
var disable_seek : bool = false
var can_attack_parent : bool = false

func _ready() -> void:
	if crit:
		damage = config.damage * 2.0
	else:
		damage = config.damage
	knockback_strength = config.knockback
	stun_time = config.stun
	speed = config.init_speed
	if config.sprite_override != null:
		sprite.texture = config.sprite_override
	$OmniLight3D.light_color = config.color
	$Sprite3D.modulate = config.color
	if config.homing > 0.0:
		$Seeker/Hitbox.shape.radius = config.homing * 2.5
	else:
		$Seeker/Hitbox.disabled = true
	$StaticSFX.play()
	$StaticSFX.pitch_scale = randf_range(1.40, 1.75) * config.init_speed / 48.0
	if config.color != Color.WHITE:
		var unig : ParticleProcessMaterial = $GPUParticles3D.process_material.duplicate(true)
		unig.color = config.color
		$GPUParticles3D.process_material = unig
	var size : float = 0.5 + clamp((clamp(damage, 34.0, 1000.0)) / 400.0, 0, 3)
	$CollisionShape3D.shape.radius = size * 0.85
	#print(get_parent().name, size)
	scale = Vector3(size, size, size) * config.size_mult
	if config.homing_on_player:
		target = _G.player
	$Timer.start(config.life_time)
	# await get_tree().create_timer(config.life_time).timeout
	# despawn(false)
	
func _physics_process(delta : float) -> void:
	$StaticSFX.volume_linear = float(_G.player.can_control)
	if not active or not _G.player.can_control: return
	velocity = seek() * speed
	$RayCast3D.target_position = velocity
	position += velocity * delta
			
func hit() -> void:
	if not active: return
	$ImpactSFX.play()
	if not config.piercing:
		despawn()
	else:
		destroy_object_init(config.destroy_object, config.destroy_object_properties)
		disable_seek = true
		$CollisionShape3D.disabled = true
		target = null

func imma_bounce() -> void:
	if parried or not config.can_parry: return
	if not $RayCast3D.is_colliding():
		direction = -direction
	else:
		direction += $RayCast3D.get_collision_normal()
	speed += config.parried_speed_multiplier
	$Impact.emitting = true
	config.homing_on_player = false
	target = null
	
func seek() -> Vector3:
	var steer : Vector3 = Vector3.ZERO
	if not config.homing_on_player:
		if target and not disable_seek:
			var desired : Vector3 = (target.global_position - global_position).normalized() * speed
			#steer = (desired - velocity).normalized()
			steer = lerp(velocity, desired, config.homing_interlpolation).normalized()
		else:
			if direction == Vector3.ZERO:
				steer = -transform.basis.z 
			else:
				steer = direction
	else:
		var desired : Vector3 = (_G.player.global_position + Vector3(0.0, 1.1, 0.0) - global_position).normalized() * speed
		#steer = (desired - velocity).normalized()
		steer = lerp(velocity, desired, config.homing_interlpolation).normalized()
	
	return steer
	
func despawn(destroy : bool = true) -> void:
	if not active: return
	active = false
	$CollisionShape3D.disabled = true
	$StaticSFX.stop()
	$GPUParticles3D.emitting = false
	$Impact.emitting = true
	$AnimationPlayer.play("despawn")
	if not destroy: return
	destroy_object_init(config.destroy_object, config.destroy_object_properties)
	
func seeker_body_entered(body : Node3D) -> void:
	if body is not CharacterBody3D: return
	if config.homing_on_player: return
	if body != target and body != get_parent():
		target = body
		
func seeker_body_exited(_body : CharacterBody3D) -> void:
	speed *= 1.1

func animation_player_animation_finished(anim_name : String) -> void:
	if anim_name == "despawn":
		queue_free.call_deferred()

func parry_seeker_area_entered(area : Area3D) -> void:
	if area is not Hazard: return
	if not area.parry: return
	imma_bounce()
	$ImpactSFX.play()
	parent = area.get_parent()
	speed *= config.parried_speed_multiplier

func handle_destroy(body : Node3D) -> void:
	if body is not StaticBody3D: return
	if config.spectral: return
	
	if config.bouncy:
		if not $RayCast3D.is_colliding():
			direction = -direction
		else:
			direction = $RayCast3D.get_collision_normal().normalized()
	else:
		despawn()
	$ImpactSFX.play()


func destroy_object_init(scene : PackedScene, properties : Dictionary) -> void:
	if not config.destroy_object_enabled: return
	if scene == null: return
	var do_instance = scene.instantiate()
	for i in properties:
		do_instance.set(i, properties[i])
	add_child.call_deferred(do_instance)



func body_entered(body: StaticBody3D) -> void:
	handle_destroy(body)

func timer_timeout() -> void:
	despawn(false)
