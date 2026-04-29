extends Node2D
class_name WorldTo2D

@export var distance_gradient : Gradient
@export var distance_mult : float = 4.0
@export var interpolation : float = 1.0

@export var edge_margin : float = 32.0
@export var clamp_to_screen : bool = false
@export var clamp_offset : float = 16.0

@export var parent_position_offset : Vector3 = Vector3.ZERO

var active : bool = true

var in_view : bool

func _world_to_screen(world_pos: Vector3) -> Vector2:
	var screen_pos: Vector2 = _G.player.camera.unproject_position(world_pos)
	var screen_size: Vector2 = _R._viewport_size
	
	in_view = screen_pos.x > -edge_margin and screen_pos.x < screen_size.x + edge_margin \
		and screen_pos.y > -edge_margin and screen_pos.y < screen_size.y + edge_margin \
		and _G.player.camera.is_position_behind(world_pos) == false
	visible = in_view and _G.player.hud.visible and active

	if clamp_to_screen:
		screen_pos.x = clamp(screen_pos.x, clamp_offset, screen_size.x - clamp_offset)
		screen_pos.y = clamp(screen_pos.y, clamp_offset, screen_size.y - clamp_offset)

	return screen_pos

func _get_3d_pos() -> Vector3:
	if get_parent() is not Node3D:
		return Vector3.ZERO
	return get_parent().global_position + parent_position_offset

func _update_distance() -> void:
	var distance_to_cam : float = _get_3d_pos().distance_to(_G.player.camera.global_position) / distance_mult
	var sampled_color : Color = distance_gradient.sample(distance_to_cam) if distance_gradient != null else Color.WHITE
	modulate = sampled_color
	
func _process(_delta: float) -> void:

	_update_distance()
	global_position = lerp(global_position, _world_to_screen(_get_3d_pos()), interpolation)
