extends CharacterBody3D
class_name Player

@onready var camera : PlayerCamera = get_node("Head/Camera")
@onready var movement_component : PlayerMoveComponent = get_node("PlayerMovement")
@onready var essence_component : EssenceComponent = get_node("EssenceComponent")
@onready var shoot_component : ShootComponent = get_node("ShootComponent")
@onready var dash_component : DashComponent = get_node("DashComponent")
@onready var level_component : LevelComponent = get_node("LevelComponent")
@onready var knock_component : KnockbackComponent = get_node("KnockbackComponent")
@onready var stats : ItemStats = get_node("ItemStats")
@onready var hitbox : CollisionShape3D = get_node("Hitbox")

@onready var dash_swoosh : AnimatedSprite3D = get_node("Head/Swoosh")
@onready var hud : PlayerHUD = get_node("HUD")
@onready var target : PlayerTarget = get_node("PlayerTarget")
@onready var mblur : TextureRect = get_node("MotionBlur")

var score : int = 0
var color : Color = Color.WHITE
var has_key : bool = false
var immune : bool = false
var a : float = 0.0

var generating_creep : bool = false
var moving_forward : bool = false
var can_interact : bool = false
var can_control : bool = false

var start_position : Vector3

#var input_dir : Vector2

var god_mode : bool = false
var fullbright : bool = false

func _enter_tree() -> void:
	can_control = true
	_G.player = self

func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion and can_control:
		rotate_y(-event.screen_relative.x * _G.config.controls.sensitivity * (0.005))
		camera.head.rotate_x(-event.screen_relative.y * _G.config.controls.sensitivity * (0.005))
		camera.head.rotation_degrees.x = clamp(camera.head.rotation_degrees.x, -90.0, 90.0)
func debug_camera() -> void:
	if camera.current:
		camera.current = false
		$DeathCamera.current = true
	else:
		camera.current = true
		$DeathCamera.current = false

func death_anim() -> void:
	if not essence_component.alive: return
	camera.current = false
	$DeathCamera.current = true
	$PlayerDeathAnim.show()
	$PlayerDeathAnim.play()
	hud.visible = false

func _process(_delta : float) -> void:
	if can_control and not _T.visible:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	$DeathCamera.fov = _G.config.fov - $PlayerDeathAnim.cam_offset

	camera.mbcam.current = _G.config.video.motion_blur
	mblur.visible = _G.config.video.motion_blur
	
	camera.mbcam.get_parent().debug_draw = get_viewport().debug_draw
	camera.mbcam.get_parent().scaling_3d_scale = get_viewport().scaling_3d_scale


	if _G.config.video.low:
		camera.far = 128.0
		camera.mbcam.far = 64.0
	else:
		camera.far = 2048.0
		camera.mbcam.far = 1028.0
	if $HUD/Eye.animation == "open": $HUD/Eye.show()
	
	if shoot_component.enabled:
		if immune:
			$HUD/Weapon.visible = not $HUD/Weapon.visible
		else:
			$HUD/Weapon.visible = true
	else:
		$HUD/Weapon.visible = false
		
	if Input.is_action_just_pressed("f4"):
		if not Input.is_key_pressed(KEY_ALT):
			camera.screenshot()

func _physics_process(delta : float) -> void:
	stats.update()
	camera.update(-movement_component.input_dir.x)
	dash_component.update()
	essence_component.update()
	level_component.update()
	$Hitbox.disabled = movement_component.noclip

	if can_control:
		if essence_component.alive:
			movement_component.update(delta)
			move_and_slide()
			camera.viewbob_amount = movement_component.moving / 2.0
			if hud.visible: hud.update(Vector2(camera.viewbob_x, camera.viewbob_y), movement_component.moving / 1.5)
			camera.anim.speed_scale = (velocity.length() / movement_component.walk_speed) * 0.75
			if not movement_component.noclip and global_position.y < _G.game.chapter.current.y_boundary:
				_G.current_run.die_reason = "You went somewhere you shouldn't."
				essence_component.die()
			moving_forward = movement_component.input_dir.y < 0
			if not movement_component.noclip:
				if Input.is_action_pressed("shoot") and not dash_component.dashing:
					shoot_component.shoot(-camera.head.global_transform.basis.z, camera.head.global_position)
				elif Input.is_action_just_pressed("dash"):
					dash_component.dash(movement_component)
			if Input.is_action_just_pressed("f2") and essence_component.alive:
				hud.visible = not hud.visible
			
			if _G.game.ending_level:
				can_control = false
			$FastParticle.emitting = velocity.length() >= movement_component.walk_speed * 1.55
	else:
		velocity = Vector3.ZERO
		camera.anim.speed_scale = 0
		camera.viewbob_amount = 0
	$DashQuery/Hitbox.disabled = not dash_component.dashing

	if has_key:
		_G.game.all_gates_open = true
	
	update_motionblur.call_deferred()
	
func query_area_entered(area : Area3D) -> void:
	if immune or dash_component.dashing: return
	if god_mode: return
	if area.get_parent() != self: 
		if area is Hazard:
			if area.damage < 1: return
			_G.current_run.die_reason = area.die_reason
			knock_component.knock(area.parent.global_position, area.knockback_strength, area.knockback_y_strength)
			essence_component.fracture(area.damage, area.crit)
			start_immunity()

