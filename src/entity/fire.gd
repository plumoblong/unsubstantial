extends Hazard

@export var life_time : float = 1.0
@export var size : float = 2.0
@export var color : Color = Color.WHITE
@export var enemy_only : bool = false

func _ready() -> void:
	
	if enemy_only:
		set_collision_layer_value(2, false)
		set_collision_mask_value(2, false)
	
	$CollisionShape3D.shape.radius = 0.4 * size
	$Outer.lifetime = 2.0 * size * clamp(life_time, 0.1, 99.0)
	#$Inner.lifetime = 2.5 * size
	var omat : ParticleProcessMaterial = $Outer.process_material.duplicate()
	omat.emission_sphere_radius = 0.25 * size
	$Sprite3D.pixel_size = 0.03 * size
	omat.set_param_min(ParticleProcessMaterial.PARAM_SCALE, 1.0 * size)
	omat.set_param_max(ParticleProcessMaterial.PARAM_SCALE, 2.0 * size)
	omat.color = color
	$Outer.process_material = omat
	#var imat : ParticleProcessMaterial = $Inner.process_material.duplicate()
	#imat.emission_sphere_radius = 0.2 * size
	#imat.set_param_min(ParticleProcessMaterial.PARAM_SCALE, 1.0 * size)
	#imat.set_param_max(ParticleProcessMaterial.PARAM_SCALE, 2.0 * size)
	#imat.color = color
	#$Inner.process_material = imat
	if life_time != 0.0:
		await get_tree().create_timer(life_time).timeout
		$CollisionShape3D.disabled = true
		$Outer.emitting = false
		await get_tree().create_timer(15.0).timeout
		queue_free.call_deferred()
