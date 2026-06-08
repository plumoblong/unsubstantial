extends CharacterBody3D
class_name Player

@onready var camera : PlayerCamera = $Head/Camera
@onready var movement_component : PlayerMoveComponent = $PlayerMovement
@onready var essence_component : EssenceComponent = $EssenceComponent
@onready var shoot_component : ShootComponent = $ShootComponent
@onready var dash_component : DashComponent = $DashComponent
@onready var knock_component : KnockbackComponent = $KnockbackComponent
@onready var stats : ItemStats = $ItemStats
@onready var hitbox : CollisionShape3D = $Hitbox
@onready var dash_swoosh : AnimatedSprite3D = $Head/Swoosh
@onready var hud : PlayerHUD = $HUD
@onready var target : PlayerTarget = $PlayerTarget
@onready var mblur : TextureRect = $MotionBlur
@onready var death_camera : Camera3D = $DeathCamera
@onready var player_death_anim : Node3D = $PlayerDeathAnim
@onready var hud_eye : AnimatedSprite2D = $HUD/Eye
@onready var shoot_sfx : AudioStreamPlayer = $ShootSFX
@onready var hit_sfx : AudioStreamPlayer = $HitSFX
@onready var dash_sfx : AudioStreamPlayer = $DashSFX
@onready var fast_particle : GPUParticles3D = $FastParticle
@onready var dash_query : Area3D = $DashQuery
@onready var dash_query_hitbox : CollisionShape3D = $DashQuery/Hitbox

@onready var interaction_query : Area3D = $Head/InteractionQuery

var score : int = 0
var combo : int = 0
var color : Color = Color.WHITE
#var has_key : bool = false
var immune : bool = false
var a : float = 0.0
var generating_creep : bool = false
var moving_forward : bool = false
var can_interact : bool = false
var can_control : bool = false
var start_position : Vector3
var god_mode : bool = false
var fullbright : bool = false

var _mouse_sensitivity : float = 0.005
var _last_low_quality : bool = false

var money : float = 0.0

func _enter_tree() -> void:
	can_control = true
	_G.player = self

func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion and can_control:
		var sensitivity : float = _G.config.controls.sensitivity * _mouse_sensitivity
		rotate_y(-event.screen_relative.x * sensitivity)
		camera.head.rotate_x(-event.screen_relative.y * sensitivity)
		camera.head.rotation_degrees.x = clampf(camera.head.rotation_degrees.x, -90.0, 90.0)

func debug_camera() -> void:
	camera.current = not camera.current
	death_camera.current = not camera.current

func death_anim() -> void:
	if not essence_component.alive:
		return
	camera.current = false
	death_camera.current = true
	player_death_anim.show()
	player_death_anim.play()
	hud.hide()
	shoot_component.visual_bullet.hide()

func _process(delta : float) -> void:
	
	_update_input_mode()
	_update_camera_settings()
	_update_hud(delta)
	_handle_debug_input()

func _update_input_mode() -> void:
	if can_control and not _T.visible:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _update_camera_settings() -> void:
	death_camera.fov = _G.config.fov - player_death_anim.cam_offset
	camera.mbcam.current = _G.config.video.motion_blur
	mblur.visible = _G.config.video.motion_blur
	#camera.mbcam.get_parent().debug_draw = get_viewport().debug_draw
	camera.mbcam.get_parent().scaling_3d_scale = get_viewport().scaling_3d_scale
	
	if _last_low_quality != _G.config.video.low:
		if _G.config.video.low:
			camera.far = 128.0
			camera.mbcam.far = 64.0
		else:
			camera.far = 2048.0
			camera.mbcam.far = 1028.0
		_last_low_quality = _G.config.video.low
	mblur.size = _R.get_screen_size()
	camera.mbcam.get_parent().size = _R.get_screen_size()
func _update_hud(delta : float) -> void:
	if hud_eye.animation == "open":
		hud_eye.show()
	if hud.visible:
		hud.update(Vector2(camera.viewbob_x, camera.viewbob_y), movement_component.moving, delta)
		
func _handle_debug_input() -> void:
	if Input.is_action_just_pressed("f4") and not Input.is_key_pressed(KEY_ALT):
		camera.screenshot()

func _physics_process(delta : float) -> void:
	stats.update()
	camera.update(-movement_component.input_dir.x)
	essence_component.update()
	
	hitbox.disabled = movement_component.noclip
	
	if can_control:
		if essence_component.alive:
			_process_player_movement(delta)
			_process_player_actions()
			_process_player_input()
		move_and_slide()
	else:
		camera.anim.speed_scale = 0
		camera.viewbob_amount = 0
	
	dash_query_hitbox.disabled = not dash_component.dashing
	
	update_motionblur.call_deferred()

func _process_player_movement(delta : float) -> void:
	movement_component.update(delta)
	camera.viewbob_amount = movement_component.moving * 0.5

	camera.anim.speed_scale = velocity.length() * 0.04
	
	if not movement_component.noclip and global_position.y < _G.game.chapter.current.y_boundary:
		_G.current_run.die_reason = "You went somewhere you shouldn't."
		essence_component.die()
	
	moving_forward = movement_component.input_dir.y < 0
	fast_particle.emitting = velocity.length() >= movement_component.walk_speed * 1.55 and essence_component.alive

