extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Shadows.button_pressed = global.config.graphics.shadows
	$Crosshair.button_pressed = global.config.crosshair
	$Process.button_pressed = global.config.graphics.post_process
	
	$ViewBob.value = global.config.view_bobbing
	$Fov.value = global.config.fov
	$Sensitivity.value = global.config.sensitivity
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	global.config.graphics.shadows = $Shadows.button_pressed
	global.config.crosshair = $Crosshair.button_pressed
	global.config.graphics.post_process = $Process.button_pressed
	
	global.config.view_bobbing = $ViewBob.value
	global.config.fov = $Fov.value
	global.config.sensitivity = $Sensitivity.value
