extends Component
class_name PlayerMoveComponent

# by plumoblong WITH HELP FROM MAJIKAYOGAMES
# FOR REUSE 2025 / 2026 / WHENEVER
# >|o

@export var hitbox : CollisionShape3D
@onready var original_capsule_height : float = hitbox.shape.height
@export var dash : DashComponent
@export var land_sfx : AudioStreamPlayer3D
@export var jump_sfx : AudioStreamPlayer3D
@export var jump_buffer_timer : Timer

var air_cap : float = 0.85 # dont know what this does lol
var air_accel : float = 48.0 # how fast the player changes direction in air
var air_move_speed : float = 6.7 # how much the camera needs to move every frame to gain / maintain speed the bigger it is the easier it is to speed up 
var jump_velocity : float = 8.0

#ground
var ground_cap : float = 2.2 # caps the walking speed by multiplying ground_cap by walk_speed (e.g. 20.0 * 2.4 = 48 m/s)
var fall_speed : float = 19.0
var walk_speed : float = 18.5

var ground_accel : float = 8.0
var ground_decel : float = 8.0
var ground_friction : float = 3.5

var slope_fall_speed : float = 500.0
var noclip_speed : float = 25.0

var input_dir : Vector2
var wish_dir : Vector3

var moving : float = 0.0
var can_jump : bool = true
var was_on_floor : bool = false
var speed_bonus : float = 1.0

var noclip : bool = false
var auto_bhop : bool = false

var _player : Player
var _player_velocity : Vector3
var _is_dashing : bool
var _is_alive : bool

var _knockback_velocity : Vector3 = Vector3.ZERO
var _knockback_decay : float = 10.0

signal just_landed

func _ready() -> void:
	assert(get_parent() is Player)
	_player = get_parent()

func landed() -> void:
	just_landed.emit()
	land_sfx.pitch_scale = randf_range(0.9, 1.1)
	land_sfx.play()

func update(delta : float) -> void:
	if not enabled: return
	
	# Cache frequently accessed properties
	_is_alive = _player.essence_component.alive
	_is_dashing = dash.dashing
	_player_velocity = _player.velocity
	
	if not _is_alive:
		_player.velocity = Vector3.ZERO
		return
	input_dir = Input.get_vector("left", "right", "up", "down").normalized()
	var is_on_floor : bool = _player.is_on_floor()
	moving = lerpf(moving, (_player_velocity.length() / walk_speed) * float(is_on_floor and not _is_dashing), 0.1)
	
	if not _is_dashing:
		wish_dir = _player.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	
	# Apply knockback (always applied, decays over time)
	if _knockback_velocity.length() > 0.01:
		_player_velocity += _knockback_velocity
		_knockback_velocity = _knockback_velocity.lerp(Vector3.ZERO, _knockback_decay * delta)
	else:
		_knockback_velocity = Vector3.ZERO
	
	if noclip:
		_handle_noclip()
	else:
		_handle_jump_input(delta)
		_handle_gravity(delta)
		
		if is_on_floor:
			_handle_floor_logic(delta)
			dash.allow_dash()
		else:
			can_jump = false
			if not _is_dashing:
				handle_air(delta)
			was_on_floor = false
	
	# Apply cached velocity back
	_player.velocity = _player_velocity

func _handle_noclip() -> void:
	var spd : float = noclip_speed * (2.0 if Input.is_action_pressed("jump") else 1.0)
	_player_velocity = wish_dir * spd
	
	if Input.is_action_pressed("shoot"):
		_player_velocity.y = spd
	elif Input.is_action_pressed("dash"):
		_player_velocity.y = -spd
	else:
		_player_velocity.y = 0.0

func _handle_jump_input(delta : float) -> void:
	if auto_bhop:
		if can_jump and Input.is_action_pressed("jump"):
			handle_jump(delta, jump_velocity)
	else:
		if Input.is_action_just_pressed("jump"):
			jump_buffer_timer.start()
		if can_jump and not jump_buffer_timer.is_stopped():
			handle_jump(delta, jump_velocity)

func _handle_gravity(delta : float) -> void:
	if _is_dashing: return
	
	var gravity_multiplier : float = 1.2 if _player_velocity.y < 0 else 1.0
	_player_velocity.y -= fall_speed * gravity_multiplier * delta

