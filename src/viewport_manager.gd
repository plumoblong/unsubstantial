extends Node
class_name ViewportManager

# THIS SCRIPT IS USED IN CASES WHERE THE ASPECT RATIO ISNT THE DEFAULT 16:9
# MEANT FOR HUDS AND UI, SO THEY ARE IN THE CORRECT POSITIONS

var margin: int = 8  # in pixels
const base_resolution : Vector2i = Vector2i(480, 270)

# Cached viewport size
var _viewport_size: Vector2i = Vector2i.ZERO

func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_viewport_size = Vector2i(get_viewport().get_visible_rect().size)
	
func _on_viewport_size_changed() -> void:
	_viewport_size = Vector2i(get_viewport().get_visible_rect().size)
	
func _right(mx: int) -> int:
	return _viewport_size.x - mx

func _bottom(my: int) -> int:
	return _viewport_size.y - my

func _cx() -> int:
	return _viewport_size.x / 2

func _cy() -> int:
	return _viewport_size.y / 2

func _mx(mx: int, override: bool) -> int:
	return mx if override else mx + margin

func _my(my: int, override: bool) -> int:
	return my if override else my + margin


# --- Corners ---

func get_top_left(override: bool = false, mx: int = 0, my: int = 0) -> Vector2i:
	return Vector2i(_mx(mx, override), _my(my, override))

func get_top_right(override: bool = false, mx: int = 0, my: int = 0) -> Vector2i:
	return Vector2i(_right(_mx(mx, override)), _my(my, override))

func get_bottom_left(override: bool = false, mx: int = 0, my: int = 0) -> Vector2i:
	return Vector2i(_mx(mx, override), _bottom(_my(my, override)))

func get_bottom_right(override: bool = false, mx: int = 0, my: int = 0) -> Vector2i:
	return Vector2i(_right(_mx(mx, override)), _bottom(_my(my, override)))


# --- Edge Centers ---

func get_top_center(override: bool = false, my: int = 0) -> Vector2i:
	return Vector2i(_cx(), _my(my, override))

func get_bottom_center(override: bool = false, my: int = 0) -> Vector2i:
	return Vector2i(_cx(), _bottom(_my(my, override)))

func get_left_center(override: bool = false, mx: int = 0) -> Vector2i:
	return Vector2i(_mx(mx, override), _cy())

func get_right_center(override: bool = false, mx: int = 0) -> Vector2i:
	return Vector2i(_right(_mx(mx, override)), _cy())

func get_center() -> Vector2i:
	return Vector2i(_cx(), _cy())

func get_screen_size() -> Vector2i:
	return _viewport_size

func get_screen_aspect() -> Vector2:
	return Vector2(float(_viewport_size.x) / float(base_resolution.x), float(_viewport_size.y) / float(base_resolution.y))

func get_aspect_coefficient() -> float:
	var aspect : Vector2 = get_screen_aspect()
	if aspect.x > aspect.y:
		return aspect.x
	return aspect.y
		
#func _update_viewport() -> void:
	#var screen_size : Vector2i = DisplayServer.screen_get_size(-1)
	#var scale : int = _get_best_scale(screen_size)
	#var scaled : Vector2i = screen_size / scale
	#get_tree().root.content_scale_size = scaled
#
#func _get_best_scale(screen_size : Vector2i) -> int:
	## Find the largest integer scale where the viewport fits
	#var scale : int = 1
	#while true:
		#var next : Vector2i = screen_size / (scale + 1)
		#if next.x < base_resolution.x or next.y < base_resolution.y:
			#break
		#scale += 1
	#return scale
