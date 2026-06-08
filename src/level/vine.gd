extends Sprite3D
class_name Vine

var color : Color
var flip : bool = false
const MAX_GRASS_RADIUS : float = 5.0

var ray_cast_mult : float = -1.0

func _ready() -> void:
	var ray1 : RayCast3D = $Ray1
	var ray2 : RayCast3D = $Grass/Grass1/Ray2
	var ray3 : RayCast3D = $Grass/Grass2/Ray3
	var ray4 : RayCast3D = $Grass/Grass3/Ray4
	color = _G.game.get_chapter_color()
	$Light.light_color = color
	frame = randi_range(0, 5)
	flip_h = bool(randi_range(0, 1))
	scale.y = randf_range(1.0, 2.0)
	scale.x = randf_range(1.0, 1.5)
	modulate = color
	if flip: 
		ray_cast_mult = -1.0
		offset.y = -12.0
		flip_v = true
	else:
		ray_cast_mult = 1.0
		offset.y = -132.0
		flip_v = false
	var ray_target_pos : Vector3 = Vector3.UP * ray_cast_mult
	ray1.target_position = ray_target_pos
	ray2.target_position = ray_target_pos
	ray3.target_position = ray_target_pos
	ray4.target_position = ray_target_pos
	for i : Sprite3D in $Grass.get_children():
		i.flip_h = bool(randi_range(0, 1))
		i.frame = randi_range(0, 2)
		i.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y if flip else BaseMaterial3D.BILLBOARD_ENABLED
		i.pixel_size = randf_range(0.04, 0.06)
		i.scale.y = randf_range(1.0, 3.0)
		i.global_position = global_position + \
		Vector3(randf_range(-MAX_GRASS_RADIUS, MAX_GRASS_RADIUS), float(flip) * -0.2, randf_range(-MAX_GRASS_RADIUS, MAX_GRASS_RADIUS))
		i.modulate = color
	if ray1.is_colliding():
		pixel_size = 0.0
	if ray2.is_colliding():
		$Grass/Grass1.queue_free.call_deferred()
	if ray3.is_colliding():
		$Grass/Grass2.queue_free.call_deferred()
	if ray4.is_colliding():
		$Grass/Grass3.queue_free.call_deferred()
