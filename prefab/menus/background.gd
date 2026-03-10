extends Node2D

func _process(_delta: float) -> void:
	$ColorRect.size = _R.get_screen_size()
	$Sprite2D.size = _R.get_screen_size()
	$TextureRect.size = _R.get_screen_size()
	$TextureRect.visible = visible
	$TextureRect.position = Vector2i.ZERO
	$DarkMode.size = _R.get_screen_size()
	$DarkMode.visible = visible and _G.config.ui_dark_mode
	$GPUParticles2D2.position = Vector2(_R.get_screen_size().x / 2.0, -10.0)
	$GPUParticles2D2.process_material.emission_box_extents.x = _R.get_screen_size().x
	$GPUParticles2D3.position = Vector2(_R.get_screen_size().x / 2.0, -10.0)
	$GPUParticles2D3.process_material.emission_box_extents.x = _R.get_screen_size().x
