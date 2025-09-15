extends Component
class_name PlayerMoveComponent

# PLUMOBLONG WITH HELP FROM MAJIKAYOGAMES
# FOR REUSE 2025 
# >|o

@export var dash : DashComponent
@export var land_sfx : AudioStreamPlayer3D
@export var jump_sfx : AudioStreamPlayer3D
@export var jump_buffer_timer : Timer

@export var air_cap : float = 0.85 # dont know what this does lol
@export var air_accel : float = 50.0 # how fast the player changes direction in air
@export var air_move_speed : float = 5.5 # how much the camera needs to move every frame to gain / maintain speed the bigger it is the easier it is to speed up 
@export var jump_velocity : float = 7.6

#ground
@export var ground_cap : float = 2.4 # caps the walking speed by multiplying ground_cap by walk_speed (e.g. 20.0 * 2.4 = 48 m/s)
@export var fall_speed : float = 19.0
@export var walk_speed : float = 20.0
@export var ground_accel : float = 8.0
@export var ground_decel : float = 11.0
@export var ground_friction : float = 3.0

@export var slope_fall_speed : float = 500.0

@export var noclip_speed : float = 25.0

var input_dir : Vector2
var wish_dir : Vector3

var moving : float = 0.0
var can_jump : bool = true
var was_on_floor : bool = false

var noclip : bool = false
var auto_bhop : bool = false

signal just_landed

func _ready() -> void:
	assert(get_parent() is Player)

func landed() -> void:
	just_landed.emit()
	land_sfx.pitch_scale = randf_range(0.9, 1.1)
	land_sfx.play()

func update(delta : float) -> void:
	if not enabled: return
	if get_parent().essence_component.alive:
		input_dir = Input.get_vector("left", "right", "up", "down").normalized()
		
		if not dash.dashing: wish_dir = get_parent().global_transform.basis * Vector3(input_dir.x, .0, input_dir.y)

		if noclip:
			var spd : float = noclip_speed
			if Input.is_action_pressed("jump"):
				spd = noclip_speed * 2.0
			else:
				spd = noclip_speed
			get_parent().velocity = wish_dir * spd
			if Input.is_action_pressed("shoot"):
				get_parent().velocity.y = spd
			elif Input.is_action_pressed("dash"):
				get_parent().velocity.y = -spd
			else:
				get_parent().velocity.y = 0.0
		else:
			
			if auto_bhop:
				if can_jump:
					if Input.is_action_pressed("jump"):
						handle_jump(jump_velocity)
			else:
				if Input.is_action_just_pressed("jump"):
					jump_buffer_timer.start()
				if can_jump and not jump_buffer_timer.is_stopped():
					handle_jump(jump_velocity)
			
			if rad_to_deg(get_parent().get_floor_angle()) != 0.0:
				if not dash.dashing:
					get_parent().velocity.y -= fall_speed * delta
				
			if get_parent().is_on_floor():
				can_jump = true
				if not was_on_floor:
					landed()
				if not dash.dashing:
					handle_ground(delta)
				if input_dir.length() != 0.0:
					moving = lerpf(moving, 1.0, 0.1)
				else:
					moving = lerpf(moving, 0.0, 0.1)
				was_on_floor = true
			else:
				moving = lerpf(moving, 0.0, 0.1)
				if not dash.dashing:
					handle_air(delta)
				was_on_floor = false
	else:
		get_parent().velocity = Vector3.ZERO
	
	
func handle_ground(delta : float) -> void:
	# Similar to the air movement. Acceleration and friction on ground.
	if not enabled: return
	var cur_speed_in_wish_dir : float = get_parent().velocity.dot(wish_dir)
	var add_speed_till_cap : float = walk_speed - cur_speed_in_wish_dir
	if add_speed_till_cap > 0.0:
		var accel_speed : float = ground_accel * delta * walk_speed
		accel_speed = minf(accel_speed, add_speed_till_cap)
		get_parent().velocity += accel_speed * wish_dir
	# Apply friction
	var control : float = max(get_parent().velocity.length(), ground_decel)
	var drop : float = control * ground_friction * delta
	var new_speed : float = max(get_parent().velocity.length() - drop, 0.0)
	if get_parent().velocity.length() > 0.0:
		new_speed /= get_parent().velocity.length()
	var side_vel : Vector2 = Vector2(get_parent().velocity.x * new_speed, get_parent().velocity.z * new_speed).limit_length(walk_speed * ground_cap)
	get_parent().velocity = Vector3(side_vel.x, get_parent().velocity.y, side_vel.y)
	
func handle_air(delta : float) -> void:
	# Classic battle tested & fan favorite source/quake air movement recipe.
	# CSS players gonna feel their gamer instincts kick in with this one
	if not enabled: return
	var cur_speed_in_wish_dir : float = get_parent().velocity.dot(wish_dir)
	# Wish speed (if wish_dir > 0 length) capped to air_cap
	var capped_speed : float = min((air_move_speed * wish_dir).length(), air_cap)
	# How much to get to the speed the player wishes (in the new dir)
	# Notice this allows for infinite speed. If wish_dir is perpendicular, we always need to add velocity
	#  no matter how fast we're going. This is what allows for things like bhop in CSS & Quake.
	# Also happens to just give some very nice feeling movement & responsiveness when in the air.
	var add_speed_till_cap : float = capped_speed - cur_speed_in_wish_dir
	if add_speed_till_cap > 0.0:
		var accel_speed : float = air_accel * delta # Usually is adding this one.
		#accel_speed = min(accel_speed, add_speed_till_cap) # Works ok without this but sticking to the recipe
		get_parent().velocity += accel_speed * air_move_speed * wish_dir
	
	if get_parent().is_on_wall():
		if is_surface_too_steep(get_parent().get_wall_normal()):
			get_parent().motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
		else:
			get_parent().motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
		clip_velocity(get_parent().get_wall_normal(), 1)
	
func clip_velocity(normal: Vector3, overbounce : float) -> void:
	# When strafing into wall, + gravity, velocity will be pointing much in the opposite direction of the normal
	# So with this code, we will back up and off of the wall, cancelling out our strafe + gravity, allowing surf.
	var backoff : float = get_parent().velocity.dot(normal) * overbounce
	# Not in original recipe. Maybe because of the ordering of the loop, in original source it
	# shouldn't be the case that velocity can be away away from plane while also colliding.
	# Without this, it's possible to get stuck in ceilings
	if backoff >= 0.0: return
	
	var change = normal * backoff
	get_parent().velocity -= change
	
	# Second iteration to make sure not still moving through plane
	# Not sure why this is necessary but it was in the original recipe so keeping it.
	var adjust : float = get_parent().velocity.dot(normal)
	if adjust < 0.0:
		get_parent().velocity -= normal * adjust

func is_surface_too_steep(normal : Vector3) -> bool:
	var max_slope_ang_dot = Vector3.UP.rotated(Vector3(1.0,0,0), get_parent().floor_max_angle).dot(Vector3.UP)
	if normal.dot(Vector3.UP) < max_slope_ang_dot:
		return true
	return false

func handle_jump(speed : float = jump_velocity) -> void:
	if not enabled: return
	jump_sfx.pitch_scale = randf_range(0.9, 1.1)
	if get_parent().is_on_floor():
		get_parent().velocity += get_parent().get_floor_normal() * speed
	else:
		if get_parent().velocity.y > speed and not dash.dashing:
			get_parent().velocity.y += speed
		else:
			get_parent().velocity.y = speed
	can_jump = false
	jump_sfx.play()
