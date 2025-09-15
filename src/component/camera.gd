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
@export var tilt : float = 0.0

@export var viewbob_amount : float = 1.0
@export var tilt_amount : float = 9.0
@export var multiplier : float = 1.0
@export var motion_blur_offset : float = 1.25

var ss_count : int = 0
var bob_offset : float = 0.0
var height_offset : float = 0.0



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
	var vb = viewbob_amount * float(_G.config.view_bob)
	fov_offsets.z = vb  * 15.0 * multiplier
	fov = _G.config.fov + fov_offsets.x + fov_offsets.y + fov_offsets.z * vb
	bob_offset = viewbob_y * vb * multiplier
	height_offset = lerpf(height_offset, (player.velocity.y / 4.2), 0.1)
	var tilt_limit : float = -player.global_transform.basis.z.dot(-head.global_transform.basis.z)
	if player.is_on_floor():
		tilt = lerpf(tilt, t * tilt_amount, 0.05) * tilt_limit
	else:
		tilt = lerpf(tilt, 0.0, 0.05)

	head.position.y = 1.816+clampf(height_offset * 0.5, -1.0, 0.0) + bob_offset
	rotation_degrees.z = tilt
	
	
	
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
	image.resize(1920, 1080, Image.INTERPOLATE_NEAREST)
	ss_count += 1
	var image_path : String = get_user_photos_path() + "/unsubstantial/capture_" + str(ss_count) + ".png"
	image.save_png(image_path)
	_G.game.chat.add_message("Saved screenshot as capture_" + str(ss_count) + ".png", Color.DEEP_PINK)
	_G.game.chat.show()

#func motion_blur_update() -> void:
	#mbcam.get_parent().
