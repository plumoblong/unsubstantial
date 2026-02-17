extends Node2D

@onready var node2d : Node = $Node2D
@onready var screen1 : Node = $Screen1
@onready var screen2 : Node = $Screen2
@onready var screen3 : Node = $Screen3
@onready var screen4 : Node = $Screen4
@onready var header : RichTextLabel = $Header

# Screen 1 nodes
@onready var s1_fullscreen : CheckBox = $Screen1/Fullscreen
@onready var s1_viewbob : CheckBox = $Screen1/ViewBob
@onready var s1_fov : Slider = $Screen1/FOV
@onready var s1_fov_text : Label = $Screen1/FOVText
@onready var s1_res : Button = $Screen1/Res

# Screen 2 nodes
@onready var s2_volume : Slider = $Screen2/Volume
@onready var s2_music : Slider = $Screen2/Music
@onready var s2_sfx : Slider = $Screen2/SFX
@onready var s2_volume_text : Label = $Screen2/VolumeText
@onready var s2_music_text : Label = $Screen2/MusicText
@onready var s2_sfx_text : Label = $Screen2/SFXText

# Screen 3 nodes
@onready var s3_sens : Slider = $Screen3/Sens
@onready var s3_sens_text : Label = $Screen3/SensText

# Screen 4 nodes
@onready var s4_lowmode : CheckBox = $Screen4/LowMode
@onready var s4_vsync : CheckBox = $Screen4/Vsync
@onready var s4_exposure : Slider = $Screen4/Exposure
@onready var s4_exposure_text : Label = $Screen4/ExposureText
@onready var s4_ui_darkmode : CheckBox = $Screen4/UIDarkMode
@onready var s4_motion_blur : CheckBox = $Screen4/MotionBlur

# Cached config reference
var cfg : Dictionary

# String constants
const HEADER_OPTIONS : String = "Options"
const HEADER_GENERAL : String = "General"
const HEADER_AUDIO : String = "Audio"
const HEADER_CONTROLS : String = "Controls"
const HEADER_GRAPHICS : String = "Graphics"

const FOV_TEXT : String = "Field of View:   "
const WINDOW_SIZE_TEXT : String = "Window Size: "
const SENS_TEXT : String = "Sensitivity:   "
const GAMMA_TEXT : String = "Gamma: "
const SFX_TEXT : String = "Sound Effects: "
const MASTER_VOL_TEXT : String = "Master Volume: "
const MUSIC_VOL_TEXT : String = "Music Volume: "
const PERCENT_SUFFIX : String = "%"

var screen : int = 0
var screen_size : Vector2i

func _ready() -> void:
	screen_size = DisplayServer.screen_get_size()
	# Initialize values
	s1_fullscreen.button_pressed = _G.config.fullscreen
	s1_viewbob.button_pressed = _G.config.view_bob
	s1_fov.value = _G.config.fov
	s3_sens.value = _G.config.controls.sensitivity
	s2_volume.value = _G.config.sound.master
	s2_music.value = _G.config.sound.music
	s2_sfx.value = _G.config.sound.sfx
	s4_lowmode.button_pressed = _G.config.video.low
	s4_vsync.button_pressed = _G.config.video.v_sync
	s4_exposure.value = _G.config.video.exposure
	s4_ui_darkmode.button_pressed = _G.config.ui_dark_mode

func _process(_delta : float) -> void:
	if not visible: return
	
	# Update screen visibility
	node2d.visible = screen == 0
	screen1.visible = screen == 1
	screen2.visible = screen == 2
	screen3.visible = screen == 3
	screen4.visible = screen == 4
	
	if screen != 0:
		if Input.is_action_just_pressed("escape"):
			if not s3_sens.get_parent().is_any_capturing:
				screen = 0
				header.text = HEADER_OPTIONS
				_G.save_files()
	
	match screen:
		1:
			_update_general_screen()
		2:
			_update_audio_screen()
		3:
			_update_controls_screen()
		4:
			_update_graphics_screen()

func _update_general_screen() -> void:
	header.text = HEADER_GENERAL
	s1_fov_text.text = FOV_TEXT + str(int(s1_fov.value))
	s1_fullscreen.button_pressed = _G.config.fullscreen
	
	if not _G.config.fullscreen:
		var res : int = _G.config.resolution
		s1_res.text = WINDOW_SIZE_TEXT + str(480 * res) + "x" + str(270 * res)
	else:
		s1_res.text = WINDOW_SIZE_TEXT + str(screen_size.x) + "x" + str(screen_size.y)
	
	s1_res.get_node("Shadow").text = s1_res.text
	s1_res.disabled = _G.config.fullscreen
	_G.config.view_bob = s1_viewbob.button_pressed
	_G.config.fov = s1_fov.value

func _update_audio_screen() -> void:
	header.text = HEADER_AUDIO
	s2_sfx_text.text = SFX_TEXT + str(int(s2_sfx.value * 100)) + PERCENT_SUFFIX
	s2_volume_text.text = MASTER_VOL_TEXT + str(int(s2_volume.value * 100)) + PERCENT_SUFFIX
	s2_music_text.text = MUSIC_VOL_TEXT + str(int(s2_music.value * 100)) + PERCENT_SUFFIX
	
	_G.config.sound.master = s2_volume.value
	_G.config.sound.sfx = s2_sfx.value
	_G.config.sound.music = s2_music.value

func _update_controls_screen() -> void:
	header.text = HEADER_CONTROLS
	s3_sens_text.text = SENS_TEXT + str(int(s3_sens.value * 100)) + PERCENT_SUFFIX
	_G.config.controls.sensitivity = s3_sens.value

func _update_graphics_screen() -> void:
	header.text = HEADER_GRAPHICS
	s4_exposure_text.text = GAMMA_TEXT + str(int(s4_exposure.value * 100)) + PERCENT_SUFFIX
	
	_G.config.video.low = s4_lowmode.button_pressed
	_G.config.video.v_sync = s4_vsync.button_pressed
	_G.config.ui_dark_mode = s4_ui_darkmode.button_pressed
	_G.config.video.exposure = s4_exposure.value
	_G.config.video.motion_blur = s4_motion_blur.button_pressed

func fullscreen_pressed() -> void:
	_G.change_fullscreen()

func general_button_pressed() -> void:
	screen = 1

func audio_pressed() -> void:
	screen = 2

func res_gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_G.config.resolution += 1
			MOUSE_BUTTON_RIGHT:
				_G.config.resolution -= 1

func other_pressed() -> void:
	screen = 3

func graphics_pressed() -> void:
	screen = 4

func vsync_toggled(a : bool) -> void:
	if a:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
