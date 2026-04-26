extends NavigationAgent3D

func _ready() -> void:
	debug_path_custom_color = _G.game.get_chapter_color()
	debug_enabled = _T.debug_flags[1]
