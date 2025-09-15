extends MeshInstance3D

@export var strength : float = 0.0
@export var color : Color = Color.WHITE
@export var alpha : float = 1.0
@export var scale_amount : float = 1.0
@export var radius : float = 1.0

func _process(delta: float) -> void:
	material_override.set_shader_parameter("strength", strength)
	material_override.set_shader_parameter("albedo_f", Color(color.r, color.g, color.b, alpha))
	scale = Vector3(radius, radius, radius) * scale_amount
