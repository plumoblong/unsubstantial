extends Camera3D
class_name PlayerCamera

@onready var anim : AnimationPlayer = get_node("AnimationPlayer")
@onready var player : Player = get_parent().get_parent()
@onready var head : Node3D = get_parent()
@onready var mbcam : Camera3D = $"../SubViewport/MotionBlurCam"

#@export var mblur_image : ImageTexture

@export var fov_offsets : Vector3 = Vector3(0.0, 0.0, 0.0)
@export var viewbob_x : float = 0.0
@export var viewbob_y : float = 0.0

var viewbob_amount : float = 1.0
@export var tilt_amount : float = 9.0
@export var multiplier : float = 1.0
@export var motion_blur_offset : float = 1.25

var head_base_height : float = 1.825
var ss_count : int = 0
var bob_offset : float = 0.0
var height_offset : float = 0.0

const TILT_LERP : float = 0.08

func _ready() -> void:
	anim.play("viewbob")
	
	var dir := DirAccess.open(get_user_photos_path())
	if dir != null:
		dir.make_dir("unsubstantial")
		dir = DirAccess.open(get_user_photos_path() + "/unsubstantial")
		
		for n in dir.get_files():
			ss_count += 1
	else:
		dir = DirAccess.open("user://")
		dir.make_dir("screenshots") 
		dir = DirAccess.open("user://screenshots")
		
		for n in dir.get_files():
			ss_count += 1

func update(t : float) -> void:
	#h_offset = viewbob_x * viewbob_amount
	#anim.speed_scale = player.velocity.length() / player.stats.speed
	fov_offsets.z = viewbob_amount * 15.0 * multiplier
	fov = _G.config.fov + fov_offsets.x + fov_offsets.y + fov_offsets.z * viewbob_amount
	if _G.config.view_bob:
		bob_offset = viewbob_y * viewbob_amount * multiplier
		height_offset = lerpf(height_offset, (player.velocity.y / 4.2), 0.1)
		head.position.y = head_base_height+clampf(height_offset * 0.5, -1.0, 0.0) + bob_offset
		rotation_degrees.z = _update_tilt(t)
	else:	
		head.position.y = head_base_height
		rotation_degrees.z = 0.0
	
func _update_tilt(t : float) -> float:
	var tilt : float = 0.0
	if player.is_on_floor():
		tilt = lerpf(tilt, t * tilt_amount, TILT_LERP)
	else:
		tilt = lerpf(tilt, 0.0, TILT_LERP)
	return tilt
	
func tween_camera_fov(amount : float = 20.0, time : float = 1.0) -> void:
	_G.tween(self, "fov_offsets", Vector3(amount, fov_offsets.y, fov_offsets.z), time / 10.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	await get_tree().create_timer(time / 10.0).timeout
	_G.tween(self, "fov_offsets", Vector3(0.0, fov_offsets.y, fov_offsets.z), time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

func tween_camera_fov2(amount : float = -20.0, time : float = 1.0) -> void:
	_G.tween(self, "fov_offsets", Vector3(fov_offsets.x, amount, fov_offsets.z), time / 10.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	await get_tree().create_timer(time / 10.0).timeout
	_G.tween(self, "fov_offsets", Vector3(fov_offsets.x, 0.0, fov_offsets.z), time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

func get_user_photos_path() -> String:
	var home_path : String = ""
	if OS.has_feature("windows"):
		home_path = OS.get_environment("USERPROFILE")
	else:
		home_path = OS.get_environment("HOME")
	
	# Adjust this path based on your platform and user's preferences
	var photos_path :String = home_path + "/Pictures"
	return photos_path

func screenshot() -> void:
	#ar d : bool = _G.config.graphics.post_process
	#_G.config.graphics.post_process = false
	_G.game.chat.hide()
	await RenderingServer.frame_post_draw
	var image : Image = get_viewport().get_texture().get_image()
	image.resize(_R.get_screen_size().x * 2, _R.get_screen_size().y * 2, Image.INTERPOLATE_NEAREST)
	ss_count += 1
	var date : Dictionary = Time.get_datetime_dict_from_system(false)
	var date_string : String = str(date.year) + "_" + str(date.month) + "_" + str(date.day) + "_" + str(date.hour) + "-" + str(date.minute) + "-" + str(date.second)
	var image_path : String = get_user_photos_path() + "/unsubstantial/capture_" + date_string + ".png"
	image.save_png(image_path)
	_G.game.chat.add_message("Saved screenshot as capture_" + date_string + ".png", Color.DEEP_PINK)
	_G.game.chat.show()
