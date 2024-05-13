extends CharacterBody3D
class_name LocalPlayer

@export var default_speed : float = 7.5
@export var max_speed : float = 30.0
@export var jump_speed : float = 6.0
@export var camera_h_offset : float = 0.0
@export var camera_v_offset : float = 0.0
@export var flare_transparency : float = 0.0
@export var hit_marker_transparency : float = 0.0

const BULLET_RES := preload("res://prefabs/bullet.tscn")
var invincible : bool = false
var speed : float = 0.0
var input_dir : Vector2 = Vector2.ZERO
var ammo : int = 6
var can_shoot : bool = true
var direction
var moving_speed : float = 0.0
var can_respawn : bool = false
var kills : int = 0
var alive : bool = true
var score : float = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera = get_node("Camera")
#var bullet_res = preload("res://prefabs/bullet.tscn")

@onready var start_position = global_position

func _ready():
	invincibility(2.5)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	speed = default_speed

func _input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * global.config.sensivity / 100)
			#camera.rotate_x(-event.relative.y  * global.config.sensivity / 100)
			
func _physics_process(delta):

	camera.fov = global.config.fov
	$Gui/Score.text = "[wave amp=16 freq=3]" + str(score) + "[/wave]" 
	$Gui/Speed.text = str(round(speed))
	score = clamp(score, 0, 999999)
	speed = clamp(speed, default_speed, max_speed)
	
	if invincible:
		$Sprite.visible = not $Sprite.visible
		$Gui/Hand.visible =  not $Gui/Hand.visible
	else:
		$Sprite.visible = true
		$Gui/Hand.visible = true
	if not is_on_floor():
		global.tween(self, "moving_speed", 0, 0.5, Tween.TRANS_LINEAR)
		velocity.y -= gravity * delta
	#else:
		#if Input.is_action_just_pressed("jump"):
			#velocity.y = jump_speed
		
	if global_position.y < -50.0:
		die()
		
	if Input.is_action_just_pressed("f2"):
		$Gui.visible = not $Gui.visible
	
	$Gui/HitMarker.material.set_shader_parameter("modulate", Color(1, 1, 1, hit_marker_transparency))
	
	if Input.is_action_just_pressed("return"):
		$Menu.visible = not $Menu.visible
	if $Menu.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		input_dir = Vector2.ZERO
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		
		if Input.is_action_pressed("shoot") and can_shoot:
			shoot()
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	$AnimationPlayer.play("running")
	camera.h_offset = camera_h_offset * moving_speed
	camera.v_offset = camera_v_offset * moving_speed
	$Gui/Hand.offset.x = -44 + ((camera_h_offset * 64) * moving_speed)
	$Gui/Hand.offset.y = -74 + ((camera_v_offset * 24) * moving_speed)
	
	$AnimationPlayer.speed_scale = 0.25 + ((speed  - default_speed)/ (max_speed - default_speed)) / 1.5
	
	if direction:
		if is_on_floor():
			global.tween(self, "moving_speed", global.config.view_bobbing_amount, 0.5, Tween.TRANS_LINEAR)
			if speed < max_speed - (max_speed / 5):
				speed += delta * 4
			else:
				if speed < max_speed:
					speed -= delta
		else:
			if speed < max_speed - (max_speed / 12):
				speed += delta * 6
				
		
				
		velocity.x = lerp(velocity.x, direction.x * speed, .05)
		velocity.z = lerp(velocity.z, direction.z * speed, .05)
	else:
		if speed > default_speed:
			speed -= delta * 8
			
		global.tween(self, "moving_speed", 0, 0.5, Tween.TRANS_LINEAR)
		velocity.x = lerp(velocity.x, .0, .05)
		velocity.z = lerp(velocity.z, .0, .05)

	if alive: move_and_slide()
	
	$Hitbox.disabled = not alive

func _on_area_3d_area_entered(area):
	if area.is_in_group("BulletCollectable"):
		$GPUParticles3D2.emitting = true
		ammo += 1
		area.queue_free()

func _on_area_3d_body_entered(body):
	if body.is_in_group("Enemy") and not body.dead:
		get_tree().reload_current_scene()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		can_shoot = true
func shoot():
	$ShootSFX.pitch_scale = randf_range(1.10, 1.30)
	var bullet = BULLET_RES.instantiate()
	get_parent().add_child(bullet)
	bullet.creator = self

	bullet.set_deferred("global_position", global_position)
	bullet.direction= -global.angle_to_vector(rotation_degrees.y)
	can_shoot = false
	global.tween($Gui/Hand, "position", Vector2($Gui/Hand.position.x, 300), 0.25, Tween.TRANS_SINE)
	$ShootSFX.play()
	await get_tree().create_timer(0.65).timeout
	global.tween($Gui/Hand, "position", Vector2($Gui/Hand.position.x, 196), 0.25, Tween.TRANS_SINE)
	await get_tree().create_timer(0.35).timeout
	can_shoot = true

func crosshair_target_shot():
	speed += 2.5
	hit_marker_transparency = 1.0
	global.tween(self, "hit_marker_transparency", 0.0, 0.5, Tween.TRANS_SINE)
	$HitMarkerSFX.play()

func die():
	speed = default_speed - 1
	alive = false
	$DeathSFX.play()
	$Flare.color = Color.WHITE
	global_position = start_position
	add_score(-1000)
	global.tween($Flare, "color", Color.TRANSPARENT, 1, Tween.TRANS_SINE)
	invincibility(2.5)
	alive = true

func invincibility(length : float):
	invincible = true
	await get_tree().create_timer(length).timeout
	invincible = false

func add_score(value):
	$Gui/Score.position.y = 152
	score += value
	global.tween($Gui/Score, "position", Vector2($Gui/Score.position.x, 160), 0.5, Tween.TRANS_LINEAR)
