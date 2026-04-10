extends Sprite3D
class_name Vine

var color : Color
var flip : bool = false
const MAX_GRASS_RADIUS : float = 8.0

func _ready() -> void:
	color = _G.game.get_chapter_color()
	$Light.light_color = color
	frame = randi_range(0, 5)
	flip_h = bool(randi_range(0, 1))
	scale.y = randf_range(1.0, 2.0)
	scale.x = randf_range(1.0, 1.5)
	modulate = color
	if flip: 
		offset.y = -12.0
		flip_v = true
	else:
		offset.y = -132.0
		flip_v = false
	for i : Sprite3D in $Grass.get_children():
		i.flip_h = bool(randi_range(0, 1))
		i.frame = randi_range(0, 2)
		i.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y if flip else BaseMaterial3D.BILLBOARD_ENABLED
		i.pixel_size = randf_range(0.04, 0.06)
		i.scale.y = randf_range(1.0, 3.0)
		i.global_position = global_position + \
		Vector3(randf_range(-MAX_GRASS_RADIUS, MAX_GRASS_RADIUS), float(flip) * -0.2, randf_range(-MAX_GRASS_RADIUS, MAX_GRASS_RADIUS))
		i.modulate = color
