extends Sprite3D
class_name Vine

var color : Color
const MAX_GRASS_RADIUS : float = 8.0

func _ready() -> void:
	color = Color.from_hsv(randf_range(0.0, 1.0), randf_range(0.5, 1.0), randf_range(0.6, 1.0))
	$Light.light_color = color
	frame = randi_range(0, 5)
	flip_h = bool(randi_range(0, 1))
	scale.y = randf_range(1.0, 2.0)
	scale.x = randf_range(1.0, 1.5)
	modulate = color
	for i : Sprite3D in $Grass.get_children():
		i.flip_h = bool(randi_range(0, 1))
		i.frame = randi_range(0, 2)
		i.pixel_size = randf_range(0.04, 0.06)
		i.scale.y = randf_range(1.0, 3.0)
		i.global_position = global_position + \
		Vector3(randf_range(-MAX_GRASS_RADIUS, MAX_GRASS_RADIUS), 0.0, randf_range(-MAX_GRASS_RADIUS, MAX_GRASS_RADIUS))
		i.modulate = color
