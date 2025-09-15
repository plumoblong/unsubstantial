extends Hazard
class_name Explosion

@export var size : float = 1.0
@export var color : Color = Color.WHITE
@export var speed_scale : float = 2.0

func _ready() -> void:
	var hshape : SphereShape3D = $Hitbox.shape.duplicate()
	hshape.radius = size / 1.75
	$AnimationPlayer.speed_scale = speed_scale
	$Hitbox.shape = hshape
	$MeshInstance3D.radius = size
	$MeshInstance3D.color = color
	$AnimatedSprite3D.speed_scale = speed_scale
	$SFX.pitch_scale = speed_scale * randf_range(0.95, 1.05)
	$AnimationPlayer.play("explode")
	$AnimatedSprite3D.play("default")
	$AnimatedSprite3D.pixel_size = 0.011 * $Hitbox.shape.radius
	
func animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "explode":
		await get_tree().create_timer(0.5).timeout
		queue_free.call_deferred()
