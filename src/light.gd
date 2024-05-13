extends CSGMesh3D

@export var color : Color = Color.WHITE
@export var radius : float = 15.0

var final_color : Color
var speed : Vector3 = Vector3(10, 10, 10)

# Called when the node enters the scene tree for the first time.
func _ready():
	speed.x = randf_range(-128, 127)
	speed.y = randf_range(-128, 127)
	speed.z = randf_range(-128, 127)
	
	final_color.r = randf_range(color.r - 0.1, color.r + 0.1)
	final_color.g = randf_range(color.g - 0.1, color.g + 0.1)
	final_color.b = randf_range(color.b - 0.1, color.b + 0.1)
	
	$Light.shadow_enabled = global.config.graphics.shadows
	$Light.light_color = final_color
	material.albedo_color = final_color

func _process(delta):
	
	rotation_degrees.x += delta * speed.x
	rotation_degrees.y += delta * speed.y
	rotation_degrees.z += delta * speed.z