func shooted() -> void:
	hud.hide_hand(stats.bullet_atkspd / stats.actual_atkspd * 0.25)
	await get_tree().create_timer(shoot_component.shoot_delay * stats.bullet_atkspd / stats.actual_atkspd).timeout
	#if not _G.game.in_ether:
		#essence_component.essence -= clampi(stat.damage[0], stat.damage[2], 999) * stat.damage[1] / 2
	$ShootSFX.pitch_scale = randf_range(1.80, 2.20) - (stats.bullet_atkspd / stats.actual_atkspd)
	$ShootSFX.play()

func _on_essence_component_died(_combo : bool) -> void:
	#essence_component.essence = essence_component.start_essence
	if $PlayerDeathAnim.played: return
	camera.mbcam.get_parent().render_target_update_mode = SubViewport.UPDATE_DISABLED
	death_anim()
	_G.tween(mblur, "modulate", Color(1.0, 1.0, 1.0, 0.0))
	await get_tree().create_timer(2.0).timeout
	
	_G.change_scene("res://scene/gameover.tscn", Color.BLACK, 0.75, 1.0, false)
	return
	#_G.game.gameover()$Query/Hitbox
	
func dash_component_dashed() -> void:
	hud.hide_hand(stats.dash_atkspd / stats.actual_atkspd  * 0.15)
	$HUD/Eye.play("close")
	_G.tween(camera, "multiplier", 0.0, 0.2)
	if not _G.game.in_ether: dash_swoosh.play("default")
	dash_swoosh.flip_h = not dash_swoosh.flip_h
	#hud.show_punchhand()
	var c : float = randf_range(0.0, 100.0)
	if c < stats.crit_chance * stats.crit_mult:
		$DashQuery.crit = true
		$DashQuery.damage = int(float(stats.actual_damage) * stats.dash_damage_mult) * 2
	else:
		$DashQuery.crit = false
		$DashQuery.damage = int(float(stats.actual_damage) * stats.dash_damage_mult)
	start_immunity(0.5)
	$DashSFX.pitch_scale = randf_range(0.9, 1.1)
	$DashSFX.play()
	#if not _G.game.in_ether:
		#essence_component.essence -= int($DashQuery.damage / 2.0)
	camera.tween_camera_fov2(-15.0, 1.5)


	await get_tree().create_timer(0.4 * stats.dash_atkspd / (1 + stats.attack_speed)).timeout
	_G.tween(camera, "multiplier", 1.0, 0.2)
	hud.show_hand()
	#hud.hide_punchhand()

func essence_component_gained(amount : int) -> void:
	_G.create_ui_popup("+" + str(amount), Vector2(float(randi_range(24.0, 38.0)), float(randi_range(224.0, 256.0))))

func essence_component_fractured(amount : int, _crit : bool) -> void:
	var time : float = clampf(amount / essence_component.max_essence, 0.25, 1.25)
	_G.flare_screen(Color(1, 1, 1, 0.7), Color.TRANSPARENT, time)
	if amount > 5:
		$HitSFX.pitch_scale = randf_range(0.95, 1.05)
		$HitSFX.play()
		_G.flare_screen(Color(1, 1, 1, 0.7), Color.TRANSPARENT, time)
		camera.tween_camera_fov(15.0, 0.5)
		_G.create_ui_popup("-" + str(amount), Vector2(38.0, 250.0), Vector2.UP, Color.RED)
		_G.current_run.hits_taken += 1

func shoot_component_reseted() -> void:
	hud.show_hand()

func start_immunity(time : float = 1.0) -> void:
	immune = true
	await get_tree().create_timer(time).timeout
	immune = false

func level_component_xp_gained() -> void:
	essence_component.gain(int(10.0 * essence_component.heal_multiplier))
	$XPPickupSFX.pitch_scale = randf_range(0.98, 1.02) + level_component.ratio / 1.75
	$XPPickupSFX.play()

func level_component_leveled_up() -> void:
	_G.game.leveled_up = true

func eye_animation_finished() -> void:
	if $HUD/Eye.animation == "open":
		$HUD/Eye.play("default")
	elif $HUD/Eye.animation == "close":
		$HUD/Eye.hide()

func dash_component_can_dash_now() -> void:
	$HUD/Eye.play("open")

func update_motionblur() -> void:
	const SMOOTHING : float = 0.8
	camera.mbcam.fov = lerpf(camera.mbcam.fov, camera.fov, SMOOTHING) * (0.98 + essence_component.ratio * 0.02) 
	camera.mbcam.rotation_degrees.z = lerpf(camera.mbcam.rotation_degrees.z ,camera.tilt, SMOOTHING)
	camera.mbcam.global_rotation.x = lerpf(camera.mbcam.global_rotation.x ,camera.global_rotation.x, SMOOTHING)
	camera.mbcam.global_rotation.y = lerp_angle(camera.mbcam.global_rotation.y ,camera.global_rotation.y, SMOOTHING)
	camera.mbcam.global_position = lerp(camera.mbcam.global_position ,camera.global_position, SMOOTHING)