func _handle_floor_logic(delta : float) -> void:
	can_jump = true
	if not was_on_floor:
		landed()
	if not _is_dashing:
		handle_ground(delta)
	was_on_floor = true
	speed_bonus = clampf(lerpf(speed_bonus, 1.0, 0.03), 0.24, 1.75)

func handle_ground(delta : float) -> void:
	if not enabled: return
	
	# Acceleration
	var cur_speed_in_wish_dir : float = _player_velocity.dot(wish_dir)
	var add_speed_till_cap : float = walk_speed * speed_bonus - cur_speed_in_wish_dir
	
	if add_speed_till_cap > 0.0:
		var accel_speed : float = minf(ground_accel * delta * walk_speed * speed_bonus, add_speed_till_cap)
		_player_velocity += accel_speed * wish_dir
	
	# Friction
	var velocity_length : float = _player_velocity.length()
	var control : float = maxf(velocity_length, ground_decel)
	var drop : float = control * ground_friction * delta
	var new_speed : float = maxf(velocity_length - drop, 0.0)
	
	if velocity_length > 0.0:
		new_speed /= velocity_length
		var side_vel : Vector2 = Vector2(_player_velocity.x * new_speed, _player_velocity.z * new_speed).limit_length(walk_speed * ground_cap * speed_bonus)
		_player_velocity = Vector3(side_vel.x, _player_velocity.y, side_vel.y)

func handle_air(delta : float) -> void:
	if not enabled: return
	
	var cur_speed_in_wish_dir : float = _player_velocity.dot(wish_dir)
	var capped_speed : float = minf((air_move_speed * wish_dir).length(), air_cap)
	var add_speed_till_cap : float = capped_speed - cur_speed_in_wish_dir
	
	if add_speed_till_cap > 0.0:
		var accel_speed : float = air_accel * delta
		_player_velocity += accel_speed * air_move_speed * wish_dir
	
	if _player.is_on_wall():
		var wall_normal : Vector3 = _player.get_wall_normal()
		_player.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING if is_surface_too_steep(wall_normal) else CharacterBody3D.MOTION_MODE_GROUNDED
		clip_velocity(wall_normal, 1)

func clip_velocity(normal: Vector3, overbounce : float) -> void:
	var backoff : float = _player_velocity.dot(normal) * overbounce
	if backoff >= 0.0: return
	
	var change : Vector3 = normal * backoff
	_player_velocity -= change
	
	# Second iteration
	var adjust : float = _player_velocity.dot(normal)
	if adjust < 0.0:
		_player_velocity -= normal * adjust

func is_surface_too_steep(normal : Vector3) -> bool:
	var max_slope_ang_dot : float = Vector3.UP.rotated(Vector3(1.0, 0.0, 0.0), _player.floor_max_angle).dot(Vector3.UP)
	return normal.dot(Vector3.UP) < max_slope_ang_dot

func handle_jump(delta : float, speed : float = jump_velocity) 	-> void:
	if not enabled: return
	jump_sfx.pitch_scale = randf_range(0.9, 1.1)
	var act_speed : float = speed
	if _player.is_on_floor():
		var floor_normal : Vector3 = _player.get_floor_normal()
		var jump_direction : Vector3 = floor_normal.normalized()
		_player_velocity += jump_direction * act_speed
		var horizontal_influence : float = 1.0 - floor_normal.dot(Vector3.UP)
		if horizontal_influence > 0.1:
			var slope_push : Vector3 = Vector3(floor_normal.x, 0, floor_normal.z).normalized()
			_player_velocity += slope_push * act_speed * 0.3 * horizontal_influence
	else:
		if _player_velocity.y > speed and not _is_dashing:
			_player_velocity.y += act_speed
		else:
			_player_velocity.y = act_speed
	can_jump = false
	jump_sfx.play()

func apply_knockback(direction: Vector3, power: float, lift_off_ground: bool = true) -> void:
	if not enabled: return
	var knockback_dir : Vector3 = direction.normalized()
	const Y_MULT : Vector3 = Vector3(1.0, 0.3, 1.0)
	if _player.is_on_floor() and lift_off_ground:
		var up_influence : float = 0.5
		knockback_dir = (knockback_dir + Vector3.UP * up_influence).normalized()
	_knockback_velocity = knockback_dir * power * Y_MULT
	can_jump = false
