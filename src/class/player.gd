extends CharacterBody3D
class_name Player

@onready var camera : PlayerCamera = get_node("Head/Camera")
#@onready var movement_component : MovementComponent = get_node("MovementComponent")
@onready var movement_component : PlayerMoveComponent = get_node("PlayerMovement")
@onready var essence_component : EssenceComponent = get_node("EssenceComponent")
@onready var shoot_component : ShootComponent = get_node("ShootComponent")
@onready var dash_component : DashComponent = get_node("DashComponent")
@onready var level_component : LevelComponent = get_node("LevelComponent")
@onready var knock_component : KnockbackComponent = get_node("KnockbackComponent")
@onready var items : ItemManager = get_node("ItemManager")
@onready var stats : ItemStats = get_node("ItemStats")

@onready var dash_swoosh : AnimatedSprite3D = get_node("Head/Swoosh")

@onready var hud : PlayerHUD = get_node("HUD")
@onready var target : PlayerTarget = get_node("PlayerTarget")

var score : int = 0
var randomize_stats : bool = false
var color : Color = Color.WHITE
var has_key : bool = false
var immune : bool = false
var a : float = 0.0

var generating_creep : bool = false
var moving_forward : bool = false
var can_interact : bool = false
var can_control : bool = false

var start_position : Vector3
var interact_tooltip : String = ""
var interact_description : String = ""
var fallof : float = 0.0
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

	shoot_component.enabled = not _G.game.in_ether
	essence_component.enabled = not _G.game.in_ether
	level_component.enabled = not _G.game.in_ether
	
	camera.mbcam.current = _G.config.video.motion_blur
	$MotionBlur.visible = _G.config.video.motion_blur
	if fullbright:
		camera.mbcam.get_parent().debug_draw = SubViewport.DEBUG_DRAW_UNSHADED
	else:
		camera.mbcam.get_parent().debug_draw = SubViewport.DEBUG_DRAW_DISABLED
	
	if can_control and not movement_component.noclip:
		if Input.is_action_pressed("shoot") and not dash_component.dashing:
			shoot_component.shoot(-camera.head.global_transform.basis.z, camera.head.global_position)
		elif Input.is_action_pressed("dash"):
			dash_component.dash(movement_component)
	
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
	
	
	
	stats.update(movement_component, shoot_component, dash_component, essence_component, knock_component, $DashQuery, hud)
	camera.update(-movement_component.input_dir.x)
	#movement_component.on_floor = is_on_floor()
	
	dash_component.update()
	essence_component.update()
	level_component.update()
	
	#if movement_component.on_floor:
		#input_dir.y = Input.get_axis("up", "down")
	
	#if not dash_component.dashing:
		#movement_component.direction = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	
	$Hitbox.disabled = movement_component.noclip
	
	
	if can_control:
		if essence_component.alive:
			movement_component.update(delta)
			move_and_slide()
			camera.viewbob_amount = movement_component.moving / 2.0
			if hud.visible: hud.update(Vector2(camera.viewbob_x, camera.viewbob_y), movement_component.moving / 1.5)
			camera.anim.speed_scale = (velocity.length() / movement_component.walk_speed) * 0.75
			if not movement_component.noclip and global_position.y < _G.game.chapter.current.y_boundary:
				_G.current_run.die_reason = "You succumbed to the poison."
				essence_component.die()
			moving_forward = movement_component.input_dir.y < 0
			if _G.config.video.low:
				camera.far = 128.0
			else:
				camera.far = 2048.0
			#if Input.is_action_just_pressed("jump") and movement_component.can_jump:
				#movement_component.jump()
			
			
			if Input.is_action_just_pressed("f2") and essence_component.alive:
				hud.visible = not hud.visible
	else:
		velocity = Vector3.ZERO
		camera.anim.speed_scale = 0
		camera.viewbob_amount = 0
	$DashQuery/Hitbox.disabled = not dash_component.dashing

	if has_key:
		_G.game.all_gates_open = true
	#velocity = movement_component.vel
	
	update_motionblur.call_deferred()
	