func _process_player_actions() -> void:
	var bullet_spawn_pos : Vector3 = shoot_component.visual_bullet.sprite.global_position
	if not movement_component.noclip:
		if Input.is_action_pressed("shoot") and not dash_component.dashing:
			shoot_component.shoot(-camera.head.global_transform.basis.z, bullet_spawn_pos)
		elif Input.is_action_just_pressed("dash"):
			dash_component.dash(movement_component)
	else:
		if Input.is_action_pressed("interact"):
			shoot_component.shoot(-camera.head.global_transform.basis.z, bullet_spawn_pos)

func _process_player_input() -> void:
	if Input.is_action_just_pressed("f2") and essence_component.alive:
		hud.visible = not hud.visible
	
	if _G.game.ending_level:
		can_control = false

func query_area_entered(area : Area3D) -> void:
	if immune or dash_component.dashing:
		return
	
	if area.get_parent() != self and area is Hazard:
		if area.damage < 1:
			return
		
		_G.current_run.die_reason = area.die_reason
		essence_component.fracture(area.damage, area.crit)
		var knock_pos : Vector3 = area.parent.global_position if area.knockback_from_parent_pos else area.global_position
		knock_component.knock(knock_pos, area.knockback_strength)
		start_immunity()

func shooted() -> void:
	#hud.hide_hand(stats.bullet_atkspd / stats.actual_atkspd * 0.25)
	#await get_tree().create_timer(shoot_component.shoot_delay * stats.bullet_atkspd / stats.actual_atkspd).timeout
	shoot_sfx.pitch_scale = randf_range(1.80, 2.20) - (stats.BULLET_ATKSPD / stats.actual_atkspd)
	shoot_sfx.play()

func _on_essence_component_died(_combo : bool) -> void:
	if player_death_anim.played:
		return
	shoot_component.enabled = false
	camera.mbcam.get_parent().render_target_update_mode = SubViewport.UPDATE_DISABLED
	death_anim()
	_G.tween(mblur, "modulate", Color(1.0, 1.0, 1.0, 0.0))
	await get_tree().create_timer(2.0).timeout
	_S.fade_song(0.0, 0.75)
	_S.change_pitch(0.0, 0.75)
	_G.change_scene("res://scene/gameover.tscn", Color.BLACK, 0.75, 1.0, false)

func dash_component_dashed() -> void:
	hud_eye.play("close")
	_G.tween(camera, "multiplier", 0.0, 0.2)
	
	if not _G.game.in_ether:
		dash_swoosh.play("default")
	
	dash_swoosh.flip_h = not dash_swoosh.flip_h
	
	var crit_roll := randf_range(0.0, 100.0)
	var base_damage := int(float(stats.actual_damage) * stats.dash_damage_mult)
	
	if crit_roll < stats.crit_chance * stats.crit_mult:
		dash_query.crit = true
		dash_query.damage = base_damage * 2
	else:
		dash_query.crit = false
		dash_query.damage = base_damage
	
	start_immunity(0.5)
	dash_sfx.pitch_scale = randf_range(0.9, 1.1)
	dash_sfx.play()
	
	await get_tree().create_timer(0.4 * stats.DASH_ATKSPD / (1 + stats.attack_speed)).timeout
	_G.tween(camera, "multiplier", 1.0, 0.2)
func essence_component_gained(amount : int) -> void:
	if not hud.visible:
		return
	
	#_G.create_ui_popup("+" + str(amount), $HUD/Info/EssenceIcon/Essence.global_position)

func essence_component_fractured(amount : int, i_time : float, combo : bool) -> void:
	var time := clampf(amount / float(essence_component.max_essence), 0.25, 1.25)
	_G.flare_screen(Color(1.0, 0.0, 0.0, 0.7), Color.TRANSPARENT, time)
	
	if amount > 5:
		
		hit_sfx.pitch_scale = randf_range(0.95, 1.05)
		hit_sfx.play()
		camera.tween_camera_fov(15.0, 0.5)
		
		#if hud.visible:
			#_G.create_ui_popup("-" + str(amount), $HUD/Info/EssenceIcon/Essence.global_position - Vector2(12.0, 0.0), Vector2.UP, Color.RED)
		combo = 0
		_G.current_run.hits_taken += 1
		dash_component.can_reset = true
		movement_component.speed_bonus *= 0.5

func start_immunity(time : float = 1.0) -> void:
	immune = true
	await get_tree().create_timer(time).timeout
	immune = false

func eye_animation_finished() -> void:
	if hud_eye.animation == "open":
		hud_eye.play("default")
	elif hud_eye.animation == "close":
		hud_eye.hide()

func dash_component_can_dash_now() -> void:
	hud_eye.play("open")

func update_motionblur() -> void:
	const SMOOTHING : float = 0.95
	camera.mbcam.fov = lerpf(camera.mbcam.fov, camera.fov, SMOOTHING)
	camera.mbcam.rotation_degrees.z = lerpf(camera.mbcam.rotation_degrees.z, camera.rotation_degrees.z, SMOOTHING)
	camera.mbcam.global_rotation.x = lerpf(camera.mbcam.global_rotation.x, camera.global_rotation.x, SMOOTHING)
	camera.mbcam.global_rotation.y = lerp_angle(camera.mbcam.global_rotation.y, camera.global_rotation.y, SMOOTHING)
	camera.mbcam.global_position = lerp(camera.mbcam.global_position, camera.global_position, SMOOTHING)


func dash_query_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		velocity.x *= 0.1
		velocity.z *= 0.1
