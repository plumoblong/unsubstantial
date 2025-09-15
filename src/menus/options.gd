extends Node2D

var screen : int = 0

func _ready() -> void:
	$Screen1/Fullscreen.button_pressed = _G.config.fullscreen
	$Screen1/ViewBob.button_pressed = _G.config.view_bob
	$Screen1/FOV.value = _G.config.fov
	$Screen3/Sens.value = _G.config.controls.sensitivity
	$Screen2/Volume.value = _G.config.sound.master
	$Screen2/Music.value = _G.config.sound.music
	$Screen2/SFX.value =_G.config.sound.sfx
	$Screen4/LowMode.button_pressed = _G.config.video.low
	$Screen4/PostProcess.button_pressed = _G.config.video.post_process
	$Screen4/Vsync.button_pressed = _G.config.video.v_sync
	$Screen4/Exposure.value = _G.config.video.exposure
	$Screen4/UIDarkMode.button_pressed = _G.config.ui_dark_mode
	
func _process(_delta : float) -> void:
	if not visible: return
	$Node2D.visible = screen == 0
	$Screen1.visible = screen == 1
	$Screen2.visible = screen == 2
	$Screen3.visible = screen == 3
	$Screen4.visible = screen == 4
	if screen != 0:
		if Input.is_action_just_pressed("escape"):
			if not $Screen3.is_any_capturing: 
				screen = 0
				$Header.text = "Options"
	match screen:
		1:
			$Header.text = "General"
			
			$Screen1/FOVText.text = "Field of View:   " + str(int($Screen1/FOV.value))
			$Screen1/Fullscreen.button_pressed = _G.config.fullscreen
			
			if not _G.config.fullscreen:
				$Screen1/Res.text = "Window Size: " + str(480 * _G.config.resolution) + "x" + str(270 * _G.config.resolution)
			else:
				$Screen1/Res.text = "Window Size: " + str(DisplayServer.screen_get_size().x) + "x" + str(DisplayServer.screen_get_size().y)
			$Screen1/Res.disabled = _G.config.fullscreen
			
			_G.config.view_bob = $Screen1/ViewBob.button_pressed
			_G.config.fov = $Screen1/FOV.value
		2:
			$Header.text = "Audio"
			$Screen2/SFXText.text = "Sound Effects: " + str($Screen2/SFX.value * 100) + "%"
			$Screen2/VolumeText.text = "Master Volume: " + str($Screen2/Volume.value * 100) + "%"
			$Screen2/MusicText.text = "Music Volume: " + str($Screen2/Music.value * 100) + "%"

			_G.config.sound.master = $Screen2/Volume.value
			_G.config.sound.sfx = $Screen2/SFX.value
			_G.config.sound.music = $Screen2/Music.value
		3:
			$Header.text = "Controls"
			$Screen3/SensText.text = "Sensitivity:   " + str($Screen3/Sens.value * 100) + "%"
			_G.config.controls.sensitivity = $Screen3/Sens.value
		4:
			$Header.text = "Graphics"
			$Screen4/ExposureText.text = "Gamma: " + str($Screen4/Exposure.value * 100) + "%"
			$Screen4/UIDarkMode.disabled = not $Screen4/PostProcess.button_pressed
			
			_G.config.video.low = $Screen4/LowMode.button_pressed
			_G.config.video.post_process = $Screen4/PostProcess.button_pressed
			_G.config.video.v_sync = $Screen4/Vsync.button_pressed
			_G.config.ui_dark_mode = $Screen4/UIDarkMode.button_pressed
			_G.config.video.exposure = $Screen4/Exposure.value
			_G.config.video.motion_blur = $Screen4/MotionBlur.button_pressed
			
	#_G.config.fullscreen = $Fullscreen.button_pressed

func fullscreen_pressed() -> void:
	_G.change_fullscreen()

func general_button_pressed() -> void:
	screen = 1

func audio_pressed()-> void:
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
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