func query_area_entered(area : Area3D) -> void:
	if immune or dash_component.dashing: return
	if area.get_parent() != self: 
		if area is Hazard:
			if area.damage < 1: return
			_G.current_run.die_reason = area.die_reason
			knock_component.knock(area.global_position, area.knockback_strength, area.knockback_y_strength)
			essence_component.fracture(area.damage, area.crit)
			start_immunity()

func shooted() -> void:
	hud.hide_hand()
	await get_tree().create_timer(shoot_component.shoot_delay * (stats.bullet.fire_rate * stats.bullet.fire_rate_mult)).timeout
	#if not _G.game.in_ether:
		#essence_component.essence -= clampi(stat.damage[0], stat.damage[2], 999) * stat.damage[1] / 2
	$ShootSFX.pitch_scale = randf_range(1.80, 2.20) - (stats.bullet.fire_rate * stats.bullet.fire_rate_mult)
	$ShootSFX.play()

func _on_essence_component_died(_combo : bool) -> void:
	#essence_component.essence = essence_component.start_essence
	if $PlayerDeathAnim.played: return
	camera.mbcam.get_parent().render_target_update_mode = SubViewport.UPDATE_DISABLED
	death_anim()
	_G.tween($MotionBlur, "modulate", Color(1.0, 1.0, 1.0, 0.0))
	await get_tree().create_timer(2.0).timeout
	
	_G.change_scene("res://scene/gameover.tscn", Color.BLACK, 0.75, 1.0, false)
	return
	#_G.game.gameover()
	
func dash_component_dashed() -> void:
	hud.hide_hand()
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


	await get_tree().create_timer(0.4 * stats.dash_cooldown * stats.dash_cooldown_mult).timeout
	_G.tween(camera, "multiplier", 1.0, 0.2)
	hud.show_hand()
	#hud.hide_punchhand()

func essence_component_gained(amount : int) -> void:
	_G.create_ui_popup("+" + str(amount), Vector2(38.0, 250.0))

func essence_component_fractured(amount : int, _crit : bool) -> void:
	var time : float = clampf(amount / essence_component.max_essence, 0.25, 1.25)
	_G.flare_screen(Color(1, 1, 1, 0.7), Color.TRANSPARENT, time)
	_G.create_ui_popup("-" + str(amount), Vector2(38.0, 250.0), Vector2.UP, Color.RED)
	camera.tween_camera_fov(15.0, 0.5)
	_G.current_run.hits_taken += 1
	camera.tween_camera_fov(-20.0, time)
	$HitSFX.play()

func shoot_component_reseted() -> void:
	hud.show_hand()

func start_immunity(time : float = 1.0) -> void:
	immune = true
	await get_tree().create_timer(time).timeout
	immune = false

func level_component_xp_gained() -> void:
	essence_component.gain((float(essence_component.max_essence) * 0.03))
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
	#camera.mbcam.fov = lerpf(camera.mbcam.fov ,camera.fov, mb_smoothing)
	camera.mbcam.fov = camera.fov - (1.0 - essence_component.ratio)
	camera.mbcam.global_rotation = camera.global_rotation
	camera.mbcam.global_position = camera.global_position
	#camera.mbcam.rotation_degrees.z = lerpf(camera.mbcam.rotation_degrees.z ,camera.tilt, mb_smoothing)
	#camera.mbcam.global_rotation.x = lerpf(camera.mbcam.global_rotation.x ,camera.global_rotation.x, mb_smoothing)
	#camera.mbcam.global_rotation.y = lerpf(camera.mbcam.global_rotation.y ,camera.global_rotation.y, mb_smoothing)
	
	#camera.mbcam.global_position = lerp(camera.mbcam.global_position ,camera.global_position, mb_smoothing)
