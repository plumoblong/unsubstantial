extends CharacterBody3D
class_name Enemy


@onready var agent := get_node("NavigationAgent3D")

@export var default_speed : float = 13.0
@export var max_speed : float = 18.5
@export var distance_to_chase : float = 25.0
@export var distance_to_shoot : float = 10.0
@export var shoot_cooldown : float = 1.5
@export var color : Color = Color.CRIMSON
@export var bullet_speed : float = 64.0
@export var bounty : float =  750.0
var start_position : Vector3

var alive : bool = true
var chasing : bool = false
var shooting : bool = false
var direction : Vector3
var speed : float = default_speed
var can_shoot : bool = true


const BULLET_RES = preload("res://prefabs/bullet.tscn")
func _ready():
	if global.game_mode == global.GAME_MODE.MULTI:
		queue_free()
	start_position = global_position
	$Sprite3D.modulate = color
	$Light.light_color = color
	
func _physics_process(delta):
	
	var target_distance = global_position.distance_to(get_parent().target.global_position)
	shooting = target_distance < distance_to_shoot
	
	if global_position.y < -50:
		die()

	if not get_parent().target.alive:
		global_position = start_position
		chasing = false
	
	if not is_on_floor():
		velocity.y -= get_parent().gravity * delta
		
	direction = global_position.direction_to(agent.get_next_path_position())
	
	if target_distance < distance_to_chase:
		chasing = true
	elif target_distance > distance_to_chase:
		chasing = false
		
	if get_parent().target_node_path != null and alive:
		if shooting:
			if can_shoot and get_parent().target.alive: shoot()
		if chasing:
			agent.target_position = get_parent().target.global_position
		else:
			agent.target_position = start_position
	if direction:
		if is_on_floor():
			if speed < max_speed:
				speed += delta * 3
		velocity.x = lerp(velocity.x, direction.x * speed, .05)
		velocity.z = lerp(velocity.z, direction.z * speed, .05)
	else:
		reset_speed()
		velocity.x = lerp(velocity.x, 0.0, .05)
		velocity.z = lerp(velocity.z, 0.0, .05)

	if alive: move_and_slide()
	
func reset_speed():
	await get_tree().create_timer(1.0).timeout
	if is_on_floor():
		speed = default_speed

func die():
	alive = false
	$Sprite3D.modulate = Color.WHITE
	$Light.light_color = Color.WHITE
	$DeathSFX.play()
	global.tween($Sprite3D, "modulate", Color.TRANSPARENT, 0.5, Tween.TRANS_SINE)
	global.tween($Light, "light_energy", 0, 1.0, Tween.TRANS_SINE)
	$Hitbox.set_deferred("disabled",true)
	await get_tree().create_timer(2).timeout
	queue_free()
	
func shoot():
	$ShootSFX.pitch_scale = randf_range(1.00, 1.20)
	var bullet = BULLET_RES.instantiate()
	get_parent().add_child(bullet)
	bullet.creator = self
	bullet.speed = bullet_speed
	bullet.global_position = global_position
	bullet.direction = global_position.direction_to(get_parent().target.global_position)
	can_shoot = false
	$ShootSFX.play()
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true
